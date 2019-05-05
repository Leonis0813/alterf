# coding: utf-8

class EvaluationMailer < ApplicationMailer
  def finished(evaluation, is_success)
    @evaluation = evaluation
    subject = is_success ? '評価が完了しました' : '評価中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    tmp_dir = Rails.root.join('tmp', 'files', evaluation.id.to_s)

    file_names = Dir[File.join(tmp_dir, '*')].map {|file| File.basename(file) }
    zip_file_name = File.join(tmp_dir, 'evaluation.zip')

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
      file_names.each do |file_name|
        zip.add(file_name, File.join(tmp_dir, file_name))
      end
    end

    attachments['evaluation.zip'] = File.read(zip_file_name)
    mail(to: 'Leonis.0813@gmail.com', subject: subject, template_name: template_name)
  end
end
