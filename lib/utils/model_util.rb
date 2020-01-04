module ModelUtil
  def unzip_model(zip_path, output_dir)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(output_dir, entry.name))
      end
    end
  end

  def read_analysis_id(metadata_file)
    raise StandardError unless File.exist?(metadata_file)

    analysis_id = YAML.load_file(metadata_file)['analysis_id']
    raise StandardError if analysis_id.nil?

    analysis_id
  end
end
