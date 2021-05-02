from sklearn.ensemble import RandomForestClassifier
import numpy as np
import os
import pandas as pd
import pickle
import sys
import yaml

args = sys.argv
data_dir = args[1]
model_filename = args[2]
test_data_filename = args[3]

workdir = os.path.dirname(os.path.abspath(args[0]))
config = yaml.safe_load(open(workdir + '/../config/settings.yml', 'r+'))

model_path = data_dir + '/' + model_filename
classifier = pickle.load(open(model_path, 'rb'))

test_data_path = data_dir + '/' + test_data_filename
test_data = yaml.safe_load(open(test_data_path, 'r+'))

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

mapping = yaml.safe_load(open(workdir + '/mapping.yml', 'r+'))
for name in mapping:
  feature[name] = feature[name].map(mapping[name]).astype(int)

racewise = feature[config['analysis']['racewise_features']]
unnormalizable_feature_names = racewise.loc[:, racewise.max() == racewise.min()].columns
normalizable_feature_names = np.setdiff1d(
  config['analysis']['racewise_features'],
  unnormalizable_feature_names
)
racewise = racewise[normalizable_feature_names]
normalized = (racewise - racewise.min()) / (racewise.max() - racewise.min())

for name in unnormalizable_feature_names:
  normalized[name] = 0.0

for name in config['analysis']['racewise_features']:
  feature[name] = normalized[name]
feature = feature.sort_values(['number'])

won = classifier.predict(feature).astype(type('int', (int,), {}))

result = {}
numbers = feature['number'].to_list()
for i in range(len(won)):
  result[numbers[i]] = won[i]

file = open(data_dir + '/prediction.yml', 'w+')
file.write(yaml.dump(result))
