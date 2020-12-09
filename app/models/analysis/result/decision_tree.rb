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

      def import!
        output_dir = Rails.root.join('tmp', 'files', 'analyses', result.analysis.id.to_s)
        tree_file = File.join(output_dir, "tree_#{tree_id}.yml")

        YAML.load_file(tree_file)['nodes'].each do |node|
          nodes.create!(
            node_id: node['node_id'],
            node_type: node['node_type'],
            group: node['group'],
            feature_name: node['feature_name'],
            threshold: node['threshold'],
            parent: nodes.find {|node| node.node_id == node['parent_id'] },
          )
        end
      end
    end
  end
end
