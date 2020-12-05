class CreateAnalysisResultDecisionTreeNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :analysis_result_decision_tree_nodes do |t|
      t.references :analysis_result_decision_tree,
                   null: false,
                   index: {name: 'index_analysis_result_decision_tree_id_on_nodes'}
      t.integer :node_id, null: false
      t.string :node_type, null: false
      t.string :group
      t.string :feature_name, null: false
      t.float :threshold, null: false
      t.integer :parent_id
      t.timestamps null: false
    end

    add_foreign_key :analysis_result_decision_tree_nodes,
                    :analysis_result_decision_tree_nodes,
                    column: :parent_id
  end
end
