App.evaluation = App.cable.subscriptions.create "EvaluationChannel",
  received: (evaluation) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}
    classNames = [
      'performed_at',
      'model',
      'state',
      'precision',
      'recall',
      'specificity',
      'f_measure',
    ]
    console.log(evaluation)
    trId = "##{evaluation.evaluation_id}"
    if $(trId).length
      switch evaluation.state
        when 'processing'
          @changeRowColor(trId, evaluation.state)
          @createDetailButton(trId, evaluation)
          $("#{trId} > td[class*=performed_at]").text(evaluation.performed_at)
        when 'completed'
          @changeRowColor(trId, evaluation.state)
          @createDetailButton(trId, evaluation)
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
    $.each(classNames, (i, className) ->
      column = $("#{trId} > td[class[*=#{className}]")
      column.removeClass('warning')
      column.addClass(stateToClassMap[state])
      return
    )
    return

  createDetailButton: (trId, evaluation) ->
    href = '/alterf/evaluations/#{evaluation.evaluation_id}'
    $("#{trId} > td[class*=state]").append("""
    <a target='_blank' rel='noopener noreferrer' href='#{href}'>
      <button class='btn btn-xs btn-#{stateToClassMap[evaluation.state]}' title='詳細を確認'>
        <span class='state'>完了</span>
        <span class='glyphicon glyphicon-new-window'></span>
      </button>
    </a>
    """)
    return

  updateProgress: (trId, evaluation) ->
    $("#{trId} span.state").text("#{evaluation.progress}%完了")
    $("#{trId} > td[class*=precision]").text(Math.round(evaluation.precision, 3))
    $("#{trId} > td[class*=recall]").text(Math.round(evaluation.recall, 3))
    $("#{trId} > td[class*=specificity]").text(Math.round(evaluation.specificity, 3))
    $("#{trId} > td[class*=f_measure]").text(Math.round(evaluation.f_measure, 3))
    return
