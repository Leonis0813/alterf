class Prediction < ActiveRecord::Base
  validates :state, inclusion: {in: %w[processing completed]}

  has_many :results, dependent: :destroy
end
