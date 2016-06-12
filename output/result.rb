require_relative '../config/settings.rb'
require_relative '../http/client.rb'
require 'date'
require 'fileutils'

def output_race_result(date)
  data_dir = File.join(Settings.application_root, 'raw_data')
  race_list_file = File.join(data_dir, 'races', "#{Date.parse(date).strftime('%Y%m%d')}.txt")
  race_result_dir = File.join(data_dir, 'results')
  FileUtils.mkdir_p(race_result_dir)

  [].tap do |race_ids|
    return [] unless File.exists?(race_list_file)

    File.open(race_list_file, 'r') do |file|
      file.each_line do |path|
        race_id = path.match(/\/race\/(\d+)/)[1]
        race_ids << race_id
        next if File.exists?(File.join(race_result_dir, "#{race_id}.html"))

        res = HTTPClient.new.get_race_result(race_id)
        
        File.open(File.join(race_result_dir, "#{race_id}.html"), "w:utf-8") do |out|
          res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
            out.puts line
          end
        end
      end
    end
  end
end
