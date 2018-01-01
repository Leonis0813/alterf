class CreateAnalyses < ActiveRecord::Migration
  def change
    create_table :analyses do |t|
      t.integer :num_data
      t.integer :num_tree
      t.integer :num_feature
      t.string :state
      t.timestamps null: false
    end
  end
end
