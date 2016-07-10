# coding: utf-8
require_relative '../settings/settings.rb'
require 'mysql2'

class Horse
  attr_accessor :id, :name, :trainer, :owner, :birthday, :breeder, :growing_area
  attr_accessor :central_prize, :local_prize, :first, :second, :third, :total_race
  attr_accessor :father_id, :mother_id

  def initialize(attribute)
    attribute.each {|key, value| eval("@#{key}=#{value}") }
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  horses
VALUES (
  NULL,
  '#{@name}',
  '#{@trainer}',
  '#{@owner}',
  '#{@birthday}',
  '#{@breeder}',
  '#{@growing_area}',
  #{@central_prize},
  #{@local_prize},
  #{@first},
  #{@second},
  #{@third},
  #{@total_race},
  #{@father_id || 'NULL'},
  #{@mother_id || 'NULL'}
)
EOF
    begin
      client.query(query)
      @id = client.last_id
      client.close
      p 'ok: ' + name
    rescue => e
      p 'ng: ' + name
      p e.message
      raise
    end
  end

  private

  def get_parent_id(parent_name)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  name = "#{parent_name}"
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result.first['id'] if result.first
    rescue => e
      p e.message
      raise
    end
  end
end
