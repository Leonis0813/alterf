# coding: utf-8
class HTML
  def self.parse(html)
    html = html.encode("utf-8", "euc-jp", :undef => :replace, :replace => '?')
    html.gsub!("\n", '')
    html.gsub!('&nbsp;', ' ')
    race_data = html.scan(/<dl class="racedata.*?\/dl>/).first
    condition = race_data.match(/<span>(.*)<\/span>/)[1].split(' / ')
    place = html.scan(/<ul class="race_place.*?<\/ul>/).first

    race = {}
    race[:track] = condition.first[0].sub('ダ', 'ダート')
    race[:direction] = condition.first[1]
    race[:distance] = condition.first.match(/(\d*)m$/)[1].to_i
    race[:weather] = condition[1].match(/天候 : (.*)/)[1]
    race[:place] = place.match(/<a href=.* class="active">(.*?)<\/a>/)[1]
    race[:round] = race_data.match(/<dt>(\d*) R<\/dt>/)[1].to_i

    entries = []
    entries_html = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)
    entries_html.each do |entry_html|
      attributes = entry_html.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
      attributes.map! {|attribute| attribute.gsub(/<.*?>/, '') }

      entry = []
      entry << attributes[4].match(/(\d+)\z/)[1].to_i
      entry << attributes[2].to_i
      entry << (attributes[14] == '計不' ? nil : attributes[14].match(/\A(\d+)/)[1].to_f rescue nil)
      entry << attributes[5].to_f

      entries << entry
    end

    race.merge(:test_data => entries)
  end
end
