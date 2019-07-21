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
        ground_truth: feature['entries'].find {|entry| entry['won'] }['number'],
      )

      feature['entries'].each {|entry| entry.except!('won') }

      File.open(File.join(data_dir, Settings.prediction.tmp_file_name), 'w') do |file|
        YAML.dump(feature, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      success = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
      raise StandardError unless success

      data.import_prediction_results(File.join(data_dir, 'prediction.yml'))
    end

    FileUtils.rm_rf(data_dir)
    evaluation.calculate_precision!
    evaluation.update!(state: 'completed')
  rescue StandardError
    evaluation.update!(state: 'error')
  end
end
