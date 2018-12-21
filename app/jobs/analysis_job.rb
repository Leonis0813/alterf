class AnalysisJob < ActiveJob::Base
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis_id, analysis.num_data, analysis.num_tree]
    output_dir = File.join(Rails.root, "/tmp/files/#{analysis_id}")
    FileUtils.mkdir_p(output_dir)
    ret = system "Rscript #{Rails.root}/scripts/analyze.r #{args.join(' ')}"

    yaml_file = File.join(output_dir, 'analysis.yml')
    if File.exists?(yaml_file)
      analysis_params = YAML.load_file(yaml_file)
      analysis.update!(:num_feature => analysis_params['mtry'])
    end

    analysis.update!(:state => 'completed')
    AnalysisMailer.finished(analysis, ret).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/files/#{analysis_id}")
  end
end
