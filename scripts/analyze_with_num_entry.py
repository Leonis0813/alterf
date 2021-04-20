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
config = yaml.safe_load(open(workdir + '/../config/settings.yml', 'r+'))
database = yaml.safe_load(open(workdir + '/../config/denebola/database.yml', 'r+'))
parameter = yaml.safe_load(open(outputdir + '/parameter.yml', 'r+'))

def create_race_feature(group):
  group = group.sort_values('number')
  feature = pd.DataFrame()

  for name in config['analysis']['feature']['races']:
    feature[name] = group[name].head(1)

  for i in range(parameter['num_entry']):
    for name in config['analysis']['feature']['horses']:
      feature[name + '_' + str(i)] = group.iloc[i][name]

    for name in config['analysis']['feature']['jockeys']:
      feature[name + '_' + str(i)] = group.iloc[i][name]

    feature['won_' + str(i)] = group.iloc[i]['won']

  wons = pd.Series()
  for i in range(parameter['num_entry']):
    wons = wons.append(feature['won_' + str(i)], ignore_index=True)
    feature['won'] = wons.where(wons == 1).first_valid_index()

  for i in range(parameter['num_entry']):
    feature = feature.drop('won_' + str(i), axis=1)

  feature['race_id'] = group.iloc[0]['race_id']

  return feature

connection = mysql.connect(
  host = database[parameter['env']]['host'],
  user = database[parameter['env']]['username'],
  password = database[parameter['env']]['password'],
  database = database[parameter['env']]['database'],
)
cursor = connection.cursor(dictionary=True)

sql = 'SELECT race_id, COUNT(*) as nentry' \
  + ' FROM features' \
  + ' GROUP BY race_id HAVING nentry = ' + str(parameter['num_entry'])
cursor.execute(sql)
race_ids = pd.DataFrame(cursor.fetchall())['race_id']
if (len(race_ids) > parameter['num_data']):
  race_ids = np.random.choice(race_ids, int(parameter['num_data']), replace=False)

cursor.execute('desc features')
fields = pd.DataFrame(cursor.fetchall())['Field']
non_feature_names = ['id', 'horse_id', 'created_at', 'updated_at']
feature_names = np.setdiff1d(fields, non_feature_names)

sql = 'SELECT ' + ','.join(feature_names) \
  + ' FROM features WHERE race_id IN (' + ','.join(race_ids) + ')'
cursor.execute(sql)
feature = pd.DataFrame(cursor.fetchall())

mapping = yaml.safe_load(open(workdir + '/mapping.yml', 'r+'))
for name in mapping:
  feature[name] = feature[name].map(mapping[name]).astype(int)

feature['horse_average_prize_money'] = feature['horse_average_prize_money'].astype(float)
feature['jockey_average_prize_money'] = feature['jockey_average_prize_money'].astype(float)

columns = feature.columns.to_list()
columns.remove('race_id')
columns.remove('number')
columns.insert(0, 'number')
columns.insert(0, 'race_id')
feature[columns].sort_values(['race_id', 'number']).to_csv(outputdir + '/feature.csv', index=False)

training_data = feature.groupby('race_id').apply(create_race_feature)
training_data = training_data.dropna()
columns = training_data.columns.to_list()
columns.remove('race_id')
columns.insert(0, 'race_id')
training_data[columns].to_csv(outputdir + '/training_data.csv', index=False)

file = open(outputdir + '/race_list.txt', 'w+')
race_ids = training_data['race_id'].unique()
race_ids.sort()
file.write("\n".join(race_ids))
file.close()

training_data = training_data.drop('race_id', axis=1)

classifier = RandomForestClassifier(
  class_weight='balanced',
  max_depth=parameter['max_depth'],
  max_features=parameter['max_features'],
  max_leaf_nodes=parameter['max_leaf_nodes'],
  min_samples_leaf=parameter['min_samples_leaf'],
  min_samples_split=parameter['min_samples_split'],
  n_estimators=parameter['num_tree'],
  random_state=0
)
classifier.fit(training_data.drop('won', axis=1), training_data['won'].astype('int'))

file = open(outputdir + '/metadata.yml', 'w+')
importance_values = classifier.feature_importances_.astype(type('float', (float,), {}))
importance = {}
for i in range(len(training_data.columns) - 1):
  importance[training_data.columns[i]] = importance_values[i]

metadata = {
  'num_data': len(training_data),
  'num_tree': parameter['num_tree'],
  'num_feature': classifier.n_features_,
  'importance': importance
}
file.write(yaml.dump(metadata))

pickle.dump(classifier, open(outputdir + '/model.rf', 'wb'))
util.output_tree(classifier, training_data, outputdir)
