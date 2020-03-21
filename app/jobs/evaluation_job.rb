class EvaluationJob < ApplicationJob
  include ModelUtil

  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    evaluation.update!(state: Evaluation::STATE_PROCESSING)

    data_dir = Rails.root.join('tmp', 'files', 'evaluations', evaluation_id.to_s)
    unzip_model(File.join(data_dir, evaluation.model), data_dir)

    evaluation.set_analysis!
    evaluation.fetch_data!

    evaluation.data.each do |datum|
      File.open(File.join(data_dir, Settings.prediction.tmp_file_name), 'w') do |file|
        feature = FeatureUtil.create_feature_from_denebola(datum.race_id)
        YAML.dump(feature.to_hash.deep_stringify_keys, file)
      end

      args = [data_dir, 'model.rf', Settings.evaluation.tmp_file_name]
      if evaluation.analysis.num_entry
        execute_script('predict_with_num_entry.py', args)
      else
        execute_script('predict.py', args)
      end

      result_file = File.join(data_dir, 'prediction.yml')
      datum.import_prediction_results(result_file)
      FileUtils.rm(result_file)
    end

    evaluation.calculate!
    evaluation.output_race_ids
    evaluation.update!(state: Evaluation::STATE_COMPLETED)
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    evaluation.update!(state: Evaluation::STATE_ERROR)
  end
end
