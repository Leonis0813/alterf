class AnalysisJob < ActiveJob::Base
  queue_as :default

  def perform(num_data, num_tree, num_feature)
    job = Analysis.create!(:num_data => num_data, :num_tree => num_tree, :num_feature => num_feature, :state => 'processing')
    ret = system "Rscript #{Rails.root}/scripts/analyze/learn.r #{num_data} #{num_tree} #{num_feature}"
    job[:state] = 'complete'
    job.save!
    AnalysisMailer.finished(ret).deliver_now
  end
end
