require_relative '../settings/settings.rb'
require_relative '../model/horse.rb'

def import_horse(file_id)
  html_file = File.join(Settings.raw_data_path, "results/#{file_id}.html")
  raw_html = File.read(html_file)
  html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')

  horse_ids = html.scan(/\/horse\/(\d+)/).flatten
  horse_ids.each do |horse_id|
    html_file = File.join(Settings.raw_data_path, "horses/#{horse_id}.html")
    Horse.new(html_file).save!
  end
end
