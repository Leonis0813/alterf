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

  after_update do
    updated_attribute = slice(:analysis_id, :state, :num_feature)
    updated_attribute['performed_at'] = performed_at&.strftime('%Y/%m/%d %T')
    ActionCable.server.broadcast('analysis', updated_attribute.compact)
  end

  def start!
    update!(state: STATE_PROCESSING, performed_at: Time.zone.now)
    FileUtils.rm_rf(tmp_dir)
    FileUtils.mkdir_p(tmp_dir)
  end

  def complete!
    update!(state: STATE_COMPLETED, completed_at: Time.zone.now)
  end

  def dump_parameter
    param = parameter.attributes.merge('env' => Rails.env.to_s)
    param.merge!(slice(:data_source, :num_data))
    param.except!('id', 'analysis_id', 'created_at', 'updated_at')
    param['num_entry'] = num_entry if num_entry

    File.open(File.join(tmp_dir, 'parameter.yml'), 'w') {|file| YAML.dump(param, file) }
  end

  def dump_training_data
    return unless data_source == DATA_SOURCE_FILE

    File.open(File.join(tmp_dir, 'training_data.txt'), 'w') do |file|
      analysis.data.each {|datum| file.puts(datum.race_id) }
    end
  end

  def import_data!
    return unless data_source == DATA_SOURCE_RANDOM

    race_ids = File.read(File.join(tmp_dir, 'race_list.txt')).lines.map(&:chomp)
    race_ids.each {|race_id| data.create!(race_id: race_id) }
  end

  private

  def tmp_dir
    Rails.root.join('tmp', 'files', 'analyses', id.to_s)
  end
end
