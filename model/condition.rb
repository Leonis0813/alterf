# coding: utf-8
require_relative '../settings/settings.rb'
require 'mysql2'

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
    return nil if @track == '障'

    client = Mysql2::Client.new(Settings.mysql)
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
      self
    rescue => e
      p e.message
      raise
    end
  end
end
