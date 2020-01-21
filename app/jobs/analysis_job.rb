class AnalysisJob < ApplicationJob
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    output_dir = Rails.root.join('tmp', 'files', analysis_id.to_s)
    FileUtils.mkdir_p(output_dir)

    if analysis.num_entry
      args = [analysis_id, analysis.num_data, analysis.num_tree, analysis.num_entry]
      execute_script('analyze_with_num_entry.py', args)
    else
      args = [analysis_id, analysis.num_data, analysis.num_tree]
      execute_script('analyze.py', args)
    end

    metadata = {}
    yaml_file = File.join(output_dir, 'metadata.yml')
    if File.exist?(yaml_file)
      metadata = YAML.load_file(yaml_file)
      analysis.update!(num_feature: metadata['num_feature'])
    end

    File.open(yaml_file, 'w') do |file|
      metadata.merge!(analysis.slice(:analysis_id, :num_feature))
      YAML.dump(metadata.stringify_keys, file)
    end

    AnalysisMailer.completed(analysis).deliver_now
    FileUtils.rm_rf("#{Rails.root}/tmp/files/#{analysis_id}")
    analysis.update!(state: 'completed')
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.update!(state: 'error')
    AnalysisMailer.error(analysis).deliver_now
  end
end
