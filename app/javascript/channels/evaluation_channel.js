import consumer from "./consumer"

consumer.subscriptions.create("EvaluationChannel", {
  received(evaluation) {
    // Called when there's incoming data on the websocket for this channel
  }
});
