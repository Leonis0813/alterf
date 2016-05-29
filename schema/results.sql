CREATE TABLE IF NOT EXISTS results (
  race_id INTEGER,
  horse_id INTEGER,
  `order` VARCHAR(2) NOT NULL,
  time FLOAT,
  margin VARCHAR(10),
  third_corner VARCHAR(2),
  forth_corner VARCHAR(2),
  slope FLOAT,
  odds FLOAT NOT NULL,
  popularity INTEGER NOT NULL,
  PRIMARY KEY(race_id, horse_id)
)
