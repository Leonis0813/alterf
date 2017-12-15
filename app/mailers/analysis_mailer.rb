class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'
  default :to => 'Leonis.0813@gmail.com'

  def finished(subject)
    mail(:subject => subject)
  end
end
