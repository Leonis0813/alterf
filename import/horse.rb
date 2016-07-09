require_relative '../settings/settings.rb'
require_relative '../model/horse.rb'

def import_horse(horse_id)
  html_file = File.join(Settings.backup_path, "horses/#{horse_id}.html")
  html = File.read(horse_html_file).gsub("\n", '').gsub('&nbsp;', ' ')

  parsed_horse = HTML.parse(html, :horse)
  horse = Horse.new(parsed_horse)
  horse.save!
end
