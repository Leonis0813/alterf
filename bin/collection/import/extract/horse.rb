# coding: utf-8
require_relative '../../lib/logger'

def parse_horse(html)
  html.gsub!("\n", '')
  html.gsub!('&nbsp;', ' ')
  profile = html.scan(/db_prof_table.*?(<.*?)<\/table>/).flatten
  profile = profile.first.scan(/<td>.*?<\/td>/).map {|td| td.gsub(/<.*?>/, '') }

  horse = {}.tap do |attribute|
    name = html.scan(/horse_title.*<h1>(.*?)<\/h1>/).flatten.first.gsub(/　| /, '')
    attribute[:name] = name.sub(/\A.*[地|外|抽|父|市]/, '')
    attribute[:trainer] = profile[1]
    attribute[:owner] = profile[2]
    attribute[:birthday] = profile[0].gsub(/年|月/, '-').gsub('日', '')
    attribute[:breeder] = profile[3]
    attribute[:growing_area]= profile[4]
    attribute[:central_prize] = (profile[6].gsub(',', '').to_f * 10000).to_i
    attribute[:local_prize] = (profile[7].gsub(',', '').to_f * 10000).to_i
    total_prize, prizes = profile[8].split(' ')
    attribute[:first] = prizes.match(/\[(\d+)-\d+-\d+-\d+\]/)[1]
    attribute[:second] = prizes.match(/\[\d+-(\d+)-\d+-\d+\]/)[1]
    attribute[:third] = prizes.match(/\[\d+-\d+-(\d+)-\d+\]/)[1]
    attribute[:total_race] = total_prize.match(/(\d+)戦/)[1]
    attribute[:father_id] =  'NULL'
    attribute[:mother_id] =  'NULL'
  end

  Logger.info(
    :action => 'extract',
    :resource => 'horse',
    :name => horse[:name],
    :birthday => horse[:birthday]
  )

  horse
end
