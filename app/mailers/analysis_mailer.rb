# coding: utf-8

class AnalysisMailer < ApplicationMailer
  def completed(analysis)
    @analysis = analysis

    tmp_dir = Rails.root.join('tmp', 'files', analysis.id.to_s)

    [
      [%w[metadata.yml model.rf], 'model.zip'],
      [%w[tree.yml feature.csv training_data.csv], 'analysis.zip'],
    ].each do |file_names, zip_file_name|
      zip_file_path = File.join(tmp_dir, 'analysis.zip')

      Zip::File.open(zip_file_path, Zip::File::CREATE) do |zip|
        file_names.each do |file_name|
          Dir[File.join(tmp_dir, file_name)].each do |file_path|
            zip.add(File.basename(file_path), file_path)
          end
        end
      end

      attachments[zip_file_name] = File.read(zip_file_name)
    end

    mail(
      to: 'Leonis.0813@gmail.com',
      subject: '分析が完了しました',
      template_name: 'success',
    )
  end

  def error(analysis)
    @analysis = analysis

    mail(
      to: 'Leonis.0813@gmail.com',
      subject: '分析中にエラーが発生しました',
      template_name: 'failer',
    )
  end
end
