App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  received: (analysis) ->
    if location.pathname != '/alterf/analyses'
      return

    stateToClassMap = {processing: 'warning', completed: 'success', error: 'error'}
    displayedState = {error: 'エラー'}
    classNames = [
      'performed_at',
      'num_data',
      'num_feature',
      'num_entry',
      'parameter',
      'state',
    ]

    trId = "##{analysis.analysis_id}"
    if $(trId).length
      $.each(classNames, (i, className) ->
        column = $("#{trId} > td[class*=#{className}]")
        column.removeClass('warning')
        column.addClass(stateToClassMap[analysis.state])

        if analysis.state == 'processing' and className == 'performed_at'
          column[0].innerText = analysis.performed_at
        if className == 'num_feature'
          column[0].innerText = analysis.num_feature
        if analysis.state == 'error' and className == 'state'
          column[0].innerText = displayedState[analysis.state]
        return
      )

      button = $("#{trId} button[class*=btn-param]")
      button.removeClass('btn-warning')
      button.addClass("btn-#{stateToClassMap[analysis.state]}")

      if analysis.state == 'completed'
        @createResultButton(trId, analysis.analysis_id)
        @createDownloadButton(trId)
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return

  createResultButton: (trId, analysisId) ->
    $("#{trId} > td.state").text('')
    $("#{trId} > td.state").append("""
<a target='_blank' rel='noopener noreferrer' href='/alterf/analyses/#{analysisId}'>
  <button class='btn btn-xs btn-success' title='結果を確認'>
    完了
    <span class='glyphicon glyphicon-new-window'></span>
  </button>
</a>
    """)
    return

  createDownloadButton: (trId) ->
    $("#{trId} > td.download").append("""
<button class='btn btn-default' title='結果をダウンロード'>
  <span class='glyphicon glyphicon-download-alt'></span>
</button>
    """)
