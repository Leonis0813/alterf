# coding: utf-8
class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(analysis, is_success)
    @analysis = analysis
    subject = is_success ? '分析が完了しました' : '分析中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    tmp_dir = File.join(Rails.root, "tmp/files/#{analysis.id}")

    file_names = %w[ training_data.yml model.rf ]
    zip_file_name = File.join(tmp_dir, 'analysis.zip')

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
      file_names.each do |file_name|
        zip.add(file_name, File.join(tmp_dir, filename))
      end
    end

    attachments['analysis.zip'] = File.read(File.join(tmp_dir, 'analysis.zip'))
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
  end
end
