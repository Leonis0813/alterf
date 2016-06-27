require_relative '../settings/settings.rb'
require_relative '../model/result.rb'

def import_result(file_id)
  html_file = File.join(Settings.raw_data_path, "results/#{file_id}.html")
  Result.create_all_entries(html_file)
end
