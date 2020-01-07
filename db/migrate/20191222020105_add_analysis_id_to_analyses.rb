class AddAnalysisIdToAnalyses < ActiveRecord::Migration[5.0]
  def change
    add_column :analyses, :analysis_id, :string, null: false, default: '', first: true
  end
end
