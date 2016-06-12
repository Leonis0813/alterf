require_relative '../settings/settings.rb'
require 'mysql2'

client = Mysql2::Client.new(Settings.mysql)
client.query("DROP DATABASE #{Settings.mysql['database']}")

query =<<"EOF"
CREATE DATABASE IF NOT EXISTS
  #{Settings.mysql['database']}
DEFAULT CHARACTER SET
  utf8
EOF
client.query(query)
client.close

client = Mysql2::Client.new(Settings.mysql)
Dir[File.join(Settings.application_root, 'schema/*.sql')].each do |sql_file|
  client.query(File.read(sql_file))
end
client.close
