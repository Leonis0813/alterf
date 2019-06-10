class Evaluation
  class Data < ActiveRecord::Base
    validates :race_name, :race_url, :ground_truth,
              presence: {message: 'absent'}
    validates :ground_truth,
              numericality: {only_integer: true, greater_than: 0, message: 'invalid'}

    belongs_to :evaluation
    has_many :prediction_results,
             class_name: Prediction::Result.name,
             as: :predictable,
             dependent: :destroy
  end
end
