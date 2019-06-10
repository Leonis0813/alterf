class CreateEvaluationData < ActiveRecord::Migration
  def change
    create_table :evaluation_data do |t|
      t.references :evaluation, null: false
      t.string :race_name, null: false
      t.string :race_url, null: false
      t.integer :ground_truth, null: false
      t.timestamp null: false
    end
  end
end
