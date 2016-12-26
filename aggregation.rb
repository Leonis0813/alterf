# coding: utf-8
require 'mysql2'
require_relative 'config/settings'

client = Mysql2::Client.new(Settings.mysql)
query = File.read(File.join(Settings.application_root, 'aggregation.sql'))
client.query(query)
