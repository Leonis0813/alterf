class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    client = NetkeibaClient.new

    client.http_get_race_top.each do |race_id|
      race_url = "#{Settings.netkeiba.base_url}/race/#{race_id}"

      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        feature = FeatureUtil.create_feature("/race/#{race_id}").deep_stringify_keys
        evaluation.data.create!(
          race_name: feature[:race_name],
          race_url: race_url
          ground_truth: feature[:entries].find {|entry| entry[:order] == 1 }[:number],
        )
        YAML.dump(feature, file)
      end

      data = evaluation.data.find_by(race_url: race_url)

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      success = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
      raise StandardError unless success

      result_file = Rails.root.join(data_dir, 'prediction.yml')
      YAML.load_file(result_file).each do |number, result|
        data.prediction_results.create!(number: number) if result == 1
      end
    end

    FileUtils.rm_rf(data_dir)
    evaluation.update!(state: 'completed')
  rescue StandardError
    evaluation.update!(state: 'error')
  end
end
