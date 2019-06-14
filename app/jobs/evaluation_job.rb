class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    client = NetkeibaClient.new

    client.http_get_race_top.each do |race_id|
      race_url = "#{Settings.netkeiba.base_url}/race/#{race_id}"

      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        feature = FeatureUtil.create_feature("/race/#{race_id}")
        evaluation.data.create!(
          race_name: feature[:race_name],
          race_url: race_url,
          ground_truth: feature[:entries].find {|entry| entry.last == 1 }[7],
        )
        YAML.dump(feature.deep_stringify_keys, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      success = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
      raise StandardError unless success

      data = evaluation.data.find_by(race_url: race_url)
      data.import_prediction_results(Rails.root.join(data_dir, 'prediction.yml'))
    end

    FileUtils.rm_rf(data_dir)
    evaluation.calculate_precision!
    evaluation.update!(state: 'completed')
  rescue StandardError
    evaluation.update!(state: 'error')
  end
end
