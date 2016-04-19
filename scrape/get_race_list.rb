require 'date'
require 'net/http'

OUTPUT_DIR = File.join(File.expand_path(File.dirname('..')), 'data/races')
BASE_URL = 'http://db.netkeiba.com/race/list'

from = ARGV[0] ? ARGV[0] : '1988/01/05'
to = ARGV[1] ? ARGV[1] : Time.now.strftime('%Y/%m/%d')
(Date.parse(from)..Date.parse(to)).each do |date|
  parsed_url = URI.parse("#{BASE_URL}/#{date.strftime('%Y%m%d')}")

  res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request Net::HTTP::Get.new(parsed_url) }

  races = res.body.scan(%r[.*(/race/\d+)]).flatten
  unless races.empty?
    File.mkdir(OUTPUT_DIR) unless File.exist?(OUTPUT_DIR)
    File.open(File.join(OUTPUT_DIR, "#{date.strftime('%Y%m%d')}.txt"), 'w') do |out|
      races.each {|race| out.puts(race) }
    end
  end
end

