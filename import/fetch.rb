require 'net/http'
require_relative '../config/settings'

def fetch(resource, id)
  return unless Dir[File.join(Settings.backup_dir[resource], "#{id}.*")].empty?
  parsed_url = URI.parse("#{Settings.url}#{Settings.path[resource]}/#{id}")
  Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
    http.request Net::HTTP::Get.new(parsed_url)
  end.body
end
