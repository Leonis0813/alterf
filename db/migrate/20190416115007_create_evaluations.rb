class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.string :model
      t.string :state
      t.timestamps null: false
    end
  end
end
