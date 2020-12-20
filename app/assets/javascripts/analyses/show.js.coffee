$ ->
  $('#tree_id').on 'change', ->
    $('#decision_tree').children().remove()
    result.drawTree(parseInt($(@).val()))
