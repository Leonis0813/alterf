# coding: utf-8

class NetkeibaClient < HTTPClient
  include FeatureExtractor

  def http_get_race_top
    res = get("#{Settings.netkeiba.base_url}/?pid=race_top")
    res.body.scan(%r{.*/race/(\d+)}).flatten
  end

  def http_get_race(path)
    html = send_request(path)
    place = html.xpath('//ul[contains(@class, "race_place")]').first
    race_data = html.xpath('//dl[contains(@class, "racedata")]')
    race_date = html.xpath('//li[@class="result_link"]').text
                    .match(/(\d*)年(\d*)月(\d*)日のレース結果/)
    extract_race(place, race_data, race_date).merge(entries: extract_entries(race_data))
  end

  def http_get_horse(path)
    html = send_request(path)
    tekisei_table = html.xpath('//table[contains(@class, "tekisei_table")]')
    result_table = html.xpath('//table[contains(@class, "db_h_race_results")]')
    extract_horse(tekisei_table).merge(results: extract_horse_results(result_table))
  end

  def http_get_jockey(path)
    html = send_request(path)
    result_table = html.xpath('//table[contains(@class, "race_table_01")]')
    {results: extract_jockey_results(result_table)}
  end

  private

  def send_request(path)
    url = Settings.netkeiba.base_url + path
    Nokogiri::HTML.parse(get(url).body.encode('UTF-8', 'EUC-JP').gsub('&nbsp;', ' '))
  end
end
