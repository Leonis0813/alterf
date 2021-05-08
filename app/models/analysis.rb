class Analysis < ApplicationRecord
  DATA_SOURCE_RANDOM = 'random'.freeze
  DATA_SOURCE_FILE = 'file'.freeze
  DATA_SOURCE_LIST = [
    DATA_SOURCE_RANDOM,
    DATA_SOURCE_FILE,
  ].freeze
  DATA_SOURCE_DEFAULT = DATA_SOURCE_RANDOM

  validates :analysis_id, :data_source, :state,
            presence: {message: MESSAGE_ABSENT}
  validates :analysis_id,
            format: {with: /\A[0-9a-f]{32}\z/, message: MESSAGE_INVALID},
            allow_nil: true
  validates :data_source,
            inclusion: {in: DATA_SOURCE_LIST, message: MESSAGE_INVALID},
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
  has_many :data, dependent: :destroy
  has_one :result, dependent: :destroy
  has_many :predictions, dependent: :destroy
  has_many :evaluations, dependent: :destroy

  accepts_nested_attributes_for :parameter

  after_initialize if: :new_record? do |analysis|
    analysis.analysis_id = SecureRandom.hex
    analysis.state = DEFAULT_STATE
  end

  after_update do
    updated_attribute = slice(:analysis_id, :state, :num_feature)
    updated_attribute['performed_at'] = performed_at&.strftime('%Y/%m/%d %T')
    ActionCable.server.broadcast('analysis', updated_attribute.compact)
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
  end

  def complete!
    update!(state: STATE_COMPLETED, completed_at: Time.zone.now)
  end
end
