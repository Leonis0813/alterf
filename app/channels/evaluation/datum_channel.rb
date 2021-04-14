class Evaluation::DatumChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'evaluation_datum'
  end
end
