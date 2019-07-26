class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    evaluation.fetch_data.each do |race_id|
      feature = FeatureUtil.create_feature(race_id)

      data = evaluation.data.create!(
        race_name: NetkeibaClient.new.http_get_race_name(race_id),
        race_url: "#{Settings.netkeiba.base_url}/race/#{race_id}",
        ground_truth: feature['entries'].find {|entry| entry[-1] }[7],
      )

      feature['entries'].each {|entry| entry.delete_at(-1) }

      File.open(File.join(data_dir, Settings.prediction.tmp_file_name), 'w') do |file|
        YAML.dump(feature, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      success = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
      raise StandardError unless success

      result_file = File.join(data_dir, 'prediction.yml')
      data.import_prediction_results(result_file)
      FileUtils.rm(result_file)
    end

    FileUtils.rm_rf(data_dir)
    evaluation.calculate!
    evaluation.update!(state: 'completed')
  rescue StandardError
    evaluation.update!(state: 'error')
  end
end
