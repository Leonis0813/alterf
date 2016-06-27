require_relative '../import/condition.rb'

file_path = ARGV[0]
matched_data = file_path.match(/\/(?<file_id>\d+)\.html\z/)
exit unless matched_data
import_condition(matched_data[:file_id])
