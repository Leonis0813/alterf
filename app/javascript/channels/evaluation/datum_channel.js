import consumer from "./consumer"

consumer.subscriptions.create("Evaluation::DatumChannel", {
  received(evaluation_datum) {
    // Called when there's incoming data on the websocket for this channel
  }
});
