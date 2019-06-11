class Prediction < ActiveRecord::Base
  validates :model, :test_data, :state,
            presence: {message: 'absent'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :results, as: :predictable, dependent: :destroy, inverse_of: :prediction

  def import_results(result_file)
    YAML.load_file(result_file).each do |number, result|
      prediction.results.create!(number: number) if result == 1
    end
  end
end
