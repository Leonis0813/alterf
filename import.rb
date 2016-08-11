require_relative '../settings/settings'
Dir['import/*.rb'].each {|file| require_relative file }

from = ARGV[0] ? Date.parse(ARGV[0]) : Date.parse('1988-01-01')
to = ARGV[1] ? Date.parse(ARGV[1]) : Date.today

(from..to).each do |date|
  date = date.strftime('%Y%m%d')

  raw_html = fetch(:race_list, date)
  file_path = if raw_html
                race_list = extract(:race_list, raw_html)
                output(:race_list, race_list, "#{date}.txt")
              else
                File.join(Settings.backup_dir[resource_type], "#{date}.txt")
              end
  File.read(file_path).split("\n").each do |race_id|
    raw_html = fetch(:race, race_id)
    encoded_html = raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
    output(:race, encoded_html, "#{race_id}.html")

    race = extract(:race, encoded_html)
    insert(:race, race)

    entries = extract(:entry, encoded_html)
    results = extract(:result, encoded_html)

    entries.zip(results).each do |entry, result|
      raw_html = fetch(:horse, entry[:external_id])
      encoded_html = raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
      output(:horse, encoded_html, "#{entry[:external_id]}.html")
      horse = extract(:horse, encoded_html)
      insert(:horse, horse)

      insert(:entry, entry.merge(:race_id => race[:id], :horse_id => horse[:id]))
      insert(:result, result.merge(:race_id => race[:id], :horse_id => horse[:id]))
    end

    extract(:payoff, encoded_html).each do |payoff|
      insert(:payoff, payoff.merge(:race_id => race[:id]))
    end
  end
end
