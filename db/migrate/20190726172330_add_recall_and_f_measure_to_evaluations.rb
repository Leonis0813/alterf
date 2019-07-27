class AddRecallAndFMeasureToEvaluations < ActiveRecord::Migration
  def change
    change_table :evaluations, bulk: true do |t|
      t.float :recall, after: :precision
      t.float :f_measure, after: :recall
    end
  end
end
