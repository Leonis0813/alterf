class AddAnalysisIdToEvaluations < ActiveRecord::Migration[5.0]
  def change
    add_reference :evaluations, :analysis, first: true
  end
end
