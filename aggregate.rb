# coding: utf-8
require 'fileutils'
require 'mysql2'
require_relative 'config/settings'

FileUtils.rm('/tmp/training_data.csv') if File.exists?('/tmp/training_data.csv')
client = Mysql2::Client.new(Settings.mysql)
query = File.read(File.join(Settings.application_root, 'aggregate/outfile.sql'))
client.query(query)
query = File.read(File.join(Settings.application_root, 'aggregate/infile.sql'))
client.query(query)
