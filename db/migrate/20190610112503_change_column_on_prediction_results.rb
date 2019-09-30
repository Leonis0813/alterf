class ChangeColumnOnPredictionResults < ActiveRecord::Migration[4.2]
  def up
    change_table :prediction_results, bulk: true do |t|
      t.remove :prediction_id
      t.integer :predictable_id, null: false, after: :id
      t.string :predictable_type, null: false, after: :predictable_id
    end
  end

  def down
    change_table :prediction_results, bulk: true do |t|
      t.integer :prediction_id, after: :id
      t.remove :predictable_id
      t.remove :predictable_type
    end
  end
end
