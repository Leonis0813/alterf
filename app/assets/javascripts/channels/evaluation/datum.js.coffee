App.evaluation_datum = App.cable.subscriptions.create "Evaluation::DatumChannel",
  received: (datum) ->
    if location.pathname != "/alterf/evaluations/#{datum.evaluation_id}"
      return

    switch datum.message_type
      when 'create'
        @createRow(datum)
      when 'update'
        @showResults(datum)
      else
        values = [
          datum.f_measure,
          datum.specificity,
          datum.recall,
          datum.precision,
        ]
        result.updateBars(values)
    return

  createRow: (datum) ->
    $('tbody').append("""
    <tr id='#{datum.race_id}' class='warning'>
      <td>#{datum.no}</td>
      <td>
        <a target='_blank' href='#{datum.race_url}'>
          #{datum.race_name}
          <span class='glyphicon glyphicon-new-window new-window'></span>
        </a>
      </td>
      <td class='result' style='padding: 4px'></td>
      <td style='padding: 4px'>
        <span class='fa-stack prediction-result' style='color: limegreen'>
          <i class='fa fa-circle fa-stack-2x'></i>
          <i class='fa fa-stack-1x fa-inverse'>#{datum.ground_truth}</i>
        </span>
      </td>
    </tr>
    """)
    return

  showResults: (datum) ->
    includeTruePositive = false
    column = $("tr##{datum.race_id} > td.result")
    $.each(datum.wons, (i, number) ->
      color = if number == datum.ground_truth then 'limegreen' else 'gray'
      includeTruePositive = includeTruePositive || color == 'limegreen'
      column.append("""
      <span class='fa-stack prediction-result' style='color: #{color}'>
        <i class='fa fa-circle fa-stack-2x'></i>
        <i class='fa fa-stack-1x fa-inverse'>#{number}</i>
      </span>
      """)
      return
    )
    row = $("tr##{datum.race_id}")
    row.removeClass('warning')
    row.addClass(if includeTruePositive then 'success' else 'danger')
    return
