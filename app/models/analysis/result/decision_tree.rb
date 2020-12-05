class Analysis
  class Result
    class DecisionTree < ApplicationRecord
      belongs_to :result
      has_many :nodes,
               foreign_key: 'analysis_result_decision_tree_id',
               dependent: :destroy,
               inverse_of: :decision_tree
    end
  end
end
