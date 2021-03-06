class Analysis < ApplicationRecord
  DATA_SOURCE_RANDOM = 'random'.freeze
  DATA_SOURCE_FILE = 'file'.freeze
  DATA_SOURCE_LIST = [
    DATA_SOURCE_RANDOM,
    DATA_SOURCE_FILE,
  ].freeze
  DEFAULT_DATA_SOURCE = DATA_SOURCE_RANDOM

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
    analysis.data_source ||= DEFAULT_DATA_SOURCE
    analysis.state = DEFAULT_STATE
  end

  after_create do
    ActionCable.server.broadcast('analysis', slice(:analysis_id))
  end

  after_update do
    updated_attribute = slice(:analysis_id, :state, :num_feature, :num_data)
    updated_attribute['performed_at'] = performed_at&.strftime('%Y/%m/%d %T')
    ActionCable.server.broadcast('analysis', updated_attribute.compact)
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
  end

  def complete!
    update!(state: STATE_COMPLETED, completed_at: Time.zone.now)
  end

  def dump_parameter
    param = parameter.attributes.merge('env' => Rails.env.to_s)
    param.merge!(slice(:data_source, :num_data))
    param.except!('id', 'analysis_id', 'created_at', 'updated_at')

    File.open(File.join(tmp_dir, 'parameter.yml'), 'w') {|file| YAML.dump(param, file) }
  end

  def import_data!
    race_ids = File.read(File.join(tmp_dir, 'race_list.txt')).lines.map(&:chomp)
    race_ids.each {|race_id| data.create!(race_id: race_id) }
  end

  def copy
    analysis = self.class.new(copy_attributes)
    analysis.build_parameter(parameter.copy_attributes)
    analysis.build_result
    data.each {|datum| analysis.data.build(datum.copy_attributes) }
    analysis
  end

  private

  def tmp_dir
    Rails.root.join('tmp/files/analyses', id.to_s)
  end

  def copy_attributes
    slice(:data_source, :num_data)
  end
end
