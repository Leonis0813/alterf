# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#new_prediction').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '予測を開始しました',
      message: '終了後、メールにて結果を通知します',
    })
    return

  $('#new_prediction').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
    })
    return
  return
