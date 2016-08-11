# coding: utf-8
def parse_entry(html)
  entries = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

  entries.map do |entry|
    features = entry.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
    features.map! {|feature| feature.gsub(/<.*?>/, '') }

    {}.tap do |attribute|
      attribute[:number] = features[2].to_i
      attribute[:bracket] = features[1].to_i
      attribute[:age] = features[4].match(/(\d+)\z/)[1].to_i
      attribute[:jockey] = features[6]
      attribute[:burden_weight] = features[5].to_f
      attribute[:weight] = features[14].match(/\A(\d+)/)[1].to_f unless features[14] == '計不'
      attribute[:external_id] = entry.scan(/href="\/horse\/(\d*)\/"/).flatten.first.to_i
    end
  end
end
