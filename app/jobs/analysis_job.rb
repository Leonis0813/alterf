class AnalysisJob < ActiveJob::Base
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis_id, analysis.num_data, analysis.num_tree, analysis.num_feature]
    FileUtils.mkdir_p("#{Rails.root}/tmp/files/#{analysis_id}")
    ret = system "Rscript #{Rails.root}/scripts/analyze.r #{args.join(' ')}"
    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/files/#{analysis_id}")
  end
end
