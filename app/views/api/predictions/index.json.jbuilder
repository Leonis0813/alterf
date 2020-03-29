json.predictions do
  json.array!(@predictions) do |prediction|
    json.(prediction, :prediction_id, :performed_at, :model, :test_data, :state)
    json.results(prediction.results, :number, :won)
  end
end
