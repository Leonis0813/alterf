# coding: utf-8
require_relative '../../lib/logger'

def parse_race(html)
  html.gsub!("\n", '')
  html.gsub!('&nbsp;', ' ')
  race_data = html.scan(/<dl class="racedata.*?\/dl>/).first

  race = {}.tap do |attribute|
    attribute[:name] = race_data.match(/<h1>(.*)<\/h1>/)[1].gsub(/<.*?>/, '').strip

    condition = race_data.match(/<span>(.*)<\/span>/)[1].split(' / ')
    return unless condition.size == 4
    attribute[:track] = condition.first[0].sub('ダ', 'ダート')
    attribute[:direction] = condition.first[1]
    attribute[:distance] = condition.first.match(/(\d*)m$/)[1].to_i
    attribute[:weather] = condition[1].match(/天候 : (.*)/)[1]
    attribute[:condition] = condition[2].match(/[ダート|芝] : (.*)/)[1]

    start_time = condition[3].match(/発走 : (.*)/)[1]
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1]
    race_date = race_date.gsub(/年|月/, '-').sub('日', '')
    attribute[:start_time] = "#{race_date} #{start_time}:00"

    place = html.scan(/<ul class="race_place.*?<\/ul>/).first
    attribute[:place] = place.match(/<a href=.* class="active">(.*?)<\/a>/)[1]
    attribute[:round] = race_data.match(/<dt>(\d*) R<\/dt>/)[1].to_i
    horses = html.scan(/<table class="race_table.*?<\/table>/).first
    attribute[:num_of_horse] = horses.scan(/<tr>.*?<\/tr>/).size
  end

  Logger.info(
    :action => 'extract',
    :resource => 'race',
    :name => race[:name],
    :start_time => race[:start_time],
    :place => race[:place]
  )

  race
end
