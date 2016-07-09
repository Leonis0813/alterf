# coding: utf-8
class HTML
  class << self
    def parse(obj, html)
      send(obj, html)
    end

    private

    def race(html)
      race_data = html.scan(/<dl class="racedata.*?\/dl>/).first

      {}.tap do |attribute|
        attribute[:name] = race_data.match(/<h1>(.*)<\/h1>/)[1].gsub(/<.*?>/, '').strip

        condition = race_data.match(/<span>(.*)<\/span>/)[1].split(' / ')
        attribute[:track] = condition.first[0].sub('ダ', 'ダート')
        attribute[:direction] = condition.first[1]
        attribute[:distance] = condition.first.match(/(\d*)m$/)[1].to_i
        attribute[:weather] = condition[1].match(/天候 : (.*)/)[1]
        attribute[:track_condition] = condition[2].match(/[ダート|芝] : (.*)/)[1]

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
    end

    def entry(html)
      entries = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

      entries.map do |entry|
        features = entry.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
        features.map! {|feature| feature.gsub(/<.*?>/, '') }

        {}.tap do |attribute|
          attribute[:number] = features[2].to_i
          attribute[:bracket] = features[1].to_i
          attribute[:age] = features[4].match(/(\d+)\z/)[1].to_i
          attribute[:jockey] = features[6]
          attribute[:burden_weight] = features[5].to_f
          attribute[:weight] = features[14].match(/\A(\d+)/)[1].to_f unless features[14] == '計不'
        end
      end
    end

    def result(html)

    end

    def payoff(html)

    end
  end
end
