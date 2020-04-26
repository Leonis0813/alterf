$ ->
  $('.btn-submit').on 'click', ->
    $(@).prop('disabled', true)
    $(@).submit()
    return

  window.stateToClass = (state) ->
    switch state
      when 'processing'
        return 'warning'
      when 'completed'
        return 'success'
      when 'error'
        return 'danger'
  return
