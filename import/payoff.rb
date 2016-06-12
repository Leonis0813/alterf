require_relative '../config/settings.rb'
require_relative '../model/payoff.rb'

def import_payoff(file_id)
  html_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  Payoff.create_all_entries(html_file)
end
