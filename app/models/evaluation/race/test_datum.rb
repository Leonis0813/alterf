class Evaluation::Race::TestDatum < ApplicationRecord
  validates :number
            presence: {message: MESSAGE_ABSENT}
  validates :number,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true

  belongs_to :evaluation_race

  scope :feature, -> do
    Denebola::Feature.where(race_id: evaluation_race.race_id, number: number)
  end
end
