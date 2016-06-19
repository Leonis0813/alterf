require_relative '../settings/settings.rb'
require_relative '../model/entry.rb'

def import_entry(file_id)
  html_file = File.join(Settings.raw_data_path, "results/#{file_id}.html")
  Entry.create_all_entries(html_file)
end
