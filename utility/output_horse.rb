require_relative '../output/horse.rb'

file_path = ARGV[0]
matched_data = file_path.match(/\/(?<file_id>\d+)\.txt\z/)
exit unless matched_data
output_horse(matched_data[:file_id])
