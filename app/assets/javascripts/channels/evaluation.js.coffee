App.evaluation = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}

    trId = "##{evaluation.evaluation_id}"
    if $(trId).length
      switch evaluation.state
        when 'processing'
          @changeRowColor(trId, evaluation.state)
          $("#{trId} > td[class*=performed_at]").text(evaluation.performed_at)
        when 'completed'
          @changeRowColor(trId, evaluation.state)
          column = $("#{trId} > td[class*=state] button")
          column.removeClass('btn-warning')
          column.addClass('btn-success')
          $("#{trId} span.state").text(displayedState[evaluation.state])
        when 'error'
          @changeRowColor(trId, evaluation.state)
          $("#{trId} > td[class*=state]").text(displayedState[evaluation.state])
        else
          @updateProgress(trId, evaluation)
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return

  changeRowColor: (trId, state) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    classNames = [
      'performed_at',
      'model',
      'state',
      'precision',
      'recall',
      'specificity',
      'f_measure',
    ]

    $.each(classNames, (i, className) ->
      column = $("#{trId} > td[class[*=#{className}]")
      column.removeClass('warning')
      column.addClass(stateToClassMap[state])
      return
    )
    return

  updateProgress: (trId, evaluation) ->
    $("#{trId} span.state").text("#{evaluation.progress}%完了")
    $("#{trId} > td[class*=precision]").text(round(evaluation.precision))
    $("#{trId} > td[class*=recall]").text(round(evaluation.recall))
    $("#{trId} > td[class*=specificity]").text(round(evaluation.specificity))
    $("#{trId} > td[class*=f_measure]").text(round(evaluation.f_measure))
    return

  round: (value) ->
    return Math.round(value * 1000) / 1000
