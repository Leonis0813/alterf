require 'date'
require 'fileutils'
Dir['{import,output}/*.rb'].each {|file| require_relative file }

date = (ARGV[0] ? Date.parse(ARGV[0]) : Date.today).strftime('%Y%m%d')

race_list_dir = File.join(Settings.backup_path, 'race_list')
FileUtils.mkdir_p(race_list_dir)
output_race_list(date)

race_list_file = File.join(race_list_dir, "#{date}.txt")
if File.exists?(race_list_file)
  races_dir = File.join(Settings.backup_path, 'races')
  FileUtils.mkdir_p(races_dir)

  File.read(race_list_file).split("\n").each do |race_path|
    output_race(race_path)
    import_race(race_path.delete('/race/'))
  end
end
