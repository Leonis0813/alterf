class EvaluationChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'evaluation'
  end
end
