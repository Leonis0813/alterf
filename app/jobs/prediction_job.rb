require_relative '../../lib/clients/netkeiba_client'

class PredictionJob < ActiveJob::Base
  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = "#{Rails.root}/tmp/files/#{prediction_id}"
    test_data = prediction.test_data

    if test_data.match(URI::regexp)
      begin
        race = NetkeibaClient.new.get_race(test_data)
        File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
          YAML.dump(race.stringify_keys, file)
        end
      rescue Exception => e
        PredictionMailer.finished(prediction, false).deliver_now
        raise e
      end
    end

    args = [prediction_id, prediction.model, Settings.prediction.tmp_file_name]
    ret = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"

    prediction.update!(:state => 'completed')
    PredictionMailer.finished(prediction, ret).deliver_now
    FileUtils.rm_rf(data_dir)
  end
end
