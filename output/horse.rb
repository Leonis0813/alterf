require 'fileutils'
require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_horse(horse_id)
  horses_dir = File.join(Settings.backup_path, 'horses')
  FileUtils.mkdir_p(horses_dir)

  return if File.exists?(File.join(horses_dir, "#{horse_id}.html"))

  res = HTTPClient.new.get_horse(horse_id)

  File.open(File.join(horses_dir, "#{horse_id}.html"), "w:utf-8") do |out|
    res.body.encode("utf-8", "euc-jp").split("\n").each do |line|
      out.puts(line)
    end
  end
end
