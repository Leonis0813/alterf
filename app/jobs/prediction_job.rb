require_relative '../../lib/clients/netkeiba_client'

class PredictionJob < ActiveJob::Base
  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = Rails.root.join('tmp', 'files', prediction_id.to_s)
    test_data = prediction.test_data

    if test_data.match(URI::DEFAULT_PARSER.make_regexp)
      race = NetkeibaClient.new.http_get_race(test_data)
      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        YAML.dump(race.stringify_keys, file)
      end
    end

    args = [prediction_id, prediction.model, Settings.prediction.tmp_file_name]
    system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"

    YAML.load_file(Rails.root.join(data_dir, 'prediction.yml')).each do |number, result|
      prediction.results.create!(number: number) if result == 1
    end
    FileUtils.rm_rf(data_dir)
    prediction.update!(state: 'completed')
  end
end
