class AddPerformedAtToJobTables < ActiveRecord::Migration[5.0]
  def change
    add_column :analyses, :performed_at, :datetime, after: :state
    add_column :evaluations, :performed_at, :datetime, after: :f_measure
    add_column :predictions, :performed_at, :datetime, after: :state
  end
end
