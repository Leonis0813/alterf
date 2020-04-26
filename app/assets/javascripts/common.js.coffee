$ ->
  $('.btn-submit').on 'click', ->
    $(@).prop('disabled', true)
    $(@).submit()
    return

  setInterval(() ->
    $.ajax({
      type: 'GET',
      url: location.pathname + location.search,
      dataType: 'script',
    })
    return
  , 3000)
  return
