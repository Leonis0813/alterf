class Analysis
  class Datum < ApplicationRecord
    validate :check_race

    belongs_to :analysis

    private

    def check_race
      errors.add(:race_id, MESSAGE_ABSENT) unless race_id

      unless Denebola::Race.exists?(:race_id => race_id)
        errors.add(:race_id, MESSAGE_INVALID)
      end
    end
  end
end
