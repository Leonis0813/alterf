# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $('#new-analysis').on 'ajax:success', (event, xhr, status, error) ->
    bootbox.alert({
      title: '学習を開始しました',
      message: '学習完了後，メールで結果が通知されます',
    })
    return
