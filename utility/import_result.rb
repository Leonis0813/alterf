require_relative '../import/result.rb'

file_path = ARGV[0]
matched_data = file_path.match(/\/(?<file_id>\d+)\.html\z/)
exit unless matched_data
import_result(matched_data[:file_id])
