# coding: utf-8
require 'mysql2'
require_relative '../settings/settings'
require_relative '../client/mysql'

class Race
  attr_accessor :id, :name, :track, :direction, :distance, :weather
  attr_accessor :track_condition, :place, :round, :start_time, :num_of_horse

  def initialize(attribute)
    attribute.each {|key, value| send("#{key}=", value) }
  end

  def save!
    return nil if @track == '障'

    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  races
VALUES (
  NULL,
  '#{@name}',
  '#{@track}',
  '#{@direction}',
  #{@distance},
  '#{@weather}',
  '#{@track_condition}',
  '#{@start_time}',
  '#{@place}',
  #{@round},
  #{@num_of_horse}
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
end
