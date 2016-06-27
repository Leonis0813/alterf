require_relative '../settings/settings.rb'
require_relative '../client/http.rb'
require 'fileutils'

def output_horse(file_id)
  output_dir = File.join(Settings.raw_data_path, 'horses')
  FileUtils.mkdir_p(output_dir)

  race_result_file = File.join(Settings.raw_data_path, 'results', "#{file_id}.html")
  horse_paths = File.read(race_result_file).scan(/\/horse\/\d+/)

  [].tap do |horse_ids|
    horse_paths.each do |path|
      horse_id = path.match(/\/horse\/(\d+)/)[1]
      next if File.exists?(File.join(output_dir, "#{horse_id}.html"))

      res = HTTPClient.new.get_horse(horse_id)

      File.open(File.join(output_dir, "#{horse_id}.html"), "w:utf-8") do |out|
        res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
          out.puts line
        end
      end

      horse_ids << horse_id
    end
  end
end
