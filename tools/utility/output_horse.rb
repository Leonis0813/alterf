require_relative '../output/horse'

file_path = ARGV[0]
matched_data = file_path.match(/\/(?<file_id>\d+)\.html\z/)
exit unless matched_data
output_horse(matched_data[:file_id])
