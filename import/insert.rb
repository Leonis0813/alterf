require 'mysql2'
require_relative '../config/settings'
require_relative '../lib/logger'

def insert(resource, attribute)
  query = File.read(File.join(Settings.application_root, 'import/insert', "#{resource}.sql"))
  attribute.each {|key, value| query.gsub!("$#{key.upcase}") {value.to_s} }
  client = Mysql2::Client.new(Settings.mysql)
  begin
    client.query(query)
    if client.last_id == 0
      Logger.info(:action => 'insert', :resource => resource, :message => 'already_exist')
    else
      Logger.info(:action => 'insert', :resource => resource, :id => client.last_id, :attribute => attribute)
    end
    client.last_id
  rescue Mysql2::Error => e
    Logger.error(:action => 'insert', :resource => resource, :message => e.message)
    raise
  ensure
    client.close
  end
end
