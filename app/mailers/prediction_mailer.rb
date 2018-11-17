# coding: utf-8
class PredictionMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(prediction, is_success)
    @prediction = prediction
    subject = is_success ? '予測が完了しました' : '予測中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    tmp_dir = File.join(Rails.root, "tmp/files/#{prediction.id}")

    file_names = %w[ prediction.yml ]
    zip_file_name = File.join(tmp_dir, 'prediction.zip')

    Zip::File.open(zip_file_name, Zip::File::CREATE) do |zip|
      file_names.each do |file_name|
        zip.add(file_name, File.join(tmp_dir, file_name))
      end
    end

    attachments['prediction.zip'] = File.read(zip_file_name)
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
  end
end
