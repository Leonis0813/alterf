from sklearn.ensemble import RandomForestClassifier
import numpy as np
import os
import pandas as pd
import pickle
import sys
import yaml

args = sys.argv
prediction_id = args[1]
model_filename = args[2]
test_data_filename = args[3]

workdir = os.path.dirname(os.path.abspath(args[0]))
config = yaml.load(open(workdir + '/../config/settings.yml', 'r+'))

model_path = workdir + '/../tmp/files/' + prediction_id + '/' + model_filename
classifier = pickle.load(open(model_path, 'rb'))

test_data_path = workdir + '/../tmp/files/' + prediction_id + '/' + test_data_filename
test_data = yaml.load(open(test_data_path, 'r+'))

mapping = yaml.load(open(workdir + '/mapping.yml', 'r+'))
feature = pd.DataFrame()
for key in test_data:
  if (key != 'entries'):
    race_feature = test_data[key]
    if (key in mapping):
      race_feature = mapping[key][race_feature]
    feature[key] = np.array([race_feature])

entry_feature_names = np.hstack((
  config['prediction']['feature']['horses'],
  config['prediction']['feature']['jockeys']
))

for entry_id in range(len(test_data['entries'])):
  entry_features = test_data['entries'][entry_id]

  for feature_id in range(len(entry_features)):
    entry_feature = entry_features[feature_id]
    feature_name = entry_feature_names[feature_id]
    if (feature_name in mapping):
      entry_feature = mapping[feature_name][entry_feature]
    feature[feature_name + '_' + str(entry_id)] = entry_feature

won = classifier.predict(feature).astype(type('int', (int,), {}))

result = {}
for i in range(len(test_data['entries'])):
  result[i + 1] = 1 if won == (i + 1) else 0

file = open(workdir + '/../tmp/files/' + prediction_id + '/prediction.yml', 'w+')
file.write(yaml.dump(result))
