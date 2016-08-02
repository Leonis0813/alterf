require_relative '../import/entry'

file_path = ARGV[0]
matched_data = file_path.match(/\/(?<file_id>\d+)\.html\z/)
exit unless matched_data
import_entry(matched_data[:file_id])
