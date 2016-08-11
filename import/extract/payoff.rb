# coding: utf-8
def parse_payoff(html)
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
