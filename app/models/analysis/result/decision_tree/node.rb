class Analysis
  class Result
    class DecisionTree
      class Node < ApplicationRecord
        NODE_TYPE_LIST = %w[root split leaf].freeze
        GROUP_LIST = %w[less greater].freeze

        validates :node_id, :node_type,
                  presence: {message: MESSAGE_ABSENT}
        validates :node_id, :num_win, :num_lose,
                  numericality: {
                    only_integer: true,
                    greater_than_or_equal_to: 0,
                    message: MESSAGE_INVALID,
                  },
                  allow_nil: true
        validates :node_id,
                  uniqueness: {
                    scope: 'analysis_result_decision_tree_id',
                    message: MESSAGE_DUPLICATED,
                  }
        validates :node_type,
                  inclusion: {in: NODE_TYPE_LIST, message: MESSAGE_INVALID},
                  allow_nil: true
        validates :group,
                  inclusion: {in: GROUP_LIST, message: MESSAGE_INVALID},
                  allow_nil: true
        validates :threshold,
                  numericality: {message: MESSAGE_INVALID},
                  allow_nil: true

        belongs_to :decision_tree,
                   foreign_key: 'analysis_result_decision_tree_id'
        belongs_to :parent,
                   class_name: 'Analysis::Result::DecisionTree::Node',
                   inverse_of: :children
        has_many :children,
                 class_name: 'Analysis::Result::DecisionTree::Node',
                 foreign_key: 'parent_id',
                 dependent: :destroy,
                 inverse_of: :parent
      end
    end
  end
end
