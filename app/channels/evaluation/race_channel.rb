class Evaluation::RaceChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'evaluation_race'
  end
end
