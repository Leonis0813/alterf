class AddEvaluationIdAndPrecisionToEvaluations < ActiveRecord::Migration
  def change
    change_table :evaluations, bulk: true do |t|
      t.string :evaluation_id, null: false, after: :id
      t.float :precision, after: :state
    end
  end
end
