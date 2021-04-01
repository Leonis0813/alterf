class AddCompletedAtToAnalysesAndEvaluations < ActiveRecord::Migration[6.1]
  def change
    add_column :analyses, :completed_at, :datetime, after: :performed_at
    add_column :evaluations, :completed_at, :datetime, after: :performed_at
  end
end
