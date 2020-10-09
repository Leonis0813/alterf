json.(
  @analysis,
  :analysis_id,
  :num_data,
  :num_feature,
  :num_entry,
  :state,
  :performed_at,
)
json.parameter do
  json.(
    @analysis.parameter,
    :max_depth,
    :max_features,
    :min_leaf_nodes,
    :min_samples_leaf,
    :min_samples_split,
    :num_tree,
  )
end
json.result do
  json.importances do
    json.array!(@analysis.result.importances) do |importance|
      json.(importance, :feature_name, :value)
    end
  end
end
