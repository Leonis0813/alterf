# coding: utf-8
require_relative 'config/settings'
require_relative 'lib/mysql_client'
Dir['import/*.rb'].each {|file| require_relative file }

from = ARGV[0] ? Date.parse(ARGV[0]) : (Date.today - 7)
to = ARGV[1] ? Date.parse(ARGV[1]) : Date.today

(from..to).each do |date|
  date = date.strftime('%Y%m%d')

  raw_html = fetch('race_list', date)
  file_path = if raw_html
                race_list = extract('race_list', raw_html)
                next if race_list.empty?
                output('race_list', race_list.join("\n").concat("\n"), "#{date}.txt")
              else
                File.join(Settings.backup_dir['race_list'], "#{date}.txt")
              end

  File.read(file_path).split("\n").each do |race_id|
    raw_html = fetch('race', race_id)
    encoded_html = if raw_html
                     raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
                   else
                     File.read(File.join(Settings.backup_dir['race'], "#{race_id}.html"))
                   end
    output('race', encoded_html, "#{race_id}.html")
    race = extract('race', encoded_html)
    next if race.nil? or race[:track] == '障'
    race.merge!(:id => insert('race', race))
    race.merge!(:id => get_race_id(race[:name], race[:start_time], race[:place])) if race[:id].to_i == 0

    entries = extract('entry', encoded_html)
    results = extract('result', encoded_html)

    entries.zip(results).each do |entry, result|
      raw_html = fetch('horse', entry[:external_id])
      encoded_html = if raw_html
                       raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
                     else
                       File.read(File.join(Settings.backup_dir['horse'], "#{entry[:external_id]}.html"))
                     end
      output('horse', encoded_html, "#{entry[:external_id]}.html")
      horse = extract('horse', encoded_html)
      horse.merge!(:external_id => entry[:external_id])
      horse.merge!(:id => insert('horse', horse))
      horse.merge!(:id => get_horse_id(horse[:external_id])) if horse[:id].to_i == 0

      insert('entry', entry.merge(:race_id => race[:id], :horse_id => horse[:id]))
      insert('result', result.merge(:race_id => race[:id], :horse_id => horse[:id]))
    end

    encoded_html = File.read(File.join(Settings.backup_dir['race'], "#{race_id}.html"))
    extract('payoff', encoded_html).each do |payoff|
      insert('payoff', payoff.merge(:race_id => race[:id]))
    end
  end
end
