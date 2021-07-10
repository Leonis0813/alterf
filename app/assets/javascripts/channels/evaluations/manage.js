import consumer from '../consumer';

consumer.subscriptions.create('EvaluationChannel', {
  received(evaluation) {
    const trId = `#${evaluation.evaluation_id}`;
    const column = $(trId);

    if (column.length) {
      switch (evaluation.state) {
        case 'processing':
          column.removeClass('cursor-auto');
          column.addClass('table-warning cursor-pointer');
          column.attr('data-state', evaluation.state);
          column.attr('title', '結果を確認');
          $(`${trId} > td[class*=performed_at]`).text(evaluation.performed_at);
          $(`${trId} > td[class*=state]`).text('0%完了');
          new bs.Tooltip(document.getElementById(evaluation.evaluation_id));
          break;
        case 'completed':
          column.removeClass('table-warning');
          column.addClass('table-success');
          column.attr('data-state', evaluation.state);
          column.attr('title', '結果を確認');
          $(`${trId} > td[class*=state]`).text('完了');
          this.addDownloadButton(trId, evaluation);
          break;
        case 'error':
          column.removeClass('table-warning cursor-pointer');
          column.addClass('table-danger cursor-auto');
          column.attr('data-state', evaluation.state);
          column.attr('title', '');
          column.attr('data-bs-original-title', '');
          $(`${trId} > td[class*=state]`).text('エラー');
          break;
        default:
          this.updateProgress(trId, evaluation);
      }
    } else {
      $.ajax({
        url: location.href,
        dataType: 'script',
      });
    }
  },

  addDownloadButton(trId, evaluation) {
    if (evaluation.data_source === 'text' || evaluation.data_source === 'file') {
      return;
    }

    const href = `/alterf/evaluations/${evaluation.evaluation_id}/download`;
    $(`${trId} > td.download`).append(
      `<a data-remote='true' href='${href}'>` +
        '<button class="btn btn-success" title="評価レースをダウンロード" ' +
          'data-bs-toggle="tooltip" data-bs-placement="top">' +
          '<span class="bi bi-download"></span>' +
        '</button>' +
      '</a>'
    );

    const element = document.querySelector(`${trId} > td.download > a > button`);
    new bs.toolTip(element);
  },

  updateProgress(trId, evaluation) {
    $(`${trId} > td[class*=state]`).text(evaluation.progress + '%完了');
    $(`${trId} > td[class*=precision]`).text(this.round(evaluation.precision));
    $(`${trId} > td[class*=recall]`).text(this.round(evaluation.recall));
    $(`${trId} > td[class*=specificity]`).text(this.round(evaluation.specificity));
    $(`${trId} > td[class*=f_measure]`).text(this.round(evaluation.f_measure));
  },

  round(value) {
    return Math.round(value * 1000) / 1000;
  }
});
