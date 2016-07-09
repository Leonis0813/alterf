require 'fileutils'
require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_races(date)
  races_dir = File.join(Settings.raw_data_path, 'races')
  races_file = File.join(races_dir, "#{date}.txt")
  return if File.exists?(races_file)

  res = HTTPClient.new.get_races(date)
  races = res.body.scan(%r[.*(/race/\d+)]).flatten
  return if races.empty?

  FileUtils.mkdir_p(races_dir)
  File.open(races_file, 'w') do |out|
    races.each {|race| out.puts(race) }
  end
end
