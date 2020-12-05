class Analysis
  class Result
    class DecisionTree
      class Node < ApplicationRecord
        belongs_to :decision_tree
        belongs_to :parent,
                   class_name: 'Analysis::Result::DecisionTree::Node',
                   foreign_key: 'parent_id'
        has_many :children,
                 class_name: 'Analysis::Result::DecisionTree::Node',
                 foreign_key: 'parent_id'
      end
    end
  end
end
