CREATE TABLE IF NOT EXISTS training_data (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  race_name VARCHAR(255) NOT NULL,
  track VARCHAR(6) NOT NULL,
  direction VARCHAR(2) NOT NULL,
  distance INTEGER NOT NULL,
  weather VARCHAR(6) NOT NULL,
  `condition` VARCHAR(4) NOT NULL,
  start_time DATETIME NOT NULL,
  place VARCHAR(16) NOT NULL,
  round INTEGER NOT NULL,
  number INTEGER NOT NULL,
  bracket INTEGER NOT NULL,
  horse_name VARCHAR(255) NOT NULL,
  age INTEGER NOT NULL,
  burden_weight FLOAT NOT NULL,
  jockey VARCHAR(16) NOT NULL,
  weight FLOAT,
  trainer VARCHAR(255) NOT NULL,
  owner VARCHAR(255) NOT NULL,
  birthday DATE NOT NULL,
  breeder VARCHAR(255) NOT NULL,
  growing_area VARCHAR(255) NOT NULL,
  father_horse_name VARCHAR(255) NOT NULL,
  mother_horse_name VARCHAR(255) NOT NULL,
  `order` VARCHAR(2) NOT NULL,
  UNIQUE(race_name, start_time, place, horse_name, birthday)
)
