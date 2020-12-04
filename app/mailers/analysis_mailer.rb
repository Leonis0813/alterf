# coding: utf-8

class AnalysisMailer < ApplicationMailer
  MAIL_TO = 'Leonis.0813@gmail.com'

  def completed(analysis)
    @analysis = analysis

    mail(
      to: MAIL_TO,
      subject: '[Alterf] 分析が完了しました',
      template_name: 'success',
    )
  end

  def error(analysis)
    @analysis = analysis

    mail(
      to: MAIL_TO,
      subject: '[Alterf] 分析中にエラーが発生しました',
      template_name: 'failer',
    )
  end
end
