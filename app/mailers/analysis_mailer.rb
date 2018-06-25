# coding: utf-8
class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(analysis, is_success)
    @analysis = analysis
    subject = is_success ? '分析が完了しました' : '分析中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    attachments['training_data.yml'] = File.read(File.join(Rails.root, "tmp/files/#{analysis.id}/analysis.yml"))
    attachments['model.rf'] = File.read(File.join(Rails.root, "tmp/files/#{analysis.id}/model.rf"))
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
  end
end
