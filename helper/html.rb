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

    def horse(html)
      profile = html.scan(/db_prof_table.*?(<.*?)<\/table>/).flatten
      profile = profile.first.scan(/<td>.*?<\/td>/).map{|td| td.gsub(/<.*?>/, '') }

      {}.tap do |attribute|
        name = html.scan(/horse_title.*<h1>(.*?)<\/h1>/).flatten.first.gsub(/　| /, '')
        attribute[:name] = name.sub(/\A.*[地|外|抽|父|市]/, '')
        attribute[:trainer] = profile[1]
        attribute[:owner] = profile[2]
        attribute[:birthday] = profile[0].gsub(/年|月/, '-').gsub('日', '')
        attribute[:breeder] = profile[3]
        attribute[:growing_area]= profile[4]
        attribute[:central_prize] = (profile[6].gsub(',', '').to_f * 10000).to_i
        attribute[:local_prize] = (profile[7].gsub(',', '').to_f * 10000).to_i
        attribute[:total_prize], prizes = profile[8].split(' ')
        attribute[:first] = prizes.match(/\[(\d+)-\d+-\d+-\d+\]/)[1]
        attribute[:second] = prizes.match(/\[\d+-(\d+)-\d+-\d+\]/)[1]
        attribute[:third] = prizes.match(/\[\d+-\d+-(\d+)-\d+\]/)[1]
        attribute[:total_race] = total_prize.match(/(\d+)戦/)[1]
      end
    end

    def result(html)
      results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

      results.map do |result|
        features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
        features.map! {|feature| feature.gsub(/<.*?>/, '') }

        {}.tap do |attribute|
          attribute[:order] = features[0]
          attribute[:time] = if attribute[:order] =~ /\A\d+\z/
                               minute, second = features[7].split(':')
                               sec, msec = second.split('.')
                               minute.to_i * 60 + sec.to_i + msec.to_f / 10
                             else
                               0.0
                             end
          attribute[:margin] = features[8]
          corners = features[10].split('-')
          attribute[:third_corner] = corners[-2] || "''"
          attribute[:forth_corner] = corners[-1] || "''"
          attribute[:slope] = features[11].empty? ? 0.0 : features[11].to_f
          attribute[:odds] = features[12] =~ /\A\d+\.\d+\z/ ? features[12].to_f : 0.0
          attribute[:popularity] = features[13].empty? ? 0 : features[13].to_i
        end
      end
    end

    def payoff(html)
      payoffs = html.match(/pay_block.*?>(.*?)<\/dl>/)[1].scan(/<tr>.*?<\/tr>/)
      payoffs.map! {|payoff| payoff.scan(/<t[d|h].*?>(.*?)<\/t[d|h]>/).flatten }
      payoffs.each {|payoff| payoff.map! {|p| p.gsub(/<.*?>/, '|') } }

      [].tap do |array|
        payoffs.each do |payoff|
          payoff[1].split('|').size.times do |i|
            array << {}.tap do |attribute|
              attribute[:prize_name] = payoff[0]
              attribute[:money] = payoff[2].split('|')[i].gsub(',', '').to_i
              attribute[:popularity] = payoff[3].split('|')[i].to_i
            end
          end
        end
      end
    end
  end
end
