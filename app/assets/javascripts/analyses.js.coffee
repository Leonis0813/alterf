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

  $('#new_analysis').on 'ajax:success', (event, xhr, status, error) ->
    successDialog()
    return

  $('#new_analysis').on 'ajax:error', (event, xhr, status, error) ->
    failureDialog()
    return

  $('#table-analysis').on 'ajax:success', (event, data, status, xhr) ->
    successDialog()
    return

  $('#table-analysis').on 'ajax:error', (event, xhr, status, error) ->
    failureDialog()
    return

  $('#parameter').on 'show.bs.collapse', ->
    $('a[href="#parameter"]')
      .removeClass('glyphicon-chevron-right')
      .addClass('glyphicon-chevron-down')
    return

  $('#parameter').on 'hide.bs.collapse', ->
    $('a[href="#parameter"]')
      .removeClass('glyphicon-chevron-down')
      .addClass('glyphicon-chevron-right')
    return

  $('tbody').on 'click', '.btn-param', ->
    analysisId = $(@).parents('tr').attr('id')
    $.ajax({
      type: 'GET',
      url: "/alterf/api/analyses/#{analysisId}/parameter",
    }).done((parameter) ->
      if (parameter.max_depth != null)
        $('#parameter-max_depth').text(parameter.max_depth)
      $('#parameter-max_features').text(parameter.max_features)
      if (parameter.max_leaf_nodes != null)
        $('#parameter-max_leaf_nodes').text(parameter.max_leaf_nodes)
      $('#parameter-min_samples_leaf').text(parameter.min_samples_leaf)
      $('#parameter-min_samples_split').text(parameter.min_samples_split)
      $('#parameter-num_tree').text(parameter.num_tree)
      $('#dialog-parameter').modal('show')
    ).fail((xhr, status, error) ->
      bootbox.alert({
        title: 'エラーが発生しました',
        message: 'パラメーターの取得に失敗しました',
      })
    )
    return

  $('#btn-modal-ok').on 'click', ->
    $('#dialog-parameter').modal('hide')
    return
  return
