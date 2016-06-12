# coding: utf-8
require_relative '../config/settings.rb'
require 'mysql2'

class Horse
  attr_accessor :id, :name, :trainer, :owner, :birthday, :breeder, :growing_area
  attr_accessor :central_prize, :local_prize, :first, :second, :third, :total_race
  attr_accessor :father_id, :mother_id

  def initialize(html_file)
    raw_html = File.read(html_file)
    html = raw_html.gsub("\n", '').gsub('&nbsp;', ' ')
    profile = html.scan(/db_prof_table.*?(<.*?)<\/table>/).flatten
    profile = profile.first.scan(/<td>.*?<\/td>/).map{|td| td.gsub(/<.*?>/, '') }

    pedigree = html.scan(/blood_table.*?(<.*?)<\/table>/).flatten
    pedigree = pedigree.first.scan(/<td.*?<\/td>/).map{|td| td.gsub(/<.*?>/, '') }

    @name = html.scan(/horse_title.*<h1>(.*?)<\/h1>/).flatten.first.gsub(/　| /, '')
    @name = @name.sub(/\A.*[地|外|抽|父|市]/, '')
    @trainer = profile[1]
    @owner = profile[2]
    @birthday = profile[0].gsub(/年|月/, '-').gsub('日', '')
    @breeder = profile[3]
    @growing_area = profile[4]
    @central_prize = (profile[6].gsub(',', '').to_f * 10000).to_i
    @local_prize = (profile[7].gsub(',', '').to_f * 10000).to_i
    total_prize, prizes = profile[8].split(' ')
    @first = prizes.match(/\[(\d+)-\d+-\d+-\d+\]/)[1]
    @second = prizes.match(/\[\d+-(\d+)-\d+-\d+\]/)[1]
    @third = prizes.match(/\[\d+-\d+-(\d+)-\d+\]/)[1]
    @total_race = total_prize.match(/(\d+)戦/)[1]
    @father_id = get_parent_id(pedigree[0])
    @mother_id = get_parent_id(pedigree[1])
  end

  def save!
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
INSERT INTO
  horses
VALUES (
  NULL,
  '#{@name}',
  '#{@trainer}',
  '#{@owner}',
  '#{@birthday}',
  '#{@breeder}',
  '#{@growing_area}',
  #{@central_prize},
  #{@local_prize},
  #{@first},
  #{@second},
  #{@third},
  #{@total_race},
  #{@father_id || 'NULL'},
  #{@mother_id || 'NULL'}
)
EOF
    begin
      client.query(query)
      @id = client.last_id
      client.close
    rescue
    end
  end

  private

  def get_parent_id(parent_name)
    client = Mysql2::Client.new(Settings.mysql)
    query =<<"EOF"
SELECT
  id
FROM
  horses
WHERE
  name = #{parent_name}
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
