# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  successDialog = ->
    bootbox.alert({
      title: '分析を開始しました',
      message: '終了後、メールにて結果を通知します',
      callback: ->
        location.reload()
        return
    })
    return

  failureDialog = ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  updateRowColor = (analysis_id, state) ->
    rowClasses = ['performed_at', 'num_data', 'num_tree', 'num_feature', 'num_entry', 'state']
    $.each(rowClasses, (i, rowClass) ->
      td = $('tr#' + analysis_id + ' > td[class*=' + rowClass + ']')
      $.each(['danger', 'warning', 'success'], (j, colorRowClass) ->
        td.removeClass(colorRowClass)
        return
      )
      td.addClass(stateToClass(state))
      return
    )
    return

  updateTable = ->
    $.ajax({
      type: 'GET',
      url: '/alterf/api/analyses' + location.search,
    }).done((response) ->
      $.each(response.analyses, (i, analysis) ->
        updateRowColor(analysis.analysis_id, analysis.state)
        if analysis.performed_at?
          datum = $('tr#' + analysis.analysis_id + ' > td[class*=performed_at]')
          date = new Date(analysis.performed_at)
          date_string = moment.utc(date).format('YYYY/MM/DD HH:mm:ss')
          datum.text(date_string)
        if analysis.num_feature?
          datum = $('tr#' + analysis.analysis_id + ' > td[class*=num_feature]')
          datum.text(analysis.num_feature)
        datum = $('tr#' + analysis.analysis_id + ' > td[class*=state]')
        datum.text(I18n.t('views.js.state.' + analysis.state))
        return
      )
      return
    ).fail((xhr, status, error) ->
      return
    )
    return

  $('#new_analysis').on 'ajax:success', (event, xhr, status, error) ->
    successDialog()
    return

  $('#new_analysis').on 'ajax:error', (event, xhr, status, error) ->
    failureDialog()
    return

  $('button.rebuild').on 'click', ->
    data = {
      num_data: parseInt($(@).parent().siblings()[1].innerText),
      num_tree: parseInt($(@).parent().siblings()[2].innerText),
    }
    num_entry = $(@).parent().siblings()[4].innerText
    if num_entry != ''
      data['num_entry'] = parseInt(num_entry)
    $.ajax({
      type: 'POST',
      url: '/alterf/analyses',
      data: data,
    }).done((data) ->
      successDialog()
      return
    ).fail((xhr, status, error) ->
      failureDialog()
      return
    )
    return

  if location.pathname.match(/analyses$/)
    setInterval(updateTable, 3000)
    return
  return
