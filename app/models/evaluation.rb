class Evaluation < ApplicationRecord
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

  validates :evaluation_id, :model, :num_data, :state,
            presence: {message: 'absent'}
  validates :evaluation_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'}
  validates :data_source,
            inclusion: {in: DATA_SOURCE_LIST, message: 'invalid'},
            allow_nil: true
  validates :num_data,
            numericality: {only_interger: true, greater_than: 0, message: 'invalid'},
            allow_nil: true
  validates :num_data,
            numericality: {equal_to: NUM_DATA_REMOTE, message: 'invalid'},
            allow_nil: true,
            if: :remote?
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}
  validates :precision, :recall, :f_measure,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 1,
              message: 'invalid',
            },
            allow_nil: true

  has_many :data, dependent: :destroy

  after_initialize :set_default_num_data

  def fetch_data!
    race_ids = if remote?
                 NetkeibaClient.new.http_get_race_top
               else
                 file_path = Rails.root.join(
                   'tmp',
                   'files',
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
    precision = recall = f_measure = 0.0
    unless (true_positive + false_positive).zero?
      precision = true_positive / (true_positive + false_positive)
    end
    unless (true_positive + false_negative).zero?
      recall = true_positive / (true_positive + false_negative)
    end
    unless (precision + recall).zero?
      f_measure = (2 * precision * recall) / (precision + recall)
    end
    update!(precision: precision, recall: recall, f_measure: f_measure)
  end

  private

  def remote?
    data_source == DATA_SOURCE_REMOTE
  end

  def set_default_num_data
    case data_source
    when DATA_SOURCE_RANDOM
      self.num_data ||= NUM_DATA_RANDOM_DEFAULT
    when DATA_SOURCE_REMOTE
      self.num_data = NUM_DATA_REMOTE
    end
  end

  def true_positive
    data.inject(0) do |tp, datum|
      tp + datum.prediction_results.won.where(number: datum.ground_truth).count
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
end
