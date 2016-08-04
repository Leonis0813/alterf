require 'net/http'
require_relative '../settings/settings'

def fetch(resource_type, id)
  parsed_url = URI.parse("#{Settings.url}#{Settings.path[resource_type]}/#{id}")
  Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
    http.request Net::HTTP::Get.new(parsed_url)
  end.body
end
