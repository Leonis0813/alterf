App.prediction = App.cable.subscriptions.create "PredictionChannel",
  received: (prediction) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}

    trId = "##{prediction.prediction_id}"
    if $(trId).length
      switch prediction.state
        when 'processing'
          $(trId).addClass(stateToClassMap[prediction.state])
        when 'completed'
          $(trId).removeClass('warning')
          $(trId).addClass(stateToClassMap[prediction.state])
          @showResults(trId, prediction.wons)
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

  showResults: (trId, wons) ->
    colors = ['orange', 'skyblue', 'magenta']
    column = $("#{trId} > td[class*=td-result]")
    column.append("""
    <span title='#{wons.join(',')}' style='padding: 4px'>
    """)
    $.each(wons, (i, number) ->
      column.append("""
      <span class='fa-stack prediction-result' style='color: #{colors[i] || 'black'}'>
        <i class='fa fa-circle fa-stack-2x'></i>
        <i class='fa fa-stack-1x fa-inverse'>#{number}</i>
      </span>
      """)
      return
    )
    if wons.length > 6
      column.append('<span>...</span>')
    return
