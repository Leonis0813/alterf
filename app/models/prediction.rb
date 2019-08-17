class Prediction < ApplicationRecord
  validates :model, :test_data, :state,
            presence: {message: 'absent'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :results, as: :predictable, dependent: :destroy, inverse_of: :predictable

  def import_results(result_file)
    race_result = YAML.load_file(result_file)
    raise ActiveRecord::RecordInvalid, self unless race_result.is_a?(Hash)

    race_result.each do |number, result|
      results.create!(number: number, won: (result == 1))
    end
  end
end
