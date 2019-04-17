# coding: utf-8
class EvaluationJob < ActiveJob::Base
  queue_as :alterf

  def perform(evaluation_id)
    evaluation = Evaluation.find(evaluation_id)
    data_dir = "#{Rails.root}/tmp/files/#{evaluation_id}"
    args = [evaluation_id, evaluation.model]
    ret = system "Rscript #{Rails.root}/scripts/evaluate.r #{args.join(' ')}"
    evaluation.update!(:state => 'completed')
    EvaluationMailer.finished(evaluation, ret).deliver_now
    FileUtils.rm_rf(data_dir)
  end
end
