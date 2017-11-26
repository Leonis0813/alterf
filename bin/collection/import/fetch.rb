require 'net/http'
require_relative '../config/settings'
require_relative '../lib/logger'

def fetch(resource, id)
  files = Dir[File.join(Settings.backup_dir[resource], "#{id}.*")]
  if files.empty?
    parsed_url = URI.parse("#{Settings.url}#{Settings.path[resource]}/#{id}")
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
    Logger.info(:action => 'fetch', :resource => resource, :status => res.code, :uri => res.uri.to_s)
    res.body
  else
    Logger.info(:action => 'fetch', :resource => resource, :message => 'already_exist', :path => files.first)
    nil
  end
end
