CREATE TABLE IF NOT EXISTS payoffs (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  race_id INTEGER NOT NULL,
  prize_name VARCHAR(6) NOT NULL,
  money INTEGER NOT NULL,
  popularity INTEGER NOT NULL,
  UNIQUE(race_id, prize_name, popularity)
)
