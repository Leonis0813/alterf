class AnalysisJob < ApplicationJob
  queue_as :alterf

  OUTPUT_FILES = %w[metadata.yml model.rf feature.csv race_list.txt training_data.csv]

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.start!

    @output_dir = Rails.root.join('tmp', 'files', 'analyses', analysis_id.to_s)
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)
    parameter = analysis.parameter.attributes.merge('num_data' => analysis.num_data)
    parameter.except!('id', 'analysis_id', 'created_at', 'updated_at')
    parameter['env'] = Rails.env.to_s

    if analysis.num_entry
      dump_yaml('parameter.yml', parameter.merge('num_entry' => analysis.num_entry))
      execute_script('analyze_with_num_entry.py', [analysis_id])
    else
      dump_yaml('parameter.yml', parameter)
      execute_script('analyze.py', [analysis_id])
    end

    check_output
    analysis.result.import!

    yaml_file = File.join(@output_dir, 'metadata.yml')
    metadata = YAML.load_file(yaml_file)
    analysis.update!(num_feature: metadata['num_feature'])
    metadata.merge!(analysis.slice(:analysis_id))
    dump_yaml('metadata.yml', metadata)

    create_zip(%w[metadata.yml model.rf], 'model.zip')
    create_zip(%w[feature.csv race_list.txt training_data.csv], 'analysis.zip')
    create_zip(%w[model.zip analysis.zip], 'result.zip')

    AnalysisMailer.completed(analysis).deliver_now
    analysis.complete!
  rescue StandardError => e
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace.join("\n"))
    analysis.update!(state: Analysis::STATE_ERROR)
    AnalysisMailer.error(analysis).deliver_now
  end

  private

  def check_output
    OUTPUT_FILES.each do |output_file|
      raise StandardError unless File.exist?(File.join(@output_dir, output_file))
    end
  end

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
