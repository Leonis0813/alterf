require_relative '../settings/settings.rb'
require_relative '../model/condition.rb'

def import_condition(file_id)
  race_result_file = File.join(Settings.raw_data_path, "results/#{file_id}.html")
  Condition.new(race_result_file).save!
end
