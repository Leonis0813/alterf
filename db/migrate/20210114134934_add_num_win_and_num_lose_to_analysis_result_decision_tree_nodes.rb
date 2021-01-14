class AddNumWinAndNumLoseToAnalysisResultDecisionTreeNodes < ActiveRecord::Migration[5.0]
  def change
    add_column :analysis_result_decision_tree_nodes, :num_win, :integer,
               after: :threshold
    add_column :analysis_result_decision_tree_nodes, :num_lose, :integer,
               after: :num_win
  end
end
