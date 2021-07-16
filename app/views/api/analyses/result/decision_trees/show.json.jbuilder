json.(@decision_tree, :decision_tree_id)
json.nodes do
  json.array!(@decision_tree.nodes) do |node|
    json.(node, :node_id, :node_type, :group, :feature_name, :threshold, :num_win, :num_lose)
    json.parent_node_id node.parent_id
  end
end
