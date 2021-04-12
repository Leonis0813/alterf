import consumer from "./consumer"

consumer.subscriptions.create("AnalysisChannel", {
  received(analysis) {
  }
});
