class Analysis
  class Parameter < ApplicationRecord
    MAX_FEATURES_LIST = %w[all sqrt log2].freeze

    validates :num_tree, :min_samples_split, :min_samples_leaf, :max_features,
              presence: {message: MESSAGE_ABSENT}
    validates :num_tree, :min_samples_split, :min_samples_leaf,
              numericality: {
                only_integer: true,
                greater_than: 0,
                message: MESSAGE_INVALID,
              },
              allow_nil: true
    validates :max_features,
              inclusion: {in: MAX_FEATURES_LIST, message: MESSAGE_INVALID},
              allow_nil: true

    belongs_to :analysis
  end
end
