INSERT IGNORE INTO
  races
SELECT
  NULL,
  race.id,
  rane.name,
  race.track,
  race.direction,
  race.distance,
  race.weather,
  race.`condition`,
  race.start_time,
  race.place,
  race.round,
  entry.number,
  entry.bracket,
  entry.horse_name,
  entry.age,
  entry.burden_weight,
  entry.jockey,
  entry.weight,
  horse.trainer,
  horse.owner,
  horse.birthday,
  horse.breeder,
  horse.growing_area,
  horse.central_prize,
  horse.local_prize,
  horse.first,
  horse.second,
  horse.third,
  horse.total_prize,
  horse.father_horse_name,
  horse.mother_horse_name,
  result.`order`
FROM
  entries AS entry
LEFT JOIN
  races AS race
ON
  entry.race_id = race.id
LEFT JOIN
  horse AS horse
ON
  entry.horse_id = horse.id
LEFT JOIN
  results AS result
ON
  entry.race_id = result.race_id AND
  entry.horse_id = result.horse_id
