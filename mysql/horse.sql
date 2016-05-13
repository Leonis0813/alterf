CREATE TABLE IF NOT EXISTS horses (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  age INTEGER NOT NULL,
  burden_weight FLOAT NOT NULL,
  weight FLOAT NOT NULL,
  trainer VARCHAR(255) NOT NULL,
  owner VARCHAR(255) NOT NULL,
  birthday DATE NOT NULL,
  breeder VARCHAR(255) NOT NULL,
  growing_area VARCHAR(255) NOT NULL,
  central_prize INTEGER NOT NULL,
  local_proze INTEGER NOT NULL,
  first INTEGER NOT NULL,
  second INTEGER NOT NULL,
  third INTEGER NOT NULL,
  total_race INTEGER NOT NULL,
  father_id INTEGER NOT NULL,
  mother_id INTEGER NOT NULL
)
