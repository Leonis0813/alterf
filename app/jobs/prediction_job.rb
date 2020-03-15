class PredictionJob < ApplicationJob
  include ModelUtil

  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = Rails.root.join('tmp', 'files', 'predictions', prediction_id.to_s)
    test_data = prediction.test_data
    unzip_model(File.join(data_dir, prediction.model), data_dir)

    prediction.set_analysis!

    feature = if test_data.match?(URI::DEFAULT_PARSER.make_regexp)
                FeatureUtil.create_feature_from_netkeiba(URI.parse(test_data).path)
              else
                YAML.load_file(test_data)
              end.deep_stringify_keys

    raise StandardError unless prediction.analysis.num_entry == feature['entries'].size

    feature_file = File.join(data_dir, Settings.prediction.tmp_file_name)
    File.open(feature_file, 'w') {|file| YAML.dump(feature, file) }

    args = [prediction_id, 'model.rf', Settings.prediction.tmp_file_name]
    if num_entry
      execute_script('predict_with_num_entry.py', args)
    else
      execute_script('predict.py', args)
    end

    prediction.import_results(Rails.root.join(data_dir, 'prediction.yml'))
    FileUtils.rm_rf(data_dir)
    prediction.update!(state: 'completed')
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    prediction.update!(state: 'error')
  end
end
