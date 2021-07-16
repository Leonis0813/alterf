class ChangeDatatypeDecisionTreeIdOfAnalysisResultDecisionTrees < ActiveRecord::Migration[6.1]
  def up
    change_column :analysis_result_decision_trees, :decision_tree_id, :string,
                  limit: 6,
                  null: false
  end

  def down
    change_column :analysis_result_decision_trees, :decision_tree_id, :integer,
                  numm: false
  end
end
