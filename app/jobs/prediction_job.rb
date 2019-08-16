class PredictionJob < ActiveJob::Base
  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = Rails.root.join('tmp', 'files', prediction_id.to_s)
    test_data = prediction.test_data

    if test_data.match(URI::DEFAULT_PARSER.make_regexp)
      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        path = URI.parse(test_data).path
        feature = FeatureUtil.create_feature_from_netkeiba(path).deep_stringify_keys
        YAML.dump(feature, file)
      end
    end

    args = [prediction_id, prediction.model, Settings.prediction.tmp_file_name]
    is_success = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
    raise StandardError unless is_success

    prediction.import_results(Rails.root.join(data_dir, 'prediction.yml'))
    FileUtils.rm_rf(data_dir)
    prediction.update!(state: 'completed')
  rescue StandardError
    prediction.update!(state: 'error')
  end
end
