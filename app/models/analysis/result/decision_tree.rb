class Analysis
  class Result
    class DecisionTree < ApplicationRecord
      validates :tree_id,
                presence: {message: MESSAGE_ABSENT}
      validates :tree_id,
                numericality: {
                  only_integer: true,
                  greater_than_or_equal_to: 0,
                  message: MESSAGE_INVALID,
                },
                allow_nil: true
      validates :tree_id,
                uniqueness: {scope: 'analysis_result_id', message: MESSAGE_DUPLICATED}

      belongs_to :result
      has_many :nodes,
               foreign_key: 'analysis_result_decision_tree_id',
               dependent: :destroy,
               inverse_of: :decision_tree
    end
  end
end
