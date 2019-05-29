require_relative '../../lib/utils/feature_util'

class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = Rails.root.join('tmp', 'files', evaluation_id.to_s)

    client = NetkeibaClient.new

    client.http_get_race_top.each do |race_id|
      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do |file|
        feature = FeatureUtil.create_feature("/race/#{race_id}").deep_stringify_keys
        YAML.dump(feature, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"

      result_file = File.join(data_dir, 'prediction.yml')
      FileUtils.mv(result_file, "#{data_dir}/#{race_id}.yml") if File.exist?(result_file)
    end

    evaluation.update!(state: 'completed')

    FileUtils.rm_f("#{data_dir}/#{Settings.prediction.tmp_file_name}")
    FileUtils.rm_f("#{data_dir}/#{evaluation.model}")
    EvaluationMailer.finished(evaluation, true).deliver_now
    FileUtils.rm_rf(data_dir)
  end
end
