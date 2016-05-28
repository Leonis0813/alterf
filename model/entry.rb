# coding: utf-8
require_relative '../config/settings.rb'
require 'mysql2'

HTML_DIR = File.join(Settings.application_root, 'raw_data/results')

class Entry
  attr_accessor :race_id, :horse_id, :number, :bracket, :age, :jockey
  attr_accessor :burden_weight, :weight

  def initialize(html_file, horse_name)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)
    results.map! do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map{|feature| feature.gsub(/<.*?>/, '') }
    end
    entry = results.find{|result| result[3] == horse_name }

    race_name = html.scan(/race_data.*?<h1>(.*?)<\/h1>/).gsub(/<.*?>/, '').strip
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1].gsub(/年|月/, '-').sub('日', '')
    start_time = html.scan(/<dl class="racedata.*?\/dl>/).first.match(/<span>(.*)<\/span>/)[1].split(' / ')[3].match(/発走 : (.*)/)[1]
    @race_id = get_race_id(race_name, "#{race_date} #{start_time}:00")
    @horse_id = get_horse_id(horse_name)
    @number = entry[2]
    @bracket = entry[1]
    @age = entry[4].match(/(\d+)\z/)[1]
    @jockey = entry[6]
    @burden_weight = entry[5]
    @weight = entry[14].match(/\A(\d+)/)[1]
  end

  def save!
    mysql_conf = {
      :host => Settings.host,
      :username => Settings.username,
      :password => Settings.password,
      :database => Settings.database,
    }

    client = Mysql2::Client.new(mysql_conf)
    query =<<"EOF"
INSERT INTO
  results
VALUES (
  #{@race_id},
  #{@horse_id},
  #{@number},
  #{@bracket},
  #{@age},
  '#{@jockey}',
  #{@burden_weight},
  #{@weight}
)
EOF
    begin
      client.query(query)
      client.close
    rescue
    end
  end

  def self.create_all_entries(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

    horse_names = results.map do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map{|feature| feature.gsub(/<.*?>/, '') }
      features[3]
    end

    horse_names.each {|horse_name| self.new(html_file, horse_name).save! }
  end

  private

  def get_race_id(race_name, start_time)
    mysql_conf = {
      :host => Settings.host,
      :username => Settings.username,
      :password => Settings.password,
      :database => Settings.database,
    }

    client = Mysql2::Client.new(mysql_conf)
    query =<<"EOF"
SELECT
  id
FROM
  conditions
WHERE
  name = #{parent_name}
  AND start_time = #{start_time}
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result[:id]
    rescue
    end
  end

  def get_horse_id(horse_name)
    mysql_conf = {
      :host => Settings.host,
      :username => Settings.username,
      :password => Settings.password,
      :database => Settings.database,
    }

    client = Mysql2::Client.new(mysql_conf)
    query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  name = #{horse_name}
LIMIT 1
EOF
    begin
      result = client.query(query)
      client.close
      result[:id]
    rescue
    end
  end
end
