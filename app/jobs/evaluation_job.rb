class EvaluationJob < ApplicationJob
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)
    evaluation.fetch_data!

    evaluation.data.each do |datum|
      File.open(File.join(data_dir, Settings.prediction.tmp_file_name), 'w') do |file|
        feature = FeatureUtil.create_feature_from_denebola(datum.race_id)
        YAML.dump(feature.to_hash.deep_stringify_keys, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      execute_script('predict.py', args)

      result_file = File.join(data_dir, 'prediction.yml')
      datum.import_prediction_results(result_file)
      FileUtils.rm(result_file)
    end

    FileUtils.rm_rf(data_dir)
    evaluation.calculate!
    evaluation.update!(state: 'completed')
  rescue StandardError
    evaluation.update!(state: 'error')
  end
end
