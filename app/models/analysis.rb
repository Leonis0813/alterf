class Analysis < ApplicationRecord
  validates :analysis_id, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :analysis_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :num_feature,
            numericality: {
              only_integer: true,
              greater_than: 0,
              message: MESSAGE_INVALID,
            },
            allow_nil: true
  validates :state,
            inclusion: {in: STATE_LIST, message: MESSAGE_INVALID},
            allow_nil: true

  has_one :parameter, dependent: :destroy
  has_one :result, dependent: :destroy
  has_many :predictions, dependent: :destroy
  has_many :evaluations, dependent: :destroy

  after_initialize if: :new_record? do |analysis|
    analysis.analysis_id = SecureRandom.hex
    analysis.state = DEFAULT_STATE
  end
end
