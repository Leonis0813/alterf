class CreateAnalysisData < ActiveRecord::Migration[6.1]
  def change
    create_table :analysis_data do |t|
      t.references :analysis, null: false
      t.string :race_id, null: false
      t.timestamps null: false

      t.index %i[analysis_id race_id], unique: true
    end
  end
end
