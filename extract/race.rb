# coding: utf-8
require 'mysql2'

APPLICATION_ROOT = File.expand_path(File.dirname('..'))
HTML_DIR = File.join(APPLICATION_ROOT, 'data/results')
CLIENT = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'alterf')

Dir[File.join(HTML_DIR, '*.html')].sort.each do |html_file|
  begin
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    racedata = html.scan(/<dl class="racedata.*?\/dl>/).first

    name = racedata.match(/<h1>(.*)<\/h1>/)[1].gsub(/<.*?>/, '').strip
    track = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first[0].sub('ダ', 'ダート')
    next if track == '障'
    direction = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first[1]
    distance = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ').first.match(/(\d*)m$/)[1]
    weather = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[1].match(/天候 : (.*)/)[1]
    track_condition = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[2].match(/[ダート|芝] : (.*)/)[1]
    start_time = racedata.match(/<span>(.*)<\/span>/)[1].split(' / ')[3].match(/発走 : (.*)/)[1]
    place = html.scan(/<ul class="race_place.*?<\/ul>/).first.match(/<a href=.* class="active">(.*?)<\/a>/)[1]
    round = racedata.match(/<dt>(\d*) R<\/dt>/)[1]
    race_date = html.match(/<li class="result_link"><.*?>(\d*年\d*月\d*日)のレース結果<.*?>/)[1].gsub(/年|月/, '-').sub('日', '')
    start_time = "#{race_date} #{start_time}:00"
    num_of_horse = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/).size
  rescue
    next
  end
  query =<<"EOF"
INSERT INTO
  races
VALUES (
  NULL, '#{name}', '#{track}', '#{direction}', #{distance}, '#{weather}', '#{track_condition}', '#{start_time}', '#{place}', #{round}, #{num_of_horse}
)
EOF
  CLIENT.query(query)
end

CLIENT.close
