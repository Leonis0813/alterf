class Prediction
  class Result < ActiveRecord::Base
    validates :number, numericality: {only_integer: true, greater_than: 0}

    belongs_to :prediction
  end
end
