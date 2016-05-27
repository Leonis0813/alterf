require_relative '../config/settings.rb'
require 'mysql2'

mysql_conf = {:host => Settings.host, :username => Settings.username, :password => Settings.password}
query = "DROP DATABASE #{Settings.database}"
client = Mysql2::Client.new(mysql_conf)
client.query(query)

query =<<"EOF"
CREATE DATABASE IF NOT EXISTS
  #{Settings.database}
DEFAULT CHARACTER SET
  utf8
EOF
client.query(query)
client.close

client = Mysql2::Client.new(mysql_conf.merge(:database => Settings.database))
Dir[File.join(Settings.application_root, 'schema/*.sql')].each do |sql_file|
  client.query(File.read(sql_file))
end
client.close
