App.prediction = App.cable.subscriptions.create "PredictionChannel",
  received: (prediction) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}
    console.log(prediction)
    trId = "##{prediction.prediction_id}"
    if $(trId).length
      switch prediction.state
        when 'processing'
          $(trId).addClass(stateToClassMap[prediction.state])
        when 'completed'
          $(trId).removeClass('warning')
          $(trId).addClass(stateToClassMap[prediction.state])
        when 'error'
          $(trId).removeClass('warning')
          $(trId).addClass(stateToClassMap[prediction.state])
          $("#{trId} > td[class*=td-result]").append("""
<span class='glyphicon glyphicon-remove' style='color: red'/>
          """)
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
