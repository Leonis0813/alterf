class AddAnalysisIdToPredictions < ActiveRecord::Migration[6.1]
  def change
    add_reference :predictions, :analysis, first: true
  end
end
