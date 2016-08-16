require 'mysql2'
require_relative '../config/settings'
require_relative '../lib/logger'

def insert(resource, attribute)
  operate = File.basename(__FILE__, '.rb')
  query = File.read(File.join(Settings.application_root, 'import/insert', "#{resource}.sql"))
  attribute.each {|key, value| query.gsub!("$#{key.upcase}") {value.to_s} }
  client = Mysql2::Client.new(Settings.mysql)
  begin
    client.query(query)
    Logger.write(resource, operate, {:id => client.last_id, :attribute => attribute})
    client.last_id
  rescue Mysql2::Error => e
    Logger.write(resource, operate, e.message)
    raise
  ensure
    client.close
  end
end
