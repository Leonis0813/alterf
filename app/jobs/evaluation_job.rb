class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    client = NetkeibaClient.new

    race_ids = if evaluation.data_source == 'remote'
                 client.http_get_race_top
               else
                 file_path = Rails.root.join(
                   data_dir,
                   Settings.evaluation.race_list_filename,
                 )
                 File.read(file_path).lines.map(&:chomp)
               end

    race_ids.each do |race_id|
      race_url = "#{Settings.netkeiba.base_url}/race/#{race_id}"
      race_name = client.http_get_race_name(race_id)
      feature = FeatureUtil.create_feature(race_id)

      evaluation.data.create!(
        race_name: race_name,
        race_url: race_url,
        ground_truth: feature['entries'].find {|entry| entry['won'] }['number'],
      )

      feature['entries'].each {|entry| entry.except!('won') }

      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        YAML.dump(feature, file)
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
