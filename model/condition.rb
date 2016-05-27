# coding: utf-8
require_relative '../config/settings.rb'
require 'mysql2'

HTML_DIR = File.join(Settings.application_root, 'raw_data/results')

class Condition
  attr_accessor :id, :name, :track, :direction, :distance, :weather
  attr_accessor :track_condition, :place, :round, :start_time, :num_of_horse

  def initialize(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    racedata = html.scan(/<dl class="racedata.*?\/dl>/).first

    @name = racedata.match(/<h1>(.*)<\/h1>/)[1].gsub(/<.*?>/, '').strip
    @track = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first[0].sub('ダ', 'ダート')
    @direction = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first[1]
    @distance = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first.match(/(\d*)m$/)[1]
    @weather = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[1].match(/天候 : (.*)/)[1]
    @track_condition = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[2].match(/[ダート|芝] : (.*)/)[1]
    start_time = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[3].match(/発走 : (.*)/)[1]
    @place = html.scan(/<ul class="race_place.*?<\/ul>/).first.match(/<a href=.* class="active">(.*?)<\/a>/)[1]
    @round = racedata.match(/<dt>(\d*) R<\/dt>/)[1]
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1].gsub(/年|月/, '-').sub('日', '')
    @start_time = "#{race_date} #{start_time}:00"
    @num_of_horse = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/).size
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
  conditions
VALUES (
  NULL,
  '#{@name}',
  '#{@track}',
  '#{@direction}',
  #{@distance},
  '#{@weather}',
  '#{@track_condition}',
  '#{@start_time}',
  '#{@place}',
  #{@round},
  #{@num_of_horse}
)
EOF
    begin
      client.query(query)
      @id = client.last_id
      client.close
    rescue
    end
  end
end

require_relative  'result.rb'
Dir[File.join(HTML_DIR, '201610010812.html')].sort.each do |html_file|
  race = Race.new(html_file)
  race.save!

  result = Result.new(html_file)
  result.race_id = race.id
end
