App.analysis = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    console.log(evaluation)
    return
