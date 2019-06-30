# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#new_evaluation').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '評価を開始しました',
      message: '終了後、メールにて結果を通知します',
      callback: ->
        $('.btn-submit').prop('disabled', false)
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
  return
