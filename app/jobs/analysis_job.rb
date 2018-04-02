class AnalysisJob < ActiveJob::Base
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis.num_data, analysis.num_tree, analysis.num_feature]
    ret = system "Rscript #{Rails.root}/scripts/learn.r #{args.join(' ')}"
    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
  end
end
