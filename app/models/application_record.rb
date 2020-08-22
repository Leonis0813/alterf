class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  MESSAGE_ABSENT = 'absent_parameter'.freeze
  MESSAGE_INVALID = 'invalid_parameter'.freeze

  STATE_WAITING = 'waiting'.freeze
  STATE_PROCESSING = 'processing'.freeze
  STATE_COMPLETED = 'completed'.freeze
  STATE_ERROR = 'error'.freeze
  DEFAULT_STATE = STATE_WAITING
  STATE_LIST = [
    STATE_WAITING,
    STATE_PROCESSING,
    STATE_COMPLETED,
    STATE_ERROR,
  ].freeze
end
