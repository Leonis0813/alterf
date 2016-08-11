CREATE TABLE IF NOT EXISTS races (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  track VARCHAR(6) NOT NULL,
  direction VARCHAR(2) NOT NULL,
  distance INTEGER NOT NULL,
  weather VARCHAR(6) NOT NULL,
  `condition` VARCHAR(4) NOT NULL,
  start_time DATETIME NOT NULL,
  place VARCHAR(16) NOT NULL,
  round INTEGER NOT NULL,
  num_of_horse INTEGER NOT NULL,
  UNIQUE(name, start_time, place)
)
