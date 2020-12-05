$ ->
  $('#new_analysis').on 'ajax:success', (event, xhr, status, error) ->
    $('#dialog-execute').modal('show')
    return

  $('#new_analysis').on 'ajax:error', (event, xhr, status, error) ->
    $('#dialog-execute-error').modal('show')
    return

  $('#table-analysis').on 'ajax:success', '.rebuild', (event, data, status, xhr) ->
    $('#dialog-execute').modal('show')
    return

  $('#table-analysis').on 'ajax:error', '.rebuild', (event, xhr, status, error) ->
    $('#dialog-execute-error').modal('show')
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
      $('#parameter-max_depth').text(parameter.max_depth || '指定なし')
      $('#parameter-max_features').text(parameter.max_features)
      $('#parameter-max_leaf_nodes').text(parameter.max_leaf_nodes || '指定なし')
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

  $('#btn-modal-parameter-ok').on 'click', ->
    $('#dialog-parameter').modal('hide')
    return

  $('#btn-modal-execute-ok').on 'click', ->
    $('#dialog-execute').modal('hide')
    location.reload()
    return

  $('#btn-modal-execute-error-ok').on 'click', ->
    $('#dialog-execute-error').modal('hide')
    $('.btn-submit').prop('disabled', false)
    return

  $('#tbody-analysis').on 'ajax:success', '.download', (event, data, status, xhr) ->
    blob = new Blob([data], {type: 'octet/stream'})
    blobUrl = (URL || webkitURL).createObjectURL(blob)
    filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1]
    $('<a>', {href: blobUrl, download: filename})[0].click()
    (URL || webkitURL).revokeObjectURL(blobUrl)
    return

  $('#tbody-analysis').on 'ajax:error', '.download', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '分析結果が存在しません',
    })
    return
  return
