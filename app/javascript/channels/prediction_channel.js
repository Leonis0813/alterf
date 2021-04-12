import consumer from "./consumer"

consumer.subscriptions.create("PredictionChannel", {
  received(prediction) {
    // Called when there's incoming data on the websocket for this channel
  }
});
