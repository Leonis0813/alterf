class CreateEvaluations < ActiveRecord::Migration[4.2]
  def change
    create_table :evaluations do |t|
      t.string :model
      t.string :state
      t.timestamps null: false
    end
  end
end
