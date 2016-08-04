Dir['import/*.rb'].each {|file| require_relative file }

from = ARGV[0] ? Date.parse(ARGV[0]) : Date.parse('1988-01-01')
to = ARGV[1] ? Date.parse(ARGV[1]) : Date.today

(from..to).each do |date|
  raw_html = fetch(:race_list, date)
  race_list = extract(:race_list, raw_html)
  file_path = output(:race_list, race_list, date)
  File.read(file_path).split("\n").each do |race_id|
    raw_html = fetch(:race, race_id)
    encoded_html = raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
    output(:race, encoded_html, race_id)

    race = extract(:race, encoded_html)
    insert(:race, race)

    entries = extract(:entry, encoded_html)
    results = extract(:result, encoded_html)

    entries.zip(results).each do |entry, result|
      raw_html = fetch(:horse, entry[:external_id])
      encoded_html = raw_html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
      output(:race, encoded_html, entry[:external_id])
      horse = extract(:horse, encoded_html)
      insert(:horse, horse)

      entry.merge!(:race_id => race[:id], :horse_id => horse[:id])
      insert(:entry, entry)

      result.merge!(:race_id => race[:id], :horse_id => horse[:id])
      insert(:result, result)
    end

    payoffs = extract(:payoff, encoded_html)
    payoffs.each do |payoff|
      payoff.merge!(:race_id => race[:id])
      insert(:payoff, payoff)
    end
  end
end
