class Analysis::Datum < ApplicationRecord
  validates :race_id,
            presence: {message: MESSAGE_ABSENT}

  belongs_to :analysis

  def copy_attributes
    slice(:race_id)
  end
end
