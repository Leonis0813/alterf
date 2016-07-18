require 'net/http'
require_relative '../settings/settings.rb'

class HTTPClient
  def get_races(date)
    return unless date.kind_of?(String) and date.match(/\d{8}/)
    get("#{Settings.url}/race/list/#{date}")
  end

  def get_race(race_id)
    return unless race_id.kind_of?(String)
    get("#{Settings.url}/race/#{race_id}")
  end

  def get_horse(horse_id)
    return unless horse_id.kind_of?(String) or horse_id.kind_of?(Fixnum)
    get("#{Settings.url}/horse/#{horse_id}")
  end

  private

  def get(url)
    parsed_url = URI.parse(url)
    Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
  end
end
