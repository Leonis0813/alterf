class PredictionJob < ApplicationJob
  queue_as :alterf

  def perform(prediction_id)
    prediction = Prediction.find(prediction_id)
    data_dir = Rails.root.join('tmp', 'files', prediction_id.to_s)
    test_data = prediction.test_data

    Zip::File.open(File.join(data_dir, prediction.model)) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(data_dir, entry.name))
      end
    end

    feature = if test_data.match?(URI::DEFAULT_PARSER.make_regexp)
                path = URI.parse(test_data).path
                FeatureUtil.create_feature_from_netkeiba(path).deep_stringify_keys
              else
                YAML.load_file(test_data).deep_stringify_keys
              end

    feature_file = File.join(data_dir, Settings.prediction.tmp_file_name)
    File.open(feature_file, 'w') {|file| YAML.dump(feature, file) }

    metadata_file = File.join(data_dir, 'metadata.yml')
    raise StandardError unless File.exist?(metadata_file)

    analysis_id = YAML.load_file(metadata_file)['analysis_id']
    raise StandardError if analysis_id.nil?

    analysis = Analysis.find_by(analysis_id: analysis_id)
    raise StandardError if analysis.nil?

    num_entry = analysis.num_entry
    raise StandardError unless (num_entry.nil? or num_entry == feature['entries'].size)

    args = [prediction_id, prediction.model, Settings.prediction.tmp_file_name]
    execute_script('predict.py', args)

    prediction.import_results(Rails.root.join(data_dir, 'prediction.yml'))
    FileUtils.rm_rf(data_dir)
    prediction.update!(state: 'completed')
  rescue StandardError
    prediction.update!(state: 'error')
  end
end
