class Prediction
  class Result < ApplicationRecord
    validates :number,
              presence: {message: MESSAGE_ABSENT}
    validates :number,
              numericality: {
                only_integer: true,
                greater_than: 0,
                message: MESSAGE_INVALID,
              },
              allow_nil: true
    validates :won,
              inclusion: {in: [true, false], message: MESSAGE_INVALID}

    belongs_to :predictable, polymorphic: true

    scope :won, -> { where(won: true) }
    scope :lost, -> { where(won: false) }
  end
end
