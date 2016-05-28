require_relative '../config/settings.rb'
require_relative '../model/result.rb'

def import_result(file_id)
  html_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  Result.new(html_file).save!
end
