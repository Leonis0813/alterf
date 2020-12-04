class AnalysisJob < ApplicationJob
  queue_as :alterf

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.update!(state: Analysis::STATE_PROCESSING, performed_at: Time.zone.now)

    @output_dir = Rails.root.join('tmp', 'files', 'analyses', analysis_id.to_s)
    FileUtils.mkdir_p(@output_dir)
    parameter = analysis.parameter.attributes.merge('num_data' => analysis.num_data)
    parameter.except!('created_at', 'updated_at')

    if analysis.num_entry
      dump_yaml('parameter.yml', parameter.merge('num_entry' => analysis.num_entry))
      execute_script('analyze_with_num_entry.py', [analysis_id])
    else
      dump_yaml('parameter.yml', parameter)
      execute_script('analyze.py', [analysis_id])
    end

    metadata = {}
    yaml_file = File.join(@output_dir, 'metadata.yml')
    if File.exist?(yaml_file)
      metadata = YAML.load_file(yaml_file)
      analysis.update!(num_feature: metadata['num_feature'])
    end
    metadata.merge!(analysis.slice(:analysis_id, :num_feature))
    dump_yaml('metadata.yml', metadata)

    tree_files = Dir[File.join(@output_dir, 'tree_*.yml')].map do |file_path|
      File.basename(file_path)
    end

    create_zip(%w[metadata.yml model.rf], 'model.zip')
    create_zip(tree_files + %w[feature.csv training_data.csv], 'analysis.zip')

    metadata['importance'].each do |feature_name, value|
      analysis.result.importances.create!(feature_name: feature_name, value: value)
    end
    AnalysisMailer.completed(analysis).deliver_now

    analysis.update!(state: Analysis::STATE_COMPLETED)
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.update!(state: Analysis::STATE_ERROR)
    AnalysisMailer.error(analysis).deliver_now
  end

  private

  def dump_yaml(file_name, content)
    yaml_file = File.join(@output_dir, file_name)

    File.open(yaml_file, 'w') do |file|
      YAML.dump(content, file)
    end
  end

  def create_zip(target_files, zip_file_name)
    zip_file_path = File.join(@output_dir, zip_file_name)

    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      target_files.each do |target_file|
        Dir[File.join(@output_dir, target_file)].each do |file_path|
          zip.add(File.basename(file_path), file_path)
        end
      end
    end
  end
end
