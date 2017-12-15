class AnalysisJob < ActiveJob::Base
  queue_as :default

  def perform(num_data, num_tree, num_feature)
#    ret = system "Rscript #{Rails.root}/scripts/analyze/learn.r #{num_data} #{num_tree} #{num_feature}"
    if true
      AnalysisMailer.finished('succeed').deliver_now
    else
      AnalysisMailer.finished('failed').deliver_now
    end
  end
end
