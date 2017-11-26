CREATE TABLE IF NOT EXISTS entries (
  race_id INTEGER,
  horse_id INTEGER,
  number INTEGER NOT NULL,
  bracket INTEGER NOT NULL,
  age INTEGER NOT NULL,
  jockey VARCHAR(16) NOT NULL,
  burden_weight FLOAT NOT NULL,
  weight FLOAT,
  PRIMARY KEY(race_id, horse_id)
)
