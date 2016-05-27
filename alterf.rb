require_relative 'config/settings.rb'
require_relative 'http/client.rb'
require 'date'
require 'fileutils'

date = ARGV[0] ? ARGV[0] : Date.today.strftime('%Y-%m-%d')

def output_race_list(date)
  res = HTTPClient.new.get_race_list(date)
  races = res.body.scan(%r[.*(/race/\d+)]).flatten

  return if races.empty?

  output_dir = File.join(Settings.application_root, 'raw_data/races')
  FileUtils.mkdir_p(output_dir)
  File.open(File.join(output_dir, "#{Date.parse(date).strftime('%Y%m%d')}.txt"), 'w') do |out|
    races.each {|race| out.puts(race) }
  end
end

def output_race_result(date)
  data_dir = File.join(Settings.application_root, 'raw_data')
  race_list_file = File.join(data_dir, 'races', "#{Date.parse(date).strftime('%Y%m%d')}.txt")
  race_result_dir = File.join(data_dir, 'results')
  FileUtils.mkdir_p(race_result_dir)

  race_ids = []
  File.open(race_list_file, 'r') do |file|
    file.each_line do |path|
      race_id = path.match(/\/race\/(\d+)/)[1]
      res = HTTPClient.new.get_race_result(race_id)
        
      File.open(File.join(race_result_dir, "#{race_id}.html"), "w:utf-8") do |out|
        res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
          out.puts line
        end
      end

      race_ids << race_id
    end
  end
  race_ids
end

output_race_list(date)
race_ids = output_race_result(date)

race_ids.each do |race_id|
#  import_race_condition(race_id)
end
