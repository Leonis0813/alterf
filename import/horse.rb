require_relative '../config/settings.rb'

def import_horse(file_id)
  horse_file = File.join(Settings.application_root, 'raw_data/horses', "#{file_id}.html")
  
end
