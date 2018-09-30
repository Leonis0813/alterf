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
    require "#{Rails.root}/lib/html"

    parsed_url = URI.parse(url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
    parsed_body = HTML.parse(res.body)
    File.open(output_path, 'w') do |f|
      f.puts "direction: #{parsed_body[:direction]}"
      f.puts "distance: #{parsed_body[:distance]}"
      f.puts "grade: #{parsed_body[:grade]}"
      f.puts "place: #{parsed_body[:place]}"
      f.puts "round: #{parsed_body[:round]}"
      f.puts "track: #{parsed_body[:track]}"
      f.puts "weather: #{parsed_body[:weather]}"

      f.puts 'test_data:'
      parsed_body[:test_data].each do |test_data|
        f.puts "  - #{test_data}"
      end
    end
  end
end
