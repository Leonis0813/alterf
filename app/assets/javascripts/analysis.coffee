# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#new-analysis').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '分析が完了しました',
      message: '学習結果をフォルダに出力しました',
    })
    return

  $('#new-analysis').on 'ajax:error', (event, xhr, status, error) ->
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
    })
    return
