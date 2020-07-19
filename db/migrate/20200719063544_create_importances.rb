class CreateImportances < ActiveRecord::Migration[5.0]
  def change
    create_table :importances do |t|
      t.references :analysis_result, null: false
      t.string :feature_name, null: false
      t.float :value, null: false
      t.timestamps null: false

      t.index %i[analysis_result_id feature_name], unique: true
    end
  end
end
