# coding: utf-8
require_relative '../../lib/logger'

def parse_result(html)
  html.gsub!("\n", '')
  html.gsub!('&nbsp;', ' ')
  results = html.scan(/<table class="race_table.*?<\/table>/).first.scan(/<tr>.*?<\/tr>/)

  results.map! do |result|
    features = result.gsub(/<[\/]?tr>/, '').scan(/<td.*?>(.*?)<\/td>/).flatten
    features.map! {|feature| feature.gsub(/<.*?>/, '') }

    {}.tap do |attribute|
      attribute[:order] = features[0]
      attribute[:time] = if attribute[:order] =~ /\A\d+\z/
                           minute, second = features[7].split(':')
                           sec, msec = second.split('.')
                           minute.to_i * 60 + sec.to_i + msec.to_f / 10
                         else
                           0.0
                         end
      attribute[:margin] = features[8]
      corners = features[10].split('-')
      attribute[:third_corner] = corners[-2] || "''"
      attribute[:forth_corner] = corners[-1] || "''"
      attribute[:slope] = features[11].empty? ? 0.0 : features[11].to_f
      attribute[:odds] = features[12] =~ /\A\d+\.\d+\z/ ? features[12].to_f : 0.0
      attribute[:popularity] = features[13].empty? ? 0 : features[13].to_i
    end
  end

  Logger.info(:action => 'extract', :resource => 'result', :'#_of_results' => results.size)

  results
end
