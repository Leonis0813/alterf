App.analysis = App.cable.subscriptions.create "AnalysisChannel",
  received: (analysis) ->
    if location.pathname != '/alterf/analyses'
      return

    trId = "##{analysis.analysis_id}"
    if $(trId).length
      switch analysis.state
        when 'processing'
          @changeRowColor(trId, analysis)
        when 'completed'
          @changeRowColor(trId, analysis, 'processing')
          @createDownloadButton(trId)
        when 'error'
          @changeRowColor(trId, analysis, 'processing')

      @changeStateText(trId, analysis)
      $("#{trId} > td[class*=performed_at]").text(analysis.performed_at || '')
      $("#{trId} > td[class*=num_feature]").text(analysis.num_feature || '')
    else
      $.ajax({
        url: location.href,
        dataType: 'script',
      })
    return

  changeRowColor: (trId, analysis, beforeState = null) ->
    stateToClassMap = {processing: 'warning', completed: 'success', error: 'error'}

    column = $(trId)
    column.removeClass(stateToClassMap[beforeState]) if beforeState
    column.addClass(stateToClassMap[analysis.state])

    button = $("#{trId} button[class*=btn-param]")
    button.removeClass("btn-#{stateToClassMap[beforeState]}") if beforeState
    button.addClass("btn-#{stateToClassMap[analysis.state]}")
    return

  createDownloadButton: (trId) ->
    $("#{trId} > td.download").append("""
    <button class='btn btn-default' title='結果をダウンロード'>
      <span class='glyphicon glyphicon-download-alt'></span>
    </button>
    """)
    return

  changeStateText: (trId, analysis) ->
    column = $("#{trId} > td.state")
    column.text('')

    switch analysis.state
      when 'processing'
        column.append("""
        <span class='processing'>実行中</span>
        <i class='fa fa-refresh fa-spin'></i>
        """)
      when 'completed'
        href = "/alterf/analyses/#{analysis.analysis_id}"
        column.append("""
        <a target='_blank' rel='noopener noreferrer' href='#{href}'>
          <button class='btn btn-xs btn-success' title='結果を確認'>
            完了
            <span class='glyphicon glyphicon-new-window'></span>
          </button>
        </a>
        """)
      when 'error'
        column.text('エラー')
    return
