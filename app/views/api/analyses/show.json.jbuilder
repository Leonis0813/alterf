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
    :max_leaf_nodes,
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
  json.decision_trees do
    json.array!(@analysis.result.decision_trees) do |decision_tree|
      json.(decision_tree, :tree_id)
      json.nodes do
        json.array!(decision_tree.nodes) do |node|
          json.(node, :node_id, :node_type, :group, :feature_name, :threshold, :num_win, :num_lose)
          json.parent_node_id node.parent&.node_id
        end
      end
    end
  end
end
