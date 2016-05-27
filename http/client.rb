require_relative '../config/settings.rb'
require 'net/http'

class HTTPClient
  def get_race_list(date)
    return unless date.kind_of?(String) and date.match(/\d{4}-\d{2}-\d{2}/)
    get("#{Settings.url}/race/list/#{date.strftime('%Y%m%d')}")
  end

  def get_race_result(race_id)
    return unless race_id.kind_of?(String)
    get("#{Settings.url}/race/#{race_id}")
  end

  private

  def get(url)
    parsed_url = URI.parse(url)
    Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
  end
end
