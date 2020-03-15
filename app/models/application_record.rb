class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  DEFAULT_STATE = 'waiting'.freeze
  STATE_LIST = [
    DEFAULT_STATE,
    'processing',
    'completed',
    'error',
  ].freeze
end
