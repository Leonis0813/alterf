import yaml

def output_tree(estimators, training_data, outputdir):
  feature_names = training_data.columns
  for i, estimator in enumerate(estimators):
    file = open(outputdir + '/tree_' + str(i) + '.yml', 'w+')
    nodes = []
    lefts = estimator.tree_.children_left.astype(type('int', (float,), {}))
    rights = estimator.tree_.children_right.astype(type('int', (float,), {}))
    feature_ids = estimator.tree_.feature
    thresholds = estimator.tree_.threshold.astype(type('float', (float,), {}))

    stack = [(0, -1, -1, 'root')]
    while len(stack) > 0:
      node_id, parent_depth, parent_node_id, direction = stack.pop()
      node = {
        'node_id': node_id,
        'depth': parent_depth + 1,
      }
      if node_id != 0:
        node['parent_node_id'] = parent_node_id
        node['direction'] = direction

      if (lefts[node_id] != rights[node_id]):
        node['type'] = 'split'
        node['feature'] = feature_names[feature_ids[node_id]]
        node['threshold'] = thresholds[node_id]
        stack.append((lefts[node_id], parent_depth + 1, node_id, 'left'))
        stack.append((rights[node_id], parent_depth + 1, node_id, 'right'))
      else:
        node['type'] = 'leaf'

      nodes.append(node)

    max_depth = max([node.get('depth') for node in nodes])
    for depth in range(1, max_depth + 1):
      target_nodes = [node for node in nodes if node['depth'] == depth]

      for left_node in [node for node in target_nodes if node['direction'] == 'left']:
        parent_node = [node for node in nodes if node['node_id'] == left_node['parent_node_id']][0]
        left_node.pop('parent_node_id')
        parent_node['left'] = left_node
      for right_node in [node for node in target_nodes if node['direction'] == 'right']:
        parent_node = [node for node in nodes if node['node_id'] == right_node['parent_node_id']][0]
        right_node.pop('parent_node_id')
        parent_node['right'] = right_node

    file.write(yaml.dump(nodes[0], default_flow_style=False, sort_keys=False))
