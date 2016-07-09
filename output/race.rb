require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_race(race_path)
  races_dir = File.join(Settings.raw_data_path, 'races')
  race_id = race_path.delete('/race/')

  unless File.exists?(File.join(races_dir, "#{race_id}.html"))
    res = HTTPClient.new.get_race(race_path)

    File.open(File.join(races_dir, "#{race_id}.html"), "w:utf-8") do |out|
      res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
        out.puts(line)
      end
    end
  end
end
