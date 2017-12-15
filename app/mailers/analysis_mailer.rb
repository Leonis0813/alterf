class AnalysisMailer < ApplicationMailer
  default :from => 'Leonis.0813@gmail.com'

  def finished(subject)
    mail(:to => 'Leonis.0813@gmail.com', :subject => subject)
  end
end
