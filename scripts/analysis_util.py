import yaml

def output_tree(classifier, training_data, outputdir):
  leaf_id_map = classifier.apply(training_data.drop('won', axis=1))

  feature_names = training_data.columns
  for i, estimator in enumerate(classifier.estimators_):
    file = open(outputdir + '/tree_' + str(i) + '.yml', 'w+')
    nodes = []

    lefts = estimator.tree_.children_left.astype(type('int', (float,), {}))
    rights = estimator.tree_.children_right.astype(type('int', (float,), {}))
    feature_ids = estimator.tree_.feature
    thresholds = estimator.tree_.threshold.astype(type('float', (float,), {}))
    leaf_ids = [l[i] for l in leaf_id_map]

    for node_id in range(len(lefts)):
      node_type = 'leaf'
      if node_id == 0:
        node_type = 'root'
      elif lefts[node_id] != rights[node_id]:
        node_type = 'split'

      num_win = None
      num_lose = None
      if node_type == 'leaf':
        num_win = 0
        num_lose = 0
        for data_id, won in enumerate(training_data['won']):
          if leaf_ids[data_id] == node_id:
            if won == 1:
              num_win += 1
            else:
              num_lose += 1

      feature_id = feature_ids[node_id]

      node = {
        'node_id': node_id,
        'node_type': node_type,
        'feature_name': None if feature_id == -2 else feature_names[feature_id],
        'threshold': None if thresholds[node_id] == -2.0 else thresholds[node_id],
        'num_win': num_win,
        'num_lose': num_lose,
        'parent_id': None,
      }
      nodes.append(node)

    nodes[0]['group'] = None

    for i, left in enumerate(lefts):
      if left != -1:
        nodes[left]['parent_id'] = i
        nodes[left]['group'] = 'less'

    for i, right in enumerate(rights):
      if right != -1:
        nodes[right]['parent_id'] = i
        nodes[right]['group'] = 'greater'

    file.write(yaml.dump({'nodes': nodes}, default_flow_style=False, sort_keys=False))
