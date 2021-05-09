class AnalysisJob < ApplicationJob
  queue_as :alterf

  OUTPUT_FILES = %w[
    feature.csv
    metadata.yml
    model.rf
    race_list.txt
    training_data.csv
  ].freeze

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)
    analysis.start!

    @tmp_dir = Rails.root.join('tmp', 'files', 'analyses', analysis_id.to_s)

    analysis.dump_parameter
    analysis.dump_training_data

    script_name = analysis.num_entry ? 'analyze_with_num_entry.py' : 'analyze.py'
    execute_script(script_name, [analysis_id])

    check_output
    analysis.import_data!
    analysis.result.import!

    yaml_file = File.join(@tmp_dir, 'metadata.yml')
    metadata = YAML.load_file(yaml_file)
    analysis.update!(num_feature: metadata['num_feature'])
    metadata.merge!(analysis.slice(:analysis_id))
    File.open(yaml_file, 'w') {|file| YAML.dump(metadata, file) }

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
      raise StandardError unless File.exist?(File.join(@tmp_dir, output_file))
    end
  end

  def create_zip(target_files, zip_file_name)
    zip_file_path = File.join(@tmp_dir, zip_file_name)

    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
      target_files.each do |target_file|
        Dir[File.join(@tmp_dir, target_file)].each do |file_path|
          zip.add(File.basename(file_path), file_path)
        end
      end
    end
  end
end
