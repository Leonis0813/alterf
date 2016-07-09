require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_race_list(date)
  race_list_file = File.join(Settings.backup_path, "race_list/#{date}.txt")
  return if File.exists?(race_list_file)

  res = HTTPClient.new.get_races(date)
  races = res.body.scan(%r[.*(/race/\d+)]).flatten
  return if races.empty?

  File.open(race_list_file, 'w') do |out|
    races.each {|race| out.puts(race) }
  end
end
