require 'fileutils'
require_relative '../settings/settings.rb'
require_relative '../client/http.rb'

def output_horse(horse_id)
  horses_dir = File.join(Settings.backup_path, 'horses')
  FileUtils.mkdir_p(horses_dir)

  horse_file = File.join(horses_dir, "#{horse_id}.html")
  return if File.exists?(horse_file) and not File.zero?(horse_file)
  res = HTTPClient.new.get_horse(horse_id)

  File.open(File.join(horses_dir, "#{horse_id}.html"), "w:utf-8") do |out|
    res.body.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?').split("\n").each do |line|
      out.puts(line)
    end
  end
end
