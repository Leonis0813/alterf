class CreateAnalysisResults < ActiveRecord::Migration[5.0]
  def change
    create_table :analysis_results do |t|
      t.references :analysis, null: false, index: {unique: true}
      t.timestamps null: false
    end
  end
end
