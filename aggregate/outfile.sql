SELECT
  NULL,
  race.name,
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
  horse.name,
  entry.age,
  entry.burden_weight,
  entry.jockey,
  entry.weight,
  horse.trainer,
  horse.owner,
  horse.birthday,
  horse.breeder,
  horse.growing_area,
  father.name,
  mother.name,
  result.`order`
FROM
  entries AS entry,
  races AS race,
  results AS result,
  horses AS horse
LEFT JOIN
  horses AS father
ON
  horse.father_id = father.id
LEFT JOIN
  horses AS mother
ON
  horse.mother_id = mother.id
WHERE
  entry.race_id = race.id
  AND entry.horse_id = horse.id
  AND entry.race_id = result.race_id
  AND entry.horse_id = result.horse_id
INTO OUTFILE
  '/tmp/training_data.csv'
FIELDS TERMINATED BY
  ','
OPTIONALLY ENCLOSED BY
  '"'
