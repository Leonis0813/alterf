class AddWonToPredictionResults < ActiveRecord::Migration
  def change
    add_column :prediction_results,
               :won,
               :boolean,
               null: false, default: false, after: :number
  end
end
