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

      belongs_to :result,
                 foreign_key: 'analysis_result_id',
                 inverse_of: :decision_trees
      has_many :nodes,
               foreign_key: 'analysis_result_decision_tree_id',
               dependent: :destroy,
               inverse_of: :decision_tree

      def import!
        output_dir = Rails.root.join('tmp', 'files', 'analyses', result.analysis.id.to_s)
        tree_file = File.join(output_dir, "tree_#{tree_id}.yml")

        attributes = YAML.load_file(tree_file)['nodes'].map do |node_attribute|
          node_attribute.merge(timestamp)
        end
        nodes.insert_all!(attributes)
      end
    end
  end
end
