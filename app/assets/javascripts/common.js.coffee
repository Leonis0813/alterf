$ ->
  $('.btn-submit').on 'click', ->
    $(@).prop('disabled', true)
    $(@).submit()
    return
  return
