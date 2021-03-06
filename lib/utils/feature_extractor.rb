# coding: utf-8

module FeatureExtractor
  def extract_race(place, race_data, race_date)
    track, weather, = race_data.search('span').text.split('/')

    {
      direction: track[1] == '芝' ? '障' : track[1],
      distance: track.match(/(\d*)m/)[1].to_i,
      grade: race_data.search('h1').text.match(/\(([^\(\)]*)\)$/).try(:[], 1) || 'N',
      month: race_date[2].to_i,
      place: place.children.search('a[@class="active"]').text,
      race_name: race_data.search('dd/h1').text.strip,
      round: race_data.search('dt').text.strip.match(/^(\d*) R$/)[1].to_i,
      track: track[0].sub('ダ', 'ダート'),
      weather: weather.match(/天候 : (.*)/)[1].strip,
    }
  end

  def extract_entries(race_data)
    race_data.xpath('//table[contains(@class, "race_table")]/tr')[1..-1].map do |entry|
      row = entry.search('td')
      attributes = row.map(&:text).map(&:strip)
      links = row.children.search('a').map {|a| a.attribute('href').value }

      burden_weight = attributes[5].to_f
      weight = attributes[14].match(/\A(\d+)/).try(:[], 1).to_f

      {
        age: attributes[4].match(/(\d+)\z/)[1].to_i,
        burden_weight: burden_weight,
        order: attributes[0].to_i,
        number: attributes[2].to_i,
        sex: attributes[4].match(/\A([^\d]*)\d+/)[1],
        weight: weight,
        weight_diff: attributes[14].match(/\((.+)\)$/).try(:[], 1).to_f,
        weight_per: burden_weight / weight,
        horse_link: links.find {|link| link.match(%r{/horse}) },
        jockey_link: links.find {|link| link.match(%r{/jockey}) },
      }
    end
  end

  def extract_horse(table)
    bars = table.children.search('tr')[2].children.search('img').map do |img|
      [
        img.attribute('src').value.match(%r{([^/_]*).png})[1],
        img.attribute('width').value.to_i,
      ]
    end
    bars.delete_if {|bar| bar.first == 'centerline' }
    values = bars.map(&:last)
    rate = values[0, 2].inject(:+).to_f / values.inject(:+)

    running_style = if rate <= 0.25
                      '追込'
                    elsif rate <= 0.5
                      '先行'
                    elsif rate <= 0.75
                      '差し'
                    else
                      '逃げ'
                    end

    {running_style: running_style}
  end

  def extract_horse_results(table)
    table.children.search('tbody').children.search('tr').map do |row|
      td = row.children.search('td')

      {
        race_id: td[4].children.search('a').attribute('href').value
                      .match(%r{/race/(\d+)})[1],
        date: Date.parse(td[0].text.strip),
        order: td[11].text.strip.to_i,
        distance: td[14].text.strip.match(/(\d+)\z/)[1].to_i,
        prize_money: td[27].text.strip.delete(',').to_i * 10000,
      }
    end
  end

  def extract_jockey_results(table)
    table.children.search('tbody').children.search('tr').map do |row|
      td = row.children.search('td')

      {
        race_id: td[4].children.search('a').attribute('href').value
                      .match(%r{/race/(\d+)})[1],
        order: td[11].text.strip.to_i,
        prize_money: td[23].text.strip.delete(',').to_i * 10000,
      }
    end
  end
end
