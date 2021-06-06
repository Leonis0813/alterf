class RemoveNumEntryFromAnalyses < ActiveRecord::Migration[6.1]
  def up
    remove_column :analyses, :num_entry
  end

  def down
    add_column :analyses, :num_entry, :integer, after: :num_feature
  end
end
