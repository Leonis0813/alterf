require_relative '../config/settings.rb'
require_relative '../model/condition.rb'

def import_condition(file_id)
  race_result_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  condition = Condition.new(race_result_file).save!
  condition.id
end
