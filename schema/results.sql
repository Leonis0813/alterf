CREATE TABLE IF NOT EXISTS results (
  race_id INTEGER,
  horse_id INTEGER,
  `order` INTEGER NOT NULL,
  time FLOAT NOT NULL,
  margin VARCHAR(10) NOT NULL,
  third_corner INTEGER NOT NULL,
  forth_corner INTEGER NOT NULL,
  slope FLOAT NOT NULL,
  odds FLOAT NOT NULL,
  popularity INTEGER NOT NULL,
  PRIMARY KEY(race_id, horse_id)
)
