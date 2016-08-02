require_relative '../settings/settings'
require_relative '../client/http'

def output_race(race_path)
  races_dir = File.join(Settings.backup_path, 'races')
  race_id = race_path.delete('/race/')

  unless File.exists?(File.join(races_dir, "#{race_id}.html"))
    res = HTTPClient.new.get_race(race_id)

    File.open(File.join(races_dir, "#{race_id}.html"), "w:utf-8") do |out|
      res.body.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?').split("\n").each do |line|
        out.puts(line)
      end
    end
  end
end
