require_relative '../settings/settings.rb'
require_relative '../model/result.rb'

def import_race(race_id)
  html_file = File.join(Settings.raw_data_path, "results/#{race_id}.html")
  Result.create_all_entries(html_file)
end
