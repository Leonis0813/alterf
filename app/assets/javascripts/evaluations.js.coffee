$ ->
  $('#new_evaluation').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '評価を開始しました',
      message: '終了後、メールにて結果を通知します',
      callback: ->
        location.reload()
        return
    })
    return

  $('#new_evaluation').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: ->
        $('.btn-submit').prop('disabled', false)
        return
    })
    return

  $('#data_source').on 'change', ->
    $('.form-data-source').prop('disabled', true)
    $('.form-data-source').addClass('not-selected')
    $('#evaluation_data_' + $(this).val()).prop('disabled', false)
    $('#evaluation_data_' + $(this).val()).removeClass('not-selected')
    return

  $('#table-evaluation').on 'ajax:success', (event, data, status, xhr) ->
    blob = new Blob([data], {type: 'text/plain'})
    blobUrl = (URL || webkitURL).createObjectURL(blob)
    filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1]
    $('<a>', {href: blobUrl, download: filename})[0].click()
    (URL || webkitURL).revokeObjectURL(blobUrl)
    return

  $('#table-evaluation').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '評価データが存在しません',
    })
    return
  return
