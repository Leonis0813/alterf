class AnalysisMailer < ApplicationMailer
  default :from => 'no_reply@alterf.com'
  default :to => 'Leonis.0813@gmail.com'

  def finished(subject)
    mail(subject: subject)
  end
end
