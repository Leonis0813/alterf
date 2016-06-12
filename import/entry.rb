require_relative '../settings/settings.rb'
require_relative '../model/entry.rb'

def import_entry(file_id)
  html_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  Entry.create_all_entries(html_file)
end
