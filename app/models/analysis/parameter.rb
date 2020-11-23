class Analysis
  class Parameter < ApplicationRecord
    MAX_FEATURES_LIST = %w[all sqrt log2].freeze
    DEFAULT_MIN_SAMPLES_LEAF = 1.freeze
    DEFAULT_MIN_SAMPLES_SPLIT = 2.freeze
    DEFAULT_NUM_TREE = 100.freeze

    belongs_to :analysis

    after_initialize if: :new_record? do |parameter|
      parameter.min_samples_leaf ||= DEFAULT_MIN_SAMPLES_LEAF
      parameter.min_samples_split ||= DEFAULT_MIN_SAMPLES_SPLIT
      parameter.num_tree ||= DEFAULT_NUM_TREE
    end
  end
end
