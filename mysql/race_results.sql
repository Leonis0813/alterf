CREATE TABLE IF NOT EXISTS race_results (
  race_id INTEGER,
  horse_id INTEGER,
  number INTEGER NOT NULL,
  `order` INTEGER NOT NULL,
  time TIME NOT NULL,
  margin VARCHAR(10) NOT NULL,
  third_corner INTEGER NOT NULL,
  forth_corner INTEGER NOT NULL,
  slope TIME NOT NULL,
  odds FLOAT NOT NULL,
  popularity INTEGER NOT NULL,
  PRIMARY KEY(race_id, horse_id)
)
