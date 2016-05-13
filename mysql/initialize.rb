require 'mysql2'

query =<<EOF
CREATE DATABASE IF NOT EXISTS
  alterf
DEFAULT CHARACTER SET
  utf8
EOF
client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4")
client.query(query)
client.close

client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'alterf')
Dir[File.join(File.expand_path(File.dirname(__FILE__)), '*.sql')].each do |sql_file|
  query = File.read(sql_file)
  client.query(query)
end
client.close
