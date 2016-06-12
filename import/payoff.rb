require_relative '../settings/settings.rb'
require_relative '../model/payoff.rb'

def import_payoff(file_id)
  html_file = File.join(Settings.application_root, 'raw_data/results', "#{file_id}.html")
  Payoff.create_all_payoffs(html_file)
end
