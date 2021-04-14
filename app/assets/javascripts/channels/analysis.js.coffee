App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  received: (analysis) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'error'}
    displayedState = {processing: '実行中', completed: '完了', error: 'エラー'}
    classNames = [
      'performed_at',
      'num_data',
      'num_feature',
      'num_entry',
      'parameter',
      'state',
    ]
    console.log(analysis)
    trId = "##{analysis.analysis_id}"
    if $(trId).length
      $.each(classNames, (i, className) ->
        column = $(trId + ' > td[class*=' + className + ']')
        column.removeClass('warning')
        column.addClass(stateToClassMap[analysis.state])

        if analysis.state == 'processing' && className == 'performed_at'
          column[0].innerText = analysis.performed_at
        if className == 'state'
          column[0].innerText = displayedState[analysis.state]
        return
      )
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return
