require 'date'
require 'net/http'

APPLICATION_ROOT = File.expand_path(File.dirname('..'))
OUTPUT_DIR = File.join(APPLICATION_ROOT, 'data/results')
BASE_URL = 'http://db.netkeiba.com'

Dir.mkdir(OUTPUT_DIR) unless File.exist?(OUTPUT_DIR)

filename = ARGV[0] ? ARGV[0] : '*'
Dir[File.join(APPLICATION_ROOT, 'data/races', "#{filename}.txt")].sort.each do |file|
  File.open(file, 'r') do |file|
    file.each_line do |path|
      parsed_url = URI.parse("#{BASE_URL}#{path.chomp}")

      res = Net::HTTP.start(parsed_url.host, parsed_url.port) {|http| http.request Net::HTTP::Get.new(parsed_url) }

      File.open(File.join(OUTPUT_DIR, "#{path.match(/\/race\/(\d+)/)[1]}.html"), "w:utf-8") do |out|
        res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
          out.puts line
        end
      end
    end
  end
end
