CREATE TABLE IF NOT EXISTS race_horses (
  race_id INTEGER,
  horse_id INTEGER,
  age INTEGER NOT NULL,
  jockey VARCHAR(16) NOT NULL,
  burden_weight FLOAT NOT NULL,
  weight FLOAT NOT NULL,
  PRIMARY KEY(race_id, horse_id)
)
