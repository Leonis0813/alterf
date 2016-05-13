CREATE TABLE IF NOT EXISTS payoffs (
  race_id INTEGER,
  prize_name VARCHAR(6),
  money INTEGER NOT NULL,
  popularity INTEGER NOT NULL,
  PRIMARY KEY(race_id, prize_name)
)
