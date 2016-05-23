# coding: utf-8
require 'mysql2'

APPLICATION_ROOT = File.expand_path(File.dirname('..'))
HTML_DIR = File.join(APPLICATION_ROOT, 'data/results')
CLIENT = Mysql2::Client.new(:host => "localhost", :username => "root", :password => "7QiSlC?4", :database => 'alterf')

Dir[File.join(HTML_DIR, '201608010112.html')].sort.each do |html_file|
  begin
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)
    results.map! do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map!{|feature| feature.gsub(/<.*?>/, '') }
      features.select{|feature| not feature.empty? }
    end
    puts results
    results.each do |result|
      number = result[0]
      order = result[1]
      popularity = result[2]
      weight = result[5]
      jockey = result[6]
      time = result[7]
      margin = result[8]
=begin
    third_corner
    forth_corner
    slope
    odds
    age
    burden_weight
=end
      query =<<"EOF"
INSERT INTO
  race_features
VALUES (
  NULL, '#{name}', '#{track}', '#{direction}', #{distance}, '#{weather}', '#{track_condition}', '#{start_time}', '#{place}', #{round}, #{num_of_horse}
)
EOF
  CLIENT.query(query)
    end
  rescue
    next
  end
end

CLIENT.close
