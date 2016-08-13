require 'mysql2'

def get_race_id(race_name, start_time)
  client = Mysql2::Client.new(Settings.mysql)
  query =<<"EOF"
SELECT
  id
FROM
  races
WHERE
  name = '#{race_name}'
  AND start_time = '#{start_time}'
LIMIT 1
EOF
  begin
    result = client.query(query)
    client.close
    result.first['id']
  rescue => e
    p e.message
    raise
  end
end

def get_horse_id(external_id)
  client = Mysql2::Client.new(Settings.mysql)
  query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  external_id = #{external_id}
ORDER BY
  birthday desc
LIMIT 1
EOF
  begin
    result = client.query(query)
    client.close
    result.first['id']
  rescue => e
    p e.message
    raise
  end
end
