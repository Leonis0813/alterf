class AddPredictionIdToPredictions < ActiveRecord::Migration[5.0]
  def change
    add_column :predictions, :prediction_id, :string, after: :id

    Prediction.where(prediction_id: nil).each do |prediction|
      prediction.update!(prediction_id: SecureRandom.hex)
    end

    add_index :predictions, :prediction_id, unique: true
  end
end
