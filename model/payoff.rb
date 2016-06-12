# coding: utf-8
require_relative '../settings/settings.rb'
require_relative '../client/mysql.rb'
require 'mysql2'

class Payoff
  attr_accessor :id, :race_id, :prize_name, :money, :popularity

  def initialize(html, payoff)
    race_name = html.scan(/race_data.*?<h1>(.*?)<\/h1>/).flatten.first.gsub(/<.*?>/, '').strip
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1].gsub(/年|月/, '-').sub('日', '')
    start_time = html.scan(/<dl class="racedata.*?\/dl>/).first.match(/<span>(.*)<\/span>/)[1].split(' / ')[3].match(/発走 : (.*)/)[1]
    @race_id ||= MysqlClient.new.get_race_id(race_name, "#{race_date} #{start_time}:00")
    @prize_name, @money, @popularity = payoff[0], payoff[1].to_i, payoff[2].to_i
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  payoffs
VALUES (
  NULL,
  '#{@race_id}',
  '#{@prize_name}',
  #{@money},
  #{@popularity}
)
EOF
    begin
      client.query(query)
      client.close
    rescue
    end
  end

  def self.create_all_payoffs(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    payoff_string = html.match(/pay_block.*?>(.*?)<\/dl>/)[1]
    payoffs = payoff_string.scan(/<tr>.*?<\/tr>/)
    payoffs.map!{|p| p.scan(/<t[d|h].*?>(.*?)<\/t[d|h]>/).flatten }
    payoffs.each {|p| p.map!{|p0| p0.gsub(/<.*?>/, '|') } }

    payoffs.each do |payoff|
      payoff[1].split('|').each_with_index do |_, i|
        money = payoff[2].split('|')[i].gsub(',', '')
        popularity = payoff[3].split('|')[i]
        p = [payoff[0], money, popularity]
        self.new(html, p).save!
      end
    end
  end
end
