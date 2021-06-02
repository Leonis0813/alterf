import consumer from '../consumer';

consumer.subscriptions.create('Evaluation::DatumChannel', {
  received(datum) {
    if (location.pathname !== `/alterf/evaluations/${datum.evaluation_id}`) {
      return;
    }

    switch (datum.message_type) {
      case 'create':
        this.createRow(datum);
        break;
      case 'update':
        this.showResults(datum);
        break;
      default:
        const values = [
          datum.f_measure,
          datum.specificity,
          datum.recall,
          datum.precision,
        ];
        result.updateBars(values);
    }
  },

  createRow(datum) {
    $('tbody').append(
      `<tr id='${datum.race_id}' class='table-warning'>` +
        `<td>${datum.no}</td>` +
        '<td>' +
          `<a target='_blank' href='${datum.race_url}'>` +
            `${datum.race_name}` +
            '<span class="bi bi-box-arrow-up-right"></span>' +
          '</a>' +
        '</td>' +
        '<td class="result" style="padding: 4px"></td>' +
        '<td style="padding: 4px">' +
          '<span class="fa-layers fa-fw fa-2x prediction-result" style="color: limegreen">' +
            '<i class="fa fa-circle"></i>' +
            `<i class='fa-layers-text fa-inverse fa-xs'>${datum.ground_truth}</i>` +
          '</span>' +
        '</td>' +
      '</tr>'
    );
  },

  showResults(datum) {
    const includeTruePositive = false;
    const column = $(`tr#${datum.race_id} > td.result`);
    $.each(datum.wons, function(i, number) {
      const color = number === datum.ground_truth ? 'limegreen' : 'gray';
      const includeTruePositive = includeTruePositive || color === 'limegreen';
      column.append(
        `<span class='fa-layers fa-fw fa-2x prediction-result' style='color: ${color}'>` +
          '<i class="fa fa-circle"></i>' +
          `<i class='fa-layers-text fa-inverse fa-xs'>${number}</i>` +
        '</span>'
      );
    });
    const row = $(`tr#${datum.race_id}`);
    row.removeClass('table-warning');
    row.addClass(includeTruePositive ? 'table-success' : 'table-danger');
  }
});
