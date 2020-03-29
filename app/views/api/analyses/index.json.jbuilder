json.analyses do
  json.array!(@analyses) do |analysis|
    json.(analysis, :analysis_id, :performed_at, :num_data, :num_tree, :num_feature, :num_entry, :state)
  end
end
