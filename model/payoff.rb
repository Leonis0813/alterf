# coding: utf-8
require_relative '../settings/settings'
require_relative '../client/mysql'
require 'mysql2'

class Payoff
  attr_accessor :id, :race_id, :prize_name, :money, :popularity

  def initialize(attribute)
    attribute.each {|key, value| send("#{key}=", value) }
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  payoffs
VALUES (
  NULL,
  '#{@race_id}',
  '#{@prize_name}',
  #{@money},
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
