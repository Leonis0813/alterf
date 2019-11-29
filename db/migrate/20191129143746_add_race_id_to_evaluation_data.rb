class AddRaceIdToEvaluationData < ActiveRecord::Migration[5.0]
  def change
    add_column :evaluation_data, :race_id, :string, null: false, after: :evaluation_id
  end
end
