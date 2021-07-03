class Evaluation::Race::TestDatum < ApplicationRecord
  validates :number,
            presence: {message: MESSAGE_ABSENT}
  validates :number,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true

  belongs_to :race,
             foreign_key: 'evaluation_race_id',
             inverse_of: :test_data

  scope :feature, lambda do
    Denebola::Feature.select(*Denebola::Feature::NAMES)
                     .find_by(race_id: race.race_id, number: number)
  end
end
