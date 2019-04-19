require_relative '../../lib/clients/netkeiba_client'

class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = File.join(Rails.root, 'tmp/files', evaluation_id)

    client = NetkeibaClient.new

    client.get_race_top.each do |race_id|
      race = client.get_race("#{Settings.netkeiba.base_url}/race/#{race_id}")
      File.open("#{data_dir}/#{Settings.prediction.tmp_file_name}", 'w') do
        YAML.dump(race.stringify_keys, file)
      end

      args = [evaluation_id, evaluation.model, Settings.evaluation.tmp_file_name]
      ret = system "Rscript #{Rails.root}/scripts/predict.r #{args.join(' ')}"
      FileUtils.mv("#{data_dir}/prediction.yml", "#{data_dir}/#{race_id}.yml")
    end

    evaluation.update!(:state => 'completed')
    EvaluationMailer.finished(evaluation, ret).deliver_now
    FileUtils.rm_rf(data_dir)
  end
end
