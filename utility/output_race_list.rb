require_relative '../output/race_list'
require 'date'

from = Date.parse('1980-01-01')
to = Date.today
begin
  from = Date.parse(ARGV[0]) if ARGV[0]
  to = Date.parse(ARGV[1]) if ARGV[1]
rescue => e
  puts e
  return
end

(from..to).each {|date| output_race_list(date.strftime('%Y-%m-%d')) }
