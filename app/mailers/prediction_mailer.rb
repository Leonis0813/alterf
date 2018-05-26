# coding: utf-8
class PredictionMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(prediction, is_success)
    @prediction = prediction
    subject = is_success ? '予測が完了しました' : '予測中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    attachments['prediction.yml'] = File.read(File.join(Rails.root, "results/prediction_#{prediction.id}.yml"))
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
  end
end
