require_relative '../config/settings.rb'
require 'mysql2'

HTML_DIR = File.join(Settings.application_root, 'raw_data/results')

class Result
  attr_accessor :race_id, :horse_id, :order, :time, :margin, :third_corner, :forth_corner
  attr_accessor :slope, :odds, :popularity

  def initialize(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)
    results.map! do |result|
      features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      features.map{|feature| feature.gsub(/<.*?>/, '') }
    end

    results.each do |result|
      @order = result[0]
      minute, second = result[7].split(':')
      sec, msec = second.split('.')
      @time = minute.to_i * 60 + sec.to_i + msec.to_f / 10
      @margin = result[8]
      corners = result[10].split('-')
      @third_corner = corners[2]
      @forth_corner = corners[3]
      @slope = result[11]
      @odds = result[12]
      @popularity = result[13]
    end
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
  #{race_id},
  #{horse_id},
  #{order},
  #{time},
  '#{margin}',
  #{third_corner},
  #{forth_corner},
  #{slope},
  #{odds},
  #{popularity}
)
EOF
    begin
      client.query(query)
      client.close
    rescue
    end
  end
end

Dir[File.join(HTML_DIR, '201610010812.html')].sort.each do |html_file|
  Result.new(html_file).save!
end
