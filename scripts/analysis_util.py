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

    for i in range(len(lefts)):
      node_type = 'leaf'
      if i == 0:
        node_type = 'root'
      elif lefts[i] != rights[i]:
        node_type = 'split'

      node = {
        'node_id': i,
        'node_type': node_type,
        'feature_name': None if feature_ids[i] == -2 else feature_names[feature_ids[i]],
        'threshold': None if thresholds[i] == -2.0 else thresholds[i],
        'parent_id': None,
      }
      nodes.append(node)

    for i, left in enumerate(lefts):
      if left != -1:
        nodes[left]['parent_id'] = i
        nodes[left]['group'] = 'less'

    for i, right in enumerate(rights):
      if right != -1:
        nodes[right]['parent_id'] = i
        nodes[right]['group'] = 'greater'

    file.write(yaml.dump({'nodes': nodes}, default_flow_style=False, sort_keys=False))
