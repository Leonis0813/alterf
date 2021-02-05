class RemoveForeignKeyParentId < ActiveRecord::Migration[6.1]
  def up
    remove_foreign_key :analysis_result_decision_tree_nodes, column: :parent_id
    remove_index :analysis_result_decision_tree_nodes, :parent_id
  end

  def down
    add_foreign_key :analysis_result_decision_tree_nodes,
                    :analysis_result_decision_tree_nodes,
                    column: :parent_id
  end
end
