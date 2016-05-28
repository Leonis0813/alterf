require_relative '../config/settings.rb'
require_relative '../model/horse.rb'

def import_horse(file_id)
  horse_file = File.join(Settings.application_root, 'raw_data/horses', "#{file_id}.html")
  Horse.new(html_file)
end
