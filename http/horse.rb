require_relative '../config/settings.rb'
require 'date'
require 'fileutils'
require 'net/http'

OUTPUT_DIR = File.join(Settings.application_root, 'raw_data/horses')

today = Time.now.strftime('%Y/%m/%d')
from = ARGV[0] ? ARGV[0] : (today - 24 * 60 * 60)
to = ARGV[1] ? ARGV[1] : today

(Date.parse(from)..Date.parse(to)).each do |date|
  parsed_url = URI.parse("#{Settings.url}/#{date.strftime('%Y%m%d')}")

  res = Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
    http.request Net::HTTP::Get.new(parsed_url)
  end

  races = res.body.scan(%r[.*(/race/\d+)]).flatten
  unless races.empty?
    FileUtils.mkdir_p(OUTPUT_DIR)
    File.open(File.join(OUTPUT_DIR, "#{date.strftime('%Y%m%d')}.txt"), 'w') do |out|
      races.each {|race| out.puts(race) }
    end
  end
end
