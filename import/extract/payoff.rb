require_relative '../../lib/logger'

def parse_payoff(html)
  html.gsub!("\n", '')
  html.gsub!('&nbsp;', ' ')
  payoffs = html.match(/pay_block.*?>(.*?)<\/dl>/)[1].scan(/<tr>.*?<\/tr>/)
  payoffs.map! {|payoff| payoff.scan(/<t[d|h].*?>(.*?)<\/t[d|h]>/).flatten }
  payoffs.each {|payoff| payoff.map! {|p| p.gsub(/<.*?>/, '|') } }

  payoffs = [].tap do |array|
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

  Logger.info(:action => 'extract', :resource => 'payoff', :'#_of_payoffs' => payoffs.size)

  payoffs
end
