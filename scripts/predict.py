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

feature = pd.DataFrame()
for key in test_data:
  if (key != 'entries'):
    feature[key] = np.array([test_data[key]] * len(test_data['entries']))

entry_feature_names = np.hstack((
  config['prediction']['feature']['horses'],
  config['prediction']['feature']['jockeys']
))

for i in range(len(entry_feature_names)):
  feature[entry_feature_names[i]] = [entry[i] for entry in test_data['entries']]

mapping = yaml.load(open(workdir + '/mapping.yml', 'r+'))
for name in mapping:
  feature[name] = feature[name].map(mapping[name]).astype(int)

racewise = feature[config['analysis']['racewise_features']]
normalized = (racewise - racewise.min()) / (racewise.max() - racewise.min())
for name in config['analysis']['racewise_features']:
  feature[name] = normalized[name]

won = classifier.predict(feature).astype(type('int', (int,), {}))

result = {}
for i in range(len(won)):
  result[i + 1] = won[i]

file = open(workdir + '/../tmp/files/' + prediction_id + '/prediction.yml', 'w+')
file.write(yaml.dump(result))
