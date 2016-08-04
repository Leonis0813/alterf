require 'mysql2'
require_relative '../settings/settings'

def insert(resource_type, attribute)
  query = File.read("insert/#{resource_type}.sql")
  attribute.each {|key, value| query.gsub!("$#{key.upcase}", value) }
  client = Mysql2::Client.new(Settings.mysql)
  result = client.query(query)
  client.close
  result
end
