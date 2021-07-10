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

  scope :won, -> { where(prediction_result: true) }
  scope :lost, -> { where(prediction_result: false) }

  def order
    order = Denebola::Race.find_by(race_id: race.race_id)
                          .entries
                          .find_by(number: number)
                          .order
    order.match?(/\A\d+\z/) ? order.to_i : order
  end

  def feature
    Denebola::Feature.select(*(Denebola::Feature::NAMES - %w[order]))
                     .find_by(race_id: race.race_id, number: number)
  end
end
