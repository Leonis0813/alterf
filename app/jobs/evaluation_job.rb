class EvaluationJob < ApplicationJob
  include ModelUtil

  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    evaluation.start!

    data_dir = Rails.root.join('tmp/files/evaluations', evaluation_id.to_s)
    unzip_model(File.join(data_dir, evaluation.model), data_dir)

    evaluation.set_analysis!
    evaluation.fetch_data!

    evaluation.data.each do |datum|
      File.open(File.join(data_dir, Settings.prediction.tmp_file_name), 'w') do |file|
        feature = FeatureUtil.create_feature_from_denebola(datum.race_id)
        YAML.dump(feature.to_hash.deep_stringify_keys, file)
      end

      args = [data_dir, 'model.rf', Settings.evaluation.tmp_file_name]
      execute_script('predict.py', args)

      result_file = File.join(data_dir, 'prediction.yml')
      datum.import_prediction_results(result_file)
      FileUtils.rm(result_file)
      evaluation.calculate!
    end

    evaluation.output_race_ids
    evaluation.complete!
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    evaluation.failed!
  end
end
