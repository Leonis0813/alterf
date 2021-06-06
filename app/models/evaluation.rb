class Evaluation < ApplicationRecord
  include ModelUtil

  DATA_SOURCE_FILE = 'file'.freeze
  DATA_SOURCE_REMOTE = 'remote'.freeze
  DATA_SOURCE_RANDOM = 'random'.freeze
  DATA_SOURCE_TEXT = 'text'.freeze
  DATA_SOURCE_LIST = [
    DATA_SOURCE_FILE,
    DATA_SOURCE_RANDOM,
    DATA_SOURCE_REMOTE,
    DATA_SOURCE_TEXT,
  ].freeze

  NUM_DATA_RANDOM_DEFAULT = 100
  NUM_DATA_REMOTE = 20

  validates :evaluation_id, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :num_data,
            numericality: {
              only_interger: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true,
            unless: :remote?
  validates :num_data,
            numericality: {equal_to: NUM_DATA_REMOTE, message: MESSAGE_INVALID},
            allow_nil: true,
            if: :remote?
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true
  validates :precision, :recall, :specificity, :f_measure,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1,
              message: MESSAGE_INVALID,
            },
            allow_nil: true

  belongs_to :analysis
  has_many :data, dependent: :destroy

  after_initialize if: :new_record? do |evaluation|
    evaluation.evaluation_id = SecureRandom.hex
    evaluation.state = DEFAULT_STATE

    case evaluation.data_source
    when DATA_SOURCE_RANDOM
      evaluation.num_data ||= NUM_DATA_RANDOM_DEFAULT
    when DATA_SOURCE_REMOTE
      evaluation.num_data = NUM_DATA_REMOTE
    end
  end

  after_create :broadcast

  def set_analysis!
    data_dir = Rails.root.join('tmp/files/evaluations', id.to_s)
    analysis_id = read_analysis_id(File.join(data_dir, 'metadata.yml'))
    analysis = Analysis.find_by(analysis_id: analysis_id)
    raise StandardError if analysis.nil?

    update!(analysis: analysis)
  end

  def fetch_data!
    race_ids = case data_source
               when DATA_SOURCE_RANDOM
                 sample_race_ids
               when DATA_SOURCE_REMOTE
                 NetkeibaClient.new.http_get_race_top
               else
                 file_path = Rails.root.join(
                   'tmp/files/evaluations',
                   id.to_s,
                   Settings.evaluation.race_list_filename,
                 )
                 File.read(file_path).lines.map(&:chomp)
               end

    race_ids.each do |race_id|
      data.create!(
        race_id: race_id,
        race_name: Denebola::Race.find_by(race_id: race_id).race_name,
        race_url: "#{Settings.netkeiba.base_url}/race/#{race_id}",
        ground_truth: Denebola::Feature.find_by(race_id: race_id, won: true).number,
      )
    end
  end

  def calculate!
    precision = recall = 0.0
    attribute = {}
    unless (true_positive + false_positive).zero?
      precision = true_positive / (true_positive + false_positive)
      attribute[:precision] = precision
    end
    unless (true_positive + false_negative).zero?
      recall = true_positive / (true_positive + false_negative)
      attribute[:recall] = recall
    end
    unless (true_negative + false_positive).zero?
      attribute[:specificity] = true_negative / (true_negative + false_positive)
    end
    unless (precision + recall).zero?
      attribute[:f_measure] = (2 * precision * recall) / (precision + recall)
    end
    update!(attribute)

    completed_data_size = data.to_a.count {|datum| datum.prediction_results.present? }

    %i[precision recall f_measure].each {|key| attribute[key] ||= 0 }
    attribute[:progress] = (100 * completed_data_size / data.size.to_f).round(0)
    broadcast(attribute)

    attribute[:evaluation_id] = evaluation_id
    ActionCable.server.broadcast('evaluation_datum', attribute)
  end

  def output_race_ids
    return if [DATA_SOURCE_FILE, DATA_SOURCE_TEXT].include?(data_source)

    file_path = Rails.root.join('tmp/files/evaluations', id.to_s, 'data.txt')
    File.open(file_path, 'w') do |file|
      data.pluck(:race_id).each {|race_id| file.puts(race_id) }
    end
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    broadcast(state: state, performed_at: performed_at.strftime('%Y/%m/%d %T'))
  end

  def complete!
    update!(state: STATE_COMPLETED, completed_at: Time.zone.now)
    broadcast(slice(:state, :data_source))
  end

  def failed!
    update!(state: STATE_ERROR)
    broadcast(slice(:state))
  end

  private

  def remote?
    data_source == DATA_SOURCE_REMOTE
  end

  def sample_race_ids
    Denebola::Feature.pluck(:race_id).uniq.sample(self.num_data)
  end

  def true_positive
    data.inject(0) do |tp, datum|
      tp + datum.prediction_results.won.where(number: datum.ground_truth).count
    end.to_f
  end

  def true_negative
    data.inject(0) do |tn, datum|
      tn + datum.prediction_results.lost.where.not(number: datum.ground_truth).count
    end.to_f
  end

  def false_positive
    data.inject(0) do |fp, datum|
      fp + datum.prediction_results.won.where.not(number: datum.ground_truth).count
    end.to_f
  end

  def false_negative
    data.inject(0) do |fn, datum|
      fn + datum.prediction_results.lost.where(number: datum.ground_truth).count
    end.to_f
  end

  def broadcast(attribute = {})
    updated_attribute = attribute.merge('evaluation_id' => evaluation_id)
    ActionCable.server.broadcast('evaluation', updated_attribute)
  end
end
