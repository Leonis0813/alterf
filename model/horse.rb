# coding: utf-8
require_relative '../settings/settings'
require 'mysql2'

class Horse
  attr_accessor :id, :name, :trainer, :owner, :birthday, :breeder, :growing_area
  attr_accessor :central_prize, :local_prize, :first, :second, :third, :total_race
  attr_accessor :father_id, :mother_id, :external_id

  def initialize(attribute)
    attribute.each {|key, value| send("#{key}=", value) }
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  horses
VALUES (
  NULL,
  "#{@name}",
  "#{@trainer}",
  "#{@owner}",
  "#{@birthday}",
  "#{@breeder}",
  "#{@growing_area}",
  #{@central_prize},
  #{@local_prize},
  #{@first},
  #{@second},
  #{@third},
  #{@total_race},
  #{@father_id || 'NULL'},
  #{@mother_id || 'NULL'},
  #{@external_id}
)
EOF
    begin
      client.query(query)
      @id = client.last_id
    rescue => e
      p e.message
      raise
    ensure
      client.close
    end
  end

  def self.find_by(attribute)
    attribute = attribute.map {|key, value| "#{key} = #{value}"}

    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  *
FROM
  horses
WHERE
  #{attribute.join(' AND ')}
LIMIT 1
EOF
    begin
      results = client.query(query)
      results.first ? self.new(results.first) : nil
    rescue => e
      p e.message
      raise
    ensure
      client.close
    end
  end
end
