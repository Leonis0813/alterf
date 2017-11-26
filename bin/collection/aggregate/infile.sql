LOAD DATA
  INFILE
    '/tmp/training_data.csv'
  IGNORE INTO TABLE
    training_data
  FIELDS TERMINATED BY
    ','
  OPTIONALLY ENCLOSED BY
    '"'
