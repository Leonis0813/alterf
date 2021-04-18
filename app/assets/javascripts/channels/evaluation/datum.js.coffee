App.evaluation_datum = App.cable.subscriptions.create "Evaluation::DatumChannel",
  received: (datum) ->
    console.log(datum)
    $('tbody').append("""
    <tr class='warning'>
      <td>#{datum.no}</td>
      <td>
        <a target='_blank' href='#{datum.race_url}'>
          #{datum.race_name}
          <span class='glyphicon glyphicon-new-window new-window'></span>
        </a>
      </td>
      <td style='padding: 4px'></td>
      <td style='padding: 4px'>
        <span class='fa-stack prediction-result' style='color: limegreen'>
          <i class='fa fa-circle fa-stack-2x'></i>
          <i class='fa fa-stack-1x fa-inverse'>#{datum.ground_truth}</i>
        </span>
      </td>
    </tr>
    """)
    return
