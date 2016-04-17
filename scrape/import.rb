require 'date'
require 'net/http'

BASE_URL = 'http://db.netkeiba.com'
begin_date =  Date.parse('1988/01/05')
end_date =  Date.parse(Time.now.strftime('%Y/%m/%d'))
(begin_date..end_date).each do |date|
  parsed_url = URI.parse("#{BASE_URL}/race/list/#{date.strftime('%Y%m%d')}")

  req = Net::HTTP::Get.new(parsed_url)
  res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request req }

  race_list = res.body.scan(%r[.*(/race/\d+)]).flatten
  File.open("races_#{date.strftime('%Y%m%d')}.txt", 'w') do |out|
    race_list.each {|race| out.puts(race) }
  end
end

