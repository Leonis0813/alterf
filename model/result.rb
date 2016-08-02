# coding: utf-8
require_relative '../settings/settings'
require_relative '../client/mysql'
require 'mysql2'

class Result
  attr_accessor :race_id, :horse_id, :order, :time, :margin, :third_corner, :forth_corner
  attr_accessor :slope, :odds, :popularity

  def initialize(attribute)
    attribute.each {|key, value| send("#{key}=", value) }
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
