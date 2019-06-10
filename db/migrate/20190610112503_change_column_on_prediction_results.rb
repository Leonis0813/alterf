class ChangeColumnOnPredictionResults < ActiveRecord::Migration
  def change
    change_table :prediction_results, bulk: true do |t|
      t.remove :prediction_id
      t.integer :predictable_id, null: false, after: :id
      t.string  :predictable_type, null: false, after: :predictable_id
    end
  end
end
