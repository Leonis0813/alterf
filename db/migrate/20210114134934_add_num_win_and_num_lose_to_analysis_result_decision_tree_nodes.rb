class AddNumWinAndNumLoseToAnalysisResultDecisionTreeNodes < ActiveRecord::Migration[5.0]
  def change
    change_table :analysis_result_decision_tree_nodes, bulk: true do |t|
      t.integer :num_win, after: :threshold
      t.integer :num_lose, after: :num_win
    end
  end
end
