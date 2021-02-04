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
                 inverse_of: :decision_tree
      has_many :nodes,
               foreign_key: 'analysis_result_decision_tree_id',
               dependent: :destroy,
               inverse_of: :decision_tree

      def import!
        output_dir = Rails.root.join('tmp', 'files', 'analyses', result.analysis.id.to_s)
        tree_file = File.join(output_dir, "tree_#{tree_id}.yml")

        YAML.load_file(tree_file)['nodes'].each do |node_attribute|
          parent = nodes.reload.find_by(node_id: node_attribute['parent_id'])
          nodes.create!(node_attribute.except('parent_id').merge(parent: parent))
        end
      end
    end
  end
end
