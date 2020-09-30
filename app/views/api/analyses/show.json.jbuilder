json.(@analysis, :analysis_id, :num_data, :num_tree, :num_feature, :num_entry, :state, :performed_at)
json.result do
  json.importances do
    json.array!(@analysis.result.importances) do |importance|
      json.(importance, :feature_name, :value)
    end
  end
end
