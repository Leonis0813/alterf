# coding: utf-8

class AnalysisMailer < ApplicationMailer
  def completed(analysis)
    @analysis = analysis

    tmp_dir = Rails.root.join('tmp', 'files', analysis.id.to_s)

    file_names = %w[metadata.yml model.rf]
    zip_file_name = File.join(tmp_dir, 'analysis.zip')

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
      file_names.each do |file_name|
        zip.add(file_name, File.join(tmp_dir, file_name))
      end
    end

    attachments['analysis.zip'] = File.read(zip_file_name)
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
