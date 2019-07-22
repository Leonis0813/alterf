# coding: utf-8

class NetkeibaClient < HTTPClient
  def http_get_race_top
    res = get("#{Settings.netkeiba.base_url}/?pid=race_top")
    res.body.scan(%r{.*/race/(\d+)}).flatten
  end

  def http_get_race_name(race_id)
    url = "#{Settings.netkeiba.base_url}/race/#{race_id}"
    html =
      Nokogiri::HTML.parse(get(url).body.encode('UTF-8', 'EUC-JP').gsub('&nbsp;', ' '))
    html.xpath('//dl[contains(@class, "racedata")]/dd/h1').text.strip
  end
end
