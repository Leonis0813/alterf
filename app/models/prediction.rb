class Prediction < ApplicationRecord
  include ModelUtil

  validates :prediction_id, :state,
            presence: {message: 'absent'}
  validates :prediction_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  has_many :results, as: :predictable, dependent: :destroy, inverse_of: :predictable

  after_initialize if: :new_record? do |prediction|
    prediction.prediction_id = SecureRandom.hex
    prediction.state = DEFAULT_STATE
  end

  def set_analysis!
    data_dir = Rails.root.join('tmp', 'files', 'predictions', id.to_s)
    analysis_id = read_analysis_id(File.join(data_dir, 'metadata.yml'))
    analysis = Analysis.find_by(analysis_id: analysis_id)
    raise StandardError if analysis.nil?

    update!(analysis: analysis)
  end

  def import_results(result_file)
    race_result = YAML.load_file(result_file)
    raise ActiveRecord::RecordInvalid, self unless race_result.is_a?(Hash)

    race_result.each do |number, result|
      results.create!(number: number, won: (result == 1))
    end
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    broadcast('performed_at' => performed_at.strftime('%Y/%m/%d %T'))
  end

  def completed!
    update!(state: STATE_COMPLETED)
    broadcast('wons' => results.won.pluck(:number).sort)
  end

  def failed!
    update!(state: STATE_ERROR)
    broadcast
  end

  private

  def broadcast(attribute = {})
    updated_attribute = slice(:prediction_id, :state).merge(attribute)
    ActionCable.server.broadcast('prediction', updated_attribute)
  end
end
