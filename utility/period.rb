require_relative '../settings/settings'
require 'date'

from = Date.parse('1988-01-01')
to = Date.today
begin
  from = Date.parse(ARGV[0]) if ARGV[0]
  to = Date.parse(ARGV[1]) if ARGV[1]
rescue => e
  puts e
  return
end

(from..to).each do |date|
  system "ruby #{Settings.application_root}/alterf.rb #{date.strftime('%Y-%m-%d')}"
end
