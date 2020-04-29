class Prediction < ApplicationRecord
  include ModelUtil

  validates :prediction_id, :model, :test_data, :state,
            presence: {message: 'absent'}
  validates :prediction_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: 'invalid'},
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: 'invalid'},
            allow_nil: true

  has_many :results, as: :predictable, dependent: :destroy, inverse_of: :predictable

  after_initialize if: :new_record? do |prediction|
    prediction.prediction_id = SecureRandom.hex
    prediction.state = DEFAULT_STATE
  end

  def set_analysis!
    data_dir = Rails.root.join('tmp', 'files', id.to_s)
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
end
