class AnalysisJob < ApplicationJob
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.update!(state: Analysis::STATE_PROCESSING, performed_at: Time.zone.now)

    output_dir = Rails.root.join('tmp', 'files', 'analyses', analysis_id.to_s)
    FileUtils.mkdir_p(output_dir)
    parameter = analysis.parameter.attributes.merge('num_data' => analysis.num_data)
    parameter_file = File.join(output_dir, 'parameter.yml')

    if analysis.num_entry
      dump_yaml(parameter_file, parameter.merge('num_entry' => analysis.num_entry))
      execute_script('analyze_with_num_entry.py', [analysis_id])
    else
      dump_yaml(parameter_file, parameter)
      execute_script('analyze.py', [analysis_id])
    end

    metadata = {}
    yaml_file = File.join(output_dir, 'metadata.yml')
    if File.exist?(yaml_file)
      metadata = YAML.load_file(yaml_file)
      analysis.update!(num_feature: metadata['num_feature'])
    end
    dump_yaml(yaml_file, metadata.merge(analysis.slice(:analysis_id, :num_feature))

    metadata['importance'].each do |feature_name, value|
      analysis.result.importances.create!(feature_name: feature_name, value: value)
    end
    AnalysisMailer.completed(analysis).deliver_now

    FileUtils.rm_rf(output_dir)
    analysis.update!(state: Analysis::STATE_COMPLETED)
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.update!(state: Analysis::STATE_ERROR)
    AnalysisMailer.error(analysis).deliver_now
  end

  private

  def dump_yaml(file, content)
    File.open(file, 'w') do |file|
      YAML.dump(parameter, file)
    end
  end
end
