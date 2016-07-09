require 'date'
require 'fileutils'
Dir['{import,output}/*.rb'].each {|file| require_relative file }

date = (ARGV[0] ? Date.parse(ARGV[0]) : Date.today).strftime('%Y%m%d')

output_races(date)

file_path = File.join(Settings.raw_data_path, "races/#{date}.html")
result_dir = File.join(Settings.raw_data_path, 'results')
FileUtils.mkdir_p(result_dir)

File.read(file_path).split("\n").each do |race_path|
  output_result(race_path)
  import_result(race_path)
end
