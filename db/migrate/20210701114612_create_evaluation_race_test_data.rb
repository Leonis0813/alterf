class CreateEvaluationRaceTestData < ActiveRecord::Migration[6.1]
  def change
    create_table :evaluation_race_test_data do |t|
      t.references :evaluation_race, null: false
      t.integer :number, null: false
      t.boolean :prediction_result
      t.timestamps null: false

      t.index %i[evaluation_race_id number], unique: true
    end
  end
end
