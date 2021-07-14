class Analysis
  class Result
    class DecisionTree < ApplicationRecord
      validates :decision_tree_id,
                presence: {message: MESSAGE_ABSENT}
      validates :decision_tree_id,
                format: {with: /\A[0-9a-f]{6}\z/, message: MESSAGE_INVALID},
                allow_nil: true
      validates :decision_tree_id,
                uniqueness: {scope: 'analysis_result_id', message: MESSAGE_DUPLICATED}

      belongs_to :result,
                 foreign_key: 'analysis_result_id',
                 inverse_of: :decision_trees
      has_many :nodes,
               foreign_key: 'analysis_result_decision_tree_id',
               dependent: :destroy,
               inverse_of: :decision_tree

      def import!(index)
        output_dir = Rails.root.join('tmp/files/analyses', result.analysis.id.to_s)
        tree_file = File.join(output_dir, "tree_#{index}.yml")

        attributes = YAML.load_file(tree_file)['nodes'].map do |node_attribute|
          node_attribute.merge(timestamp)
        end
        nodes.insert_all!(attributes)
      end
    end
  end
end
