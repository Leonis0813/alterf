class Prediction < ActiveRecord::Base
  validates :model, :test_data, :state,
            presence: {message: 'absent'}
  validates :state,
            inclusion: {in: %w[processing completed error], message: 'invalid'}

  has_many :results, as: :predictable, dependent: :destroy
end
