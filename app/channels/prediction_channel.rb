class PredictionChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'prediction'
  end
end
