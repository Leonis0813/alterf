import consumer from '../consumer';

consumer.subscriptions.create('Evaluation::RaceChannel', {
  received(race) {
    if (location.pathname !== `/alterf/evaluations/${race.evaluation_id}`) {
      return;
    }

    switch (race.message_type) {
      case 'create':
        this.createRow(race);
        const tooltips = document.querySelectorAll('[data-bs-toggle="tooltip"]');
        tooltips.forEach(function (tooltip) {
          return new bs.Tooltip(tooltip);
        });
        break;
      case 'update':
        this.showResults(race);
        break;
      default:
        const values = [
          race.f_measure,
          race.specificity,
          race.recall,
          race.precision,
        ];
        result.updateBars(values);
    }
  },

  createRow(race) {
    $('tbody').append(
      `<tr id='${race.race_id}' class='cursor-pointer table-warning' ` +
        'title="テストデータを確認" data-bs-toggle="tooltip" data-bs-placement="top" data-bs-offset="-500,0">' +
        `<td>${race.no}</td>` +
        '<td>' +
          `<a target='_blank' href='${race.race_url}'>` +
            `${race.race_name}` +
            '<span class="bi bi-box-arrow-up-right"></span>' +
          '</a>' +
        '</td>' +
        '<td class="num_entry"></td>' +
        '<td class="result" style="padding: 4px"></td>' +
        '<td style="padding: 4px">' +
          '<span class="fa-layers fa-fw fa-2x prediction-result" style="color: limegreen">' +
            '<i class="fa fa-circle"></i>' +
            `<i class='fa-layers-text fa-inverse fa-xs'>${race.ground_truth}</i>` +
          '</span>' +
        '</td>' +
      '</tr>'
    );
  },

  showResults(race) {
    let includeTruePositive = false;
    const column = $(`tr#${race.race_id} > td.result`);
    $.each(race.wons, function(i, number) {
      const color = number === race.ground_truth ? 'limegreen' : 'gray';
      includeTruePositive = includeTruePositive || color === 'limegreen';
      column.append(
        `<span class='fa-layers fa-fw fa-2x prediction-result' style='color: ${color}'>` +
          '<i class="fa fa-circle"></i>' +
          `<i class='fa-layers-text fa-inverse fa-xs'>${number}</i>` +
        '</span>'
      );
    });
    $(`tr#${race.race_id} > td.num_entry`).text(race.num_entry);
    const row = $(`tr#${race.race_id}`);
    row.removeClass('table-warning');
    row.addClass(includeTruePositive ? 'table-success' : 'table-danger');
  }
});
