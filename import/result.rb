require_relative '../settings/settings.rb'
require_relative '../model/result.rb'

def import_result(file_id)
  html_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  Result.create_all_entries(html_file)
end
