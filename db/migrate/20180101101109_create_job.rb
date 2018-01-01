class CreateJob < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :num_data
      t.integer :num_tree
      t.integer :num_feature
      t.string :state

      t.timestamp null: false
    end
  end
end
