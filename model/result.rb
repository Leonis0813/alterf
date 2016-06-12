# coding: utf-8
require_relative '../config/settings.rb'
require 'mysql2'

class Result
  attr_accessor :race_id, :horse_id, :order, :time, :margin, :third_corner, :forth_corner
  attr_accessor :slope, :odds, :popularity

  def initialize(html_file, horse_name)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)
    results.map! do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map{|feature| feature.gsub(/<.*?>/, '') }
    end
    result = results.find{|result| result[3] == horse_name }

    race_name = html.scan(/race_data.*?<h1>(.*?)<\/h1>/).flatten.first.gsub(/<.*?>/, '').strip
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1].gsub(/年|月/, '-').sub('日', '')
    start_time = html.scan(/<dl class="racedata.*?\/dl>/).first.match(/<span>(.*)<\/span>/)[1].split(' / ')[3].match(/発走 : (.*)/)[1]
    @race_id = get_race_id(race_name, "#{race_date} #{start_time}:00")
    @horse_id = get_horse_id(horse_name)
    @order = result[0]
    @time = if @order =~ /\A\d+\z/
              minute, second = result[7].split(':')
              sec, msec = second.split('.')
              minute.to_i * 60 + sec.to_i + msec.to_f / 10
            else
              0.0
            end
    @margin = result[8]
    @res = result[10]
    corners = result[10].split('-')
    @third_corner = corners[-2] || "''"
    @forth_corner = corners[-1] || "''"
    @slope = result[11].empty? ? 0.0 : result[11]
    @odds = result[12] =~ /\A\d+\.\d+\z/ ? result[12] : 0.0
    @popularity = result[13].empty? ? 0 : result[13]
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  results
VALUES (
  #{@race_id},
  #{@horse_id},
  '#{@order}',
  #{@time || 'NULL'},
  '#{@margin}',
  #{@third_corner},
  #{@forth_corner},
  #{@slope},
  #{@odds},
  #{@popularity}
)
EOF
    begin
      client.query(query)
      client.close
    rescue => e
      puts query
      puts @res
      puts e.message
    end
  end

  def self.create_all_entries(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

    horse_names = results.map do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map!{|feature| feature.gsub(/<.*?>/, '') }
      features[3]
    end

    horse_names.each {|horse_name| self.new(html_file, horse_name).save! }
  end
  
  private

  def get_race_id(race_name, start_time)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  conditions
WHERE
  name = '#{race_name}'
  AND start_time = '#{start_time}'
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result.first['id']
    rescue
    end
  end

  def get_horse_id(horse_name)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  name = '#{horse_name}'
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result.first['id']
     rescue
    end
  end
end
