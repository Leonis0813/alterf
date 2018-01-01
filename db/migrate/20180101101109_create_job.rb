class CreateJob < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :num_data, :null => false
      t.integer :num_tree, :null => false
      t.integer :num_feature, :null => false
      t.string :state, :null => false

      t.timestamps null: false
    end
  end
end
