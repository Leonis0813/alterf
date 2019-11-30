class Evaluation
  class Datum < ApplicationRecord
    validates :race_id, :race_name, :race_url, :ground_truth,
              presence: {message: 'absent'}
    validates :race_id,
              format: {with: /\A\d+\z/, message: 'invalid'},
              allow_nil: true
    validates :ground_truth,
              numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
              allow_nil: true

    belongs_to :evaluation
    has_many :prediction_results,
             class_name: 'Prediction::Result',
             as: :predictable,
             dependent: :destroy,
             inverse_of: :predictable

    def import_prediction_results(result_file)
      race_result = YAML.load_file(result_file)
      raise ActiveRecord::RecordInvalid, self unless race_result.is_a?(Hash)

      race_result.each do |number, result|
        prediction_results.create!(number: number, won: (result == 1))
      end
    end
  end
end
