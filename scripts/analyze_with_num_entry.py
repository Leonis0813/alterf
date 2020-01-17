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
training_data = training_data.dropna()
training_data.to_csv(outputdir + '/training_data.csv', index=False)

classifier = RandomForestClassifier(n_estimators=ntree, random_state=0)
classifier.fit(training_data.drop('won', axis=1), training_data['won'].astype('int'))

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
util.output_tree(classifier.estimators_, training_data, outputdir)
