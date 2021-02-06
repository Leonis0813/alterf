from sklearn.ensemble import RandomForestClassifier
import analysis_util as util
import mysql.connector as mysql
import numpy as np
import os
import pandas as pd
import pickle
import sys
import yaml

args = sys.argv
analysis_id = args[1]

workdir = os.path.dirname(os.path.abspath(args[0]))
outputdir = workdir + '/../tmp/files/analyses/' + analysis_id
config = yaml.load(open(workdir + '/../config/settings.yml', 'r+'))
parameter = yaml.load(open(outputdir + '/parameter.yml', 'r+'))

def normalize_racewise_feature(group):
  features = group[config['analysis']['racewise_features']]
  features['horse_average_prize_money'] = features['horse_average_prize_money'].astype(float)
  features['jockey_average_prize_money'] = features['jockey_average_prize_money'].astype(float)
  unnormalizable_feature_names = features.loc[:, features.max() == features.min()].columns
  normalizable_feature_names = np.setdiff1d(
    config['analysis']['racewise_features'],
    unnormalizable_feature_names
  )
  features = features[normalizable_feature_names]
  normalized = (features - features.min()) / (features.max() - features.min())

  for name in unnormalizable_feature_names:
    normalized[name] = 0.0

  for name in normalizable_feature_names:
    group[name] = normalized[name]

  return group

connection = mysql.connect(
  host = config['mysql']['host'],
  user = config['mysql']['user'],
  password = config['mysql']['password'],
  database = config['mysql']['database'],
)
cursor = connection.cursor(dictionary=True)

cursor.execute('SELECT race_id FROM features WHERE won = 1')
race_ids = pd.DataFrame(cursor.fetchall())['race_id']

if (len(race_ids) >= parameter['num_data'] / 2):
  race_ids = np.random.choice(race_ids, int(parameter['num_data'] / 2), replace=False)

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

columns = feature.columns.to_list()
columns.remove('race_id')
columns.remove('number')
columns.insert(0, 'number')
columns.insert(0, 'race_id')
feature[columns].sort_values(['race_id', 'number']).to_csv(outputdir + '/feature.csv', index=False)
feature = feature.groupby('race_id').apply(normalize_racewise_feature)
feature = feature.dropna()

positive = feature[feature['won'] == 1]
negative = feature[feature['won'] == 0].sample(n=len(positive))
training_data = pd.concat([positive, negative])

columns = training_data.columns.to_list()
columns.remove('race_id')
columns.remove('number')
columns.insert(0, 'number')
columns.insert(0, 'race_id')
training_data[columns].sort_values(['race_id', 'number']).to_csv(outputdir + '/training_data.csv', index=False)
training_data = training_data.drop('race_id', axis=1)

classifier = RandomForestClassifier(
  max_depth=parameter['max_depth'],
  max_features=parameter['max_features'],
  max_leaf_nodes=parameter['max_leaf_nodes'],
  min_samples_leaf=parameter['min_samples_leaf'],
  min_samples_split=parameter['min_samples_split'],
  n_estimators=parameter['num_tree'],
  random_state=0
)
classifier.fit(training_data.drop('won', axis=1), training_data['won'])

file = open(outputdir + '/metadata.yml', 'w+')
importance_values = classifier.feature_importances_.astype(type('float', (float,), {}))
importance = {}
for i in range(len(training_data.columns) - 1):
  importance[training_data.columns[i]] = importance_values[i]

metadata = {
  'num_data': {
    'positive': len(positive),
    'negative': len(negative)
  },
  'num_tree': parameter['num_tree'],
  'num_feature': classifier.n_features_,
  'importance': importance
}
file.write(yaml.dump(metadata))

pickle.dump(classifier, open(outputdir + '/model.rf', 'wb'))
util.output_tree(classifier, training_data, outputdir)
