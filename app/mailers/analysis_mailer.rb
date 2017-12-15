# coding: utf-8
class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(is_success)
    subject = is_success ? '分析が完了しました' : '分析中にエラーが発生しました'
    template_name = is_success ? 'success' : 'failer'
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject, :template_name => template_name)
  end
end
