require_relative '../../lib/logger'

def parse_race_list(html)
  races = html.scan(%r[.*/race/(\d+)]).flatten
  Logger.write(
    File.basename(__FILE__, '.rb'),
    'extract',
    {:'#_of_races' => races.size, :from => races.first, :to => races.last}
  )
  races
end
