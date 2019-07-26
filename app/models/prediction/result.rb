class Prediction
  class Result < ActiveRecord::Base
    validates :number,
              presence: {message: 'absent'},
              numericality: {only_integer: true, greater_than: 0, message: 'invalid'}
    validates :won,
              inclusion: {in: [true, false], message: 'invalid'}

    belongs_to :predictable, polymorphic: true

    scope :won, -> { where(won: true) }
    scope :lost, -> { where(won: false) }
  end
end
