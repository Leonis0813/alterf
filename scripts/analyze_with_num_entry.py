from sklearn.ensemble import RandomForestClassifier
import mysql.connector as mysql
import numpy as np
import os
import pandas as pd
import pickle
import sys
import yaml

args = sys.argv
analysis_id = args[1]
num_training_data = int(args[2])
ntree = int(args[3])
nentry = int(args[4])

workdir = os.path.dirname(os.path.abspath(args[0]))
outputdir = workdir + '/../tmp/files/' + analysis_id
config = yaml.load(open(workdir + '/../config/settings.yml', 'r+'))

def create_race_feature(group):
  group = group.sort_values('number')
  feature = pd.DataFrame()

  for name in config['analysis']['feature']['races']:
    feature[name] = group[name].head(1)

  for i in range(nentry):
    for name in config['analysis']['feature']['horses']:
      feature[name + '_' + str(i)] = group.iloc[i][name]

    for name in config['analysis']['feature']['jockeys']:
      feature[name + '_' + str(i)] = group.iloc[i][name]

    feature['won_' + str(i)] = group.iloc[i]['won']

  wons = pd.Series()
  for i in range(nentry):
    wons = wons.append(feature['won_' + str(i)], ignore_index=True)
    feature['won'] = wons.where(wons == 1).first_valid_index()

  for i in range(nentry):
    feature = feature.drop('won_' + str(i), axis=1)

  return feature

connection = mysql.connect(
  host = config['mysql']['host'],
  user = config['mysql']['user'],
  password = config['mysql']['password'],
  database = config['mysql']['database'],
)
cursor = connection.cursor(dictionary=True)

sql = 'SELECT race_id, COUNT(*) as nentry' \
  + ' FROM features' \
  + ' GROUP BY race_id HAVING nentry = ' + str(nentry)
cursor.execute(sql)
race_ids = pd.DataFrame(cursor.fetchall())['race_id']
if (len(race_ids) > num_training_data):
  race_ids = np.random.choice(race_ids, int(num_training_data), replace=False)

cursor.execute('desc features')
fields = pd.DataFrame(cursor.fetchall())['Field']
non_feature_names = ['id', 'horse_id', 'created_at', 'updated_at']
feature_names = np.setdiff1d(fields, non_feature_names)

sql = 'SELECT ' + ','.join(feature_names) \
  + ' FROM features WHERE race_id IN (' + ','.join(race_ids) + ')'
cursor.execute(sql)
feature = pd.DataFrame(cursor.fetchall())
mapping = yaml.load(open(workdir + '/mapping.yml', 'r+'))
for name in mapping:
  feature[name] = feature[name].map(mapping[name]).astype(int)

feature.to_csv(outputdir + '/feature.csv', index=False)
training_data = feature.groupby('race_id').apply(create_race_feature)
training_data.to_csv(outputdir + '/training_data.csv', index=False)

classifier = RandomForestClassifier(n_estimators=ntree, random_state=0)
classifier.fit(training_data.drop('won', axis=1), training_data['won'])

file = open(outputdir + '/metadata.yml', 'w+')
importance_values = classifier.feature_importances_.astype(type('float', (float,), {}))
importance = {}
for i in range(len(training_data.columns) - 1):
  importance[training_data.columns[i]] = importance_values[i]

metadata = {
  'num_training_data': len(training_data),
  'num_tree': ntree,
  'num_feature': classifier.n_features_,
  'importance': importance
}
file.write(yaml.dump(metadata))

pickle.dump(classifier, open(outputdir + '/model.rf', 'wb'))

feature_names = training_data.columns
for i, estimator in enumerate(classifier.estimators_):
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
