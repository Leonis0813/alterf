json.evaluations do
  json.array!(@evaluations) do |evaluation|
    json.(evaluation, :evaluation_id, :performed_at, :model, :data_source, :num_data, :state, :precision, :recall, :f_measure)
    json.data do
      json.array!(evaluation.data) do |data|
        json.(data, :race_id, :race_name, :race_url)
        json.predictions_results(data.prediction_results, :number, :won)
        json.(data, :ground_truth)
      end
    end
  end
end
