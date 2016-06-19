require_relative '../settings/settings.rb'
require_relative '../client/http.rb'
require 'date'
require 'fileutils'

def output_race_list(date)
  race_list_dir = File.join(Settings.raw_data_path, 'races')
  race_list_file = File.join(race_list_dir, "#{Date.parse(date).strftime('%Y%m%d')}.txt")
  return if File.exists?(race_list_file)

  res = HTTPClient.new.get_race_list(date)
  races = res.body.scan(%r[.*(/race/\d+)]).flatten

  return if races.empty?

  FileUtils.mkdir_p(race_list_dir)
  File.open(race_list_file, 'w') do |out|
    races.each {|race| out.puts(race) }
  end
end
