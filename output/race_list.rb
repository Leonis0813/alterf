require_relative '../settings/settings.rb'
require_relative '../client/http.rb'
require 'date'
require 'fileutils'

def output_race_list(date)
  races_dir = File.join(Settings.application_root, 'raw_data/races')
  return if File.exists?(File.join(races_dir, "#{Date.parse(date).strftime('%Y%m%d')}.txt"))

  res = HTTPClient.new.get_race_list(date)
  races = res.body.scan(%r[.*(/race/\d+)]).flatten

  return if races.empty?

  output_dir = File.join(Settings.application_root, 'raw_data/races')
  FileUtils.mkdir_p(output_dir)
  File.open(File.join(output_dir, "#{Date.parse(date).strftime('%Y%m%d')}.txt"), 'w') do |out|
    races.each {|race| out.puts(race) }
  end
end
