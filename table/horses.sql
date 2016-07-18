CREATE TABLE IF NOT EXISTS horses (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  trainer VARCHAR(255) NOT NULL,
  owner VARCHAR(255) NOT NULL,
  birthday DATE NOT NULL,
  breeder VARCHAR(255) NOT NULL,
  growing_area VARCHAR(255) NOT NULL,
  central_prize BIGINT NOT NULL,
  local_prize BIGINT NOT NULL,
  first INTEGER NOT NULL,
  second INTEGER NOT NULL,
  third INTEGER NOT NULL,
  total_race INTEGER NOT NULL,
  father_id INTEGER,
  mother_id INTEGER,
  external_id INTEGER UNIQUE NOT NULL,
  UNIQUE(name, birthday)
)
