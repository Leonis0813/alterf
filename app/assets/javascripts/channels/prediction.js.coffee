App.analysis = App.cable.subscriptions.create "PredictionChannel",
  received: (prediction) ->
    console.log(prediction)
    return
