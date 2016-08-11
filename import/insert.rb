require 'mysql2'
require_relative '../config/settings'

def insert(resource_type, attribute)
  query = File.read(File.join(Settings.application_root, 'import/insert', "#{resource_type}.sql"))
  attribute.each {|key, value| query.gsub!("$#{key.upcase}") {value.to_s} }
  client = Mysql2::Client.new(Settings.mysql)
  begin
    client.query(query)
    client.last_id
  rescue Mysql2::Error => e
    raise unless e.message.match(/Duplicate/)
  ensure
    client.close
  end
end
