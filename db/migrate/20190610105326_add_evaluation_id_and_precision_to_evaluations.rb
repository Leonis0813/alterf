class AddEvaluationIdAndPrecisionToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :evaluation_id, :string, null: false, after: :id
    add_column :evaluations, :precision, :float, after: :state
  end
end
