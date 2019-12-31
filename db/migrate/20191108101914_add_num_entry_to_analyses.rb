class AddNumEntryToAnalyses < ActiveRecord::Migration[5.0]
  def change
    add_column :analyses, :num_entry, :integer, after: :num_feature
  end
end
