# coding: utf-8
class PredictionJob < ActiveJob::Base
  queue_as :alterf

  TEST_DATA_FILE_NAME = 'test_data.yml'

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    if prediction.test_data.match(URI::regexp)
      begin
        generate_test_data(prediction.test_data)
      rescue Exception => e
        PredictionMailer.finished(prediction, false).deliver_now
        raise e
      end
      prediction.test_data = TEST_DATA_FILE_NAME
    end
    args = [prediction_id, prediction.model, prediction.test_data]
    ret = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
    FileUtils.rm_rf("#{Rails.root}/tmp/files/#{prediction_id}")
    prediction.update!(:state => 'completed')
    PredictionMailer.finished(prediction, ret).deliver_now
  end

  private

  def generate_test_data(url)
    parsed_url = URI.parse(url)
    res = Net::HTTP.start(parsed_url.host, parsed_url.port) do |http|
      http.request Net::HTTP::Get.new(parsed_url)
    end
    parsed_body = HTML.parse(res.body)
  end
end
