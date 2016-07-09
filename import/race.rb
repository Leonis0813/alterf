# coding: utf-8
require_relative '../settings/settings.rb'
require_relative '../model/result.rb'

def import_race(race_id)
  html_file = File.join(Settings.backup_path, "races/#{race_id}.html")
  html = File.read(html_file).gsub("\n", '').gsub('&nbsp;', ' ')

  parsed_race = HTML.parse(html, :race)
  race = Race.new(parsed_race)
  race.save!

  parsed_entries = HTML.parse(html, :entry)
  parsed_entries.each do |e|
    entry = Entry.new(e)
    horse = Horse.find_by(:external_id => entry.external_id)
    unless horse
      parsed_horse = HTML.parse(html, :horse)
      horse = Horse.new(parsed_horse)
      horse.save!
    end
    entry.race_id = race.id
    entry.horse_id = horse.id
    entry.save!

    parsed_result = HTML.parse(html, :result)
    result = Result.new(parsed_result)
    result.race_id = race.id
    result.horse_id = horse.id
    result.save!
  end

  parsed_payoffs = HTML.parse(html, :payoff)
  parsed_payoffs.each do |p|
    payoff = Payoff.new(p)
    payoff.race_id = race.id
    payoff.save!
  end
end
