require_relative '../config/settings.rb'
require 'fileutils'
require 'net/http'

OUTPUT_DIR = File.join(Settings.application_root, 'raw_data/results')

filename = ARGV[0] ? ARGV[0] : '*'

FileUtils.mkdir_p(OUTPUT_DIR)

Dir[File.join(Settings.application_root, 'raw_data/races', "#{filename}.txt")].sort.each do |file|
  File.open(file, 'r') do |file|
    file.each_line do |path|
      parsed_url = URI.parse("#{Settings.url}#{path.chomp}")

      res = Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
        http.request Net::HTTP::Get.new(parsed_url)
      end

      File.open(File.join(OUTPUT_DIR, "#{path.match(/\/race\/(\d+)/)[1]}.html"), "w:utf-8") do |out|
        res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
          out.puts line
        end
      end
    end
  end
end
