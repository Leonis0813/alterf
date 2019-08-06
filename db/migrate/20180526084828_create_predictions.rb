class CreatePredictions < ActiveRecord::Migration[4.2]
  def change
    create_table :predictions do |t|
      t.string :model
      t.string :test_data
      t.string :state
      t.timestamps null: false
    end
  end
end
