json.importances do
  json.array!(@importances) do |importance|
    json.(importance, :feature_name, :value)
  end
end
