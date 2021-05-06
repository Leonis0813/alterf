App.evaluation = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    if location.pathname != '/alterf/evaluations'
      return

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
          @addDownloadButton(trId, evaluation)
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
    column = $(trId)
    column.removeClass('warning')
    column.addClass(stateToClassMap[state])
    return

  addDownloadButton: (trId, evaluation) ->
    if evaluation.data_source == 'text' or evaluation.data_source == 'file'
      return

    href = "/alterf/evaluations/#{evaluation.evaluation_id}/download"
    $("#{trId} > td.download").append("""
    <a data-remote='true' href='#{href}'>
      <button class='btn btn-success'>
        <span class='glyphicon glyphicon-download-alt'></span>
      </button>
    </a>
    """)
    return

  updateProgress: (trId, evaluation) ->
    $("#{trId} > td[class*=state]").text("#{evaluation.progress}%完了")
    $("#{trId} > td[class*=precision]").text(@round(evaluation.precision))
    $("#{trId} > td[class*=recall]").text(@round(evaluation.recall))
    $("#{trId} > td[class*=specificity]").text(@round(evaluation.specificity))
    $("#{trId} > td[class*=f_measure]").text(@round(evaluation.f_measure))
    return

  round: (value) ->
    return Math.round(value * 1000) / 1000
