from dtreeviz.trees import dtreeviz
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

workdir = os.path.dirname(os.path.abspath(args[0]))
outputdir = workdir + '/../tmp/files/' + analysis_id
config = yaml.load(open(workdir + '/../config/settings.yml', 'r+'))

def normalize_racewise_feature(group):
  features = group[config['analysis']['racewise_features']]
  normalized = (features - features.min()) / (features.max() - features.min())
  for name in config['analysis']['racewise_features']:
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

if (len(race_ids) >= num_training_data / 2):
  race_ids = np.random.choice(race_ids, int(num_training_data / 2), replace=False)

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
feature = feature.groupby('race_id').apply(normalize_racewise_feature)
feature = feature.drop('race_id', axis=1)
feature = feature.dropna()

positive = feature[feature['won'] == 1]
negative = feature[feature['won'] == 0].sample(n=len(positive))
training_data = pd.concat([positive, negative])
training_data.to_csv(outputdir + '/training_data.csv', index=False)

classifier = RandomForestClassifier(n_estimators=ntree, random_state=0)
classifier.fit(training_data.drop('won', axis=1), training_data['won'])

file = open(outputdir + '/metadata.yml', 'w+')
importance_values = classifier.feature_importances_.astype(type('float', (float,), {}))
importance = {}
for i in range(len(training_data.columns) - 1):
  importance[training_data.columns[i]] = importance_values[i]

metadata = {
  'num_training_data': {
    'positive': len(positive),
    'negative': len(negative)
  },
  'num_tree': ntree,
  'num_feature': classifier.n_features_,
  'importance': importance
}
file.write(yaml.dump(metadata))

pickle.dump(classifier, open(outputdir + '/model.rf', 'wb'))

#for i, estimator in enumerate(classifier.estimators_):
#  tree = dtreeviz(
#    estimator,
#    training_data.drop('won', axis=1),
#    training_data['won'],
#    target_name='Result',
#    feature_names=training_data.drop('won', axis=1).columns,
#    class_names=['lost', 'won'],
#  )
#  tree.save(outputdir + '/tree_' + str(i) + '.svg')
