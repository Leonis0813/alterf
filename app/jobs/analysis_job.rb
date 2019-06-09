class AnalysisJob < ActiveJob::Base
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    args = [analysis_id, analysis.num_data, analysis.num_tree]
    output_dir = Rails.root.join('tmp', 'files', analysis_id.to_s)
    FileUtils.mkdir_p(output_dir)
    success = system "Rscript #{Rails.root}/scripts/analyze.r #{args.join(' ')}"
    raise StandardError unless success

    yaml_file = File.join(output_dir, 'analysis.yml')
    if File.exist?(yaml_file)
      analysis_params = YAML.load_file(yaml_file)
      analysis.update!(num_feature: analysis_params['mtry'])
    end

    AnalysisMailer.completed(analysis).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/files/#{analysis_id}")
    analysis.update!(state: 'completed')
  rescue StandardError
    analysis.update!(state: 'error')
    AnalysisMailer.error(analysis).deliver_now
  end
end
