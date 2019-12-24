module ModelUtil
  def unzip_model(zip_path, output_dir)
    Zip::File.open(zip_path) do |zip|
      zip.each do |entry|
        zip.extract(entry, File.join(output_dir, entry.name))
      end
    end
  end
end
