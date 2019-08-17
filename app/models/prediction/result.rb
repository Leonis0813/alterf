class Prediction
  class Result < ApplicationRecord
    validates :number,
              presence: {message: 'absent'}
    validates :number,
              numericality: {only_integer: true, greater_than: 0, message: 'invalid'},
              allow_nil: true
    validates :won,
              inclusion: {in: [true, false], message: 'invalid'}

    belongs_to :predictable, polymorphic: true

    scope :won, -> { where(won: true) }
    scope :lost, -> { where(won: false) }
  end
end
