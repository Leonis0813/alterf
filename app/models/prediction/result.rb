class Prediction
  class Result < ActiveRecord::Base
    validates :number,
              presence: {message: 'absent'},
              numericality: {only_integer: true, greater_than: 0, message: 'invalid'}

    belongs_to :predictable, polymorphic: true
  end
end
