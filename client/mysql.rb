require 'mysql2'

class MysqlClient
  def get_race_id(race_name, start_time)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  conditions
WHERE
  name = '#{race_name}'
  AND start_time = '#{start_time}'
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result.first['id']
    rescue
    end
  end

  def get_horse_id(horse_name)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  name = '#{horse_name}'
ORDER BY
  birthday desc
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result.first['id']
     rescue
    end
  end
end
