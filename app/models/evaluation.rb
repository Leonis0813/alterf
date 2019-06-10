class Evaluation < ActiveRecord::Base
  validates :state, inclusion: {in: %w[processing completed error]}

  has_many :data, dependent: :destroy
end
