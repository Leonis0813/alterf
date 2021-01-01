class CreateAnalysisResultDecisionTrees < ActiveRecord::Migration[5.0]
  def change
    create_table :analysis_result_decision_trees do |t|
      t.references :analysis_result, null: false
      t.integer :tree_id, null: false
      t.timestamps null: false

      t.index %i[analysis_result_id tree_id],
              unique: true,
              name: 'index_unique_analysis_result_id_tree_id_on_decision_trees'
    end
  end
end
