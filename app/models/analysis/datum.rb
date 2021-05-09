class Analysis::Datum < ApplicationRecord
  validates :race_id,
            presence: {message: MESSAGE_ABSENT}

  belongs_to :analysis
end
