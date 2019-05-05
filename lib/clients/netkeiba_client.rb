# coding: utf-8

class NetkeibaClient < HTTPClient
  def http_get_race_top
    res = get("#{Settings.netkeiba.base_url}/?pid=race_top")
    html = Nokogiri::HTML.parse(res.body.encode('UTF-8', 'EUC-JP').gsub('&nbsp;', ' '))
    html.scan(%r{.*/race/(\d+)}).flatten
  end

  def http_get_race(url)
    html =
      Nokogiri::HTML.parse(get(url).body.encode('UTF-8', 'EUC-JP').gsub('&nbsp;', ' '))

    race_data = html.xpath('//dl[contains(@class, "racedata")]')
    track, weather, = race_data.search('span').text.split('/')
    entries = race_data.xpath('//table[contains(@class, "race_table")]').search('tr')

    {
      track: track[0].sub('ダ', 'ダート'),
      direction: track[1],
      distance: track.match(/(\d*)m/)[1].to_i,
      weather: weather.match(/天候 : (.*)/)[1].strip,
      grade: race_data.search('h1').text.match(/\((.*)\)$/).try(:[], 1),
      place: html.xpath('//ul[contains(@class, "race_place")]').first
                 .children[1].text.match(%r{<a.*class="active">(.*?)</a>})[1],
      round: race_data.search('dt').text.strip.match(/^(\d*) R$/)[1].to_i,
      test_data: extract_test_data(entries[1..-1]),
    }
  end

  private

  def extract_test_data(entries)
    entries.map do |entry|
      attributes = entry.search('td').map(&:text).map(&:strip)

      [
        attributes[4].match(/(\d+)\z/)[1].to_i,
        attributes[5].to_f,
        attributes[2].to_i,
        attributes[14].match(/\A(\d+)/).try(:[], 1).to_f,
        attributes[14].match(/\((.+)\)$/).try(:[], 1).to_f,
      ]
    end
  end
end
