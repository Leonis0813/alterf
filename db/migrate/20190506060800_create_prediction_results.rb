class CreatePredictionResults < ActiveRecord::Migration
  def change
    create_table :prediction_results do |t|
      t.references :prediction
      t.integer :number, null: false

      t.timestamps null: false
    end
  end
end
