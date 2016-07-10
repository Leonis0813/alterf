# coding: utf-8
require_relative '../settings/settings.rb'
require_relative '../client/mysql.rb'
require 'mysql2'

class Entry
  attr_accessor :race_id, :horse_id, :number, :bracket, :age, :jockey
  attr_accessor :burden_weight, :weight

  def initialize(attribute)
    attribute.each {|key, value| send("#{key}=", value) }
  end

  def save!
    return if @weight == '計不'

    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  entries
VALUES (
  #{@race_id},
  #{@horse_id},
  #{@number},
  #{@bracket},
  #{@age},
  '#{@jockey}',
  #{@burden_weight},
  #{@weight || 'NULL'}
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
