class ChangeEvaluationDataToEvaluationRaces < ActiveRecord::Migration[6.1]
  def change
    rename_table :evaluation_data, :evaluation_races
  end
end
