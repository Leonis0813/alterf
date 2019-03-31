# coding: utf-8
class PredictionJob < ActiveJob::Base
  queue_as :alterf

  TEST_DATA_FILE_NAME = 'test_data.yml'

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = "#{Rails.root}/tmp/files/#{prediction_id}"
    test_data = prediction.test_data
    if prediction.test_data.match(URI::regexp)
      begin
        generate_test_data(prediction.test_data, "#{data_dir}/#{TEST_DATA_FILE_NAME}")
      rescue Exception => e
        PredictionMailer.finished(prediction, false).deliver_now
        raise e
      end
      test_data = TEST_DATA_FILE_NAME
    end
    args = [prediction_id, prediction.model, test_data]
    ret = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
    prediction.update!(:state => 'completed')
    PredictionMailer.finished(prediction, ret).deliver_now
    FileUtils.rm_rf(data_dir)
  end

  private

  def generate_test_data(url, output_path)
    parsed_url = URI.parse(url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port, :use_ssl => true) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
    html = Nokogiri::HTML.parse(res.body.encode('UTF-8', 'EUC-JP').gsub('&nbsp;', ' '))
    feature = extract_feature(html)

    File.open(output_path, 'w') do |f|
      f.puts "direction: #{feature[:direction]}"
      f.puts "distance: #{feature[:distance]}"
      f.puts "grade: #{feature[:grade]}"
      f.puts "place: #{feature[:place]}"
      f.puts "round: #{feature[:round]}"
      f.puts "track: #{feature[:track]}"
      f.puts "weather: #{feature[:weather]}"

      f.puts 'test_data:'
      feature[:test_data].each do |test_data|
        f.puts "  - #{test_data}"
      end
    end
  end

  def extract_feature(html)
    {}.tap do |feature|
      race_data = html.xpath('//dl[contains(@class, "racedata")]')

      track, weather, _ = race_data.search('span').text.split('/')
      feature[:track] = track[0].sub('ダ', 'ダート')
      feature[:direction] = track[1]
      feature[:distance] = track.match(/(\d*)m/)[1].to_i
      feature[:weather] = weather.match(/天候 : (.*)/)[1]
      feature[:grade] = race_data.search('h1').text.match(/\((.*)\)$/).try(:[], 1)
      feature[:place] = html.xpath('//ul[contains(@class, "race_place")]').first
                        .children[1].text.match(/<a.*class="active">(.*?)<\/a>/)[1]
      feature[:round] = race_data.search('dt').text.strip.match(/^(\d*) R$/)[1].to_i

      _, *data = race_data.xpath('//table[contains(@class, "race_table")]').search('tr')
      feature[:test_data] = data.map do |entry|
        attributes = entry.search('td').map(&:text).map(&:strip)

        [
          attributes[4].match(/(\d+)\z/)[1].to_i,
          attributes[5].to_f,
          attributes[2].to_i,
          attributes[14].match(/\A(\d+)/).try(:[], 1).to_f,
          attributes[14].match(/\((.+)\)$/).try(:[], 1).to_f,
        ]
      end
    end
  end
end
