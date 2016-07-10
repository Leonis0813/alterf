# coding: utf-8
require_relative '../settings/settings.rb'
require_relative '../client/mysql.rb'
require 'mysql2'

class Race
  attr_accessor :id, :name, :track, :direction, :distance, :weather
  attr_accessor :track_condition, :place, :round, :start_time, :num_of_horse

  def initialize(attribute)
    attribute.each {|key, value| eval("@#{key}=#{value}") }
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  results
VALUES (
  #{@race_id},
  #{@horse_id},
  '#{@order}',
  #{@time || 'NULL'},
  '#{@margin}',
  #{@third_corner},
  #{@forth_corner},
  #{@slope},
  #{@odds},
  #{@popularity}
)
EOF
    begin
      client.query(query)
      client.close
    rescue => e
      p e.message
      raise
    end
  end
end
