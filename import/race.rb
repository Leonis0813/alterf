require_relative '../settings/settings.rb'
require_relative '../helper/html.rb'
Dir["#{Settings.application_root}/model/*.rb"].each {|file| require_relative file }

def import_race(race_id)
  html_file = File.join(Settings.backup_path, "races/#{race_id}.html")
  html = File.read(html_file).gsub("\n", '').gsub('&nbsp;', ' ')

  parsed_race = HTML.parse(:race, html)
  race = Race.new(parsed_race)
  race.save!

  parsed_entries = HTML.parse(:entry, html)
  parsed_results = HTML.parse(:result, html)
  parsed_entries.zip(parsed_results).each_with_index do |parsed_data, i|
    entry = Entry.new(parsed_data.first)
    result = Result.new(parsed_data.last)

    horse = Horse.find_by(:external_id => entry.external_id)
    horse = unless horse
              output_horse(entry.external_id)
              import_horse(entry.external_id)
            end

    entry.race_id = race.id
    entry.horse_id = horse.id
    entry.save!

    result.race_id = race.id
    result.horse_id = horse.id
    result.save!
  end

  parsed_payoffs = HTML.parse(:payoff, html)
  parsed_payoffs.each do |p|
    payoff = Payoff.new(p)
    payoff.race_id = race.id
    payoff.save!
  end
end
