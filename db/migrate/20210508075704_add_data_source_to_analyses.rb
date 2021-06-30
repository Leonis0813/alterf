class AddDataSourceToAnalyses < ActiveRecord::Migration[6.1]
  def change
    add_column :analyses, :data_source, :string, after: :analysis_id
  end
end
