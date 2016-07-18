require_relative '../settings/settings.rb'
require_relative '../model/horse.rb'

def import_horse(horse_id)
  html_file = File.join(Settings.backup_path, "horses/#{horse_id}.html")
  html = File.read(html_file).gsub("\n", '').gsub('&nbsp;', ' ')

  parsed_horse = HTML.parse(:horse, html)
  horse = Horse.new(parsed_horse)
  horse.external_id = horse_id
  horse.save!
  horse
end
