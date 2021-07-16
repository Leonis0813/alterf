class RenameTreeIdColumnToAnalysisResultDecisionTrees < ActiveRecord::Migration[6.1]
  def change
    rename_column :analysis_result_decision_trees, :tree_id, :decision_tree_id
  end
end
