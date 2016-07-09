require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_result(race_path)
  result_dir = File.join(Settings.raw_data_path, 'results')
  race_id = race_path.delete('/race/')

  unless File.exists?(File.join(result_dir, "#{race_id}.html"))
    res = HTTPClient.new.get_race_result(race_path)
        
    File.open(File.join(result_dir, "#{race_id}.html"), "w:utf-8") do |out|
      res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
        out.puts line
      end
    end
  end
end
