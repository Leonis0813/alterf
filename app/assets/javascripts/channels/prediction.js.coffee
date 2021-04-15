App.analysis = App.cable.subscriptions.create "PredictionChannel",
  received: (prediction) ->
    console.log(prediction)
    trId = "##{analysis.analysis_id}"
    if $(trId).length
      switch prediction.state
        when 'processing'
          $(trId).addClass(prediction.state)
        when 'completed'
          $(trId).removeClass('warning')
          $(trId).addClass(prediction.state)
        when 'error'
          $(trId).removeClass('warning')
          $(trId).addClass(prediction.state)
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
