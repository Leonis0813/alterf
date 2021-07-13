import consumer from '../consumer';

consumer.subscriptions.create('EvaluationChannel', {
  received(evaluation) {
    const trId = `tr#${evaluation.evaluation_id}`;
    const row = $(trId);

    if (row.length) {
      switch (evaluation.state) {
        case 'processing':
          row.removeClass('cursor-auto');
          row.addClass('table-warning cursor-pointer');
          row.attr('data-state', evaluation.state);
          row.attr('title', '結果を確認');
          $(`${trId} > td[class*=performed_at]`).text(evaluation.performed_at);
          $(`${trId} > td[class*=state]`).text('0%完了');
          new bs.Tooltip(row);
          break;
        case 'completed':
          row.removeClass('table-warning');
          row.addClass('table-success');
          row.attr('data-state', evaluation.state);
          row.attr('title', '結果を確認');
          $(`${trId} > td[class*=state]`).text('完了');
          this.addDownloadButton(trId, evaluation);
          break;
        case 'error':
          row.removeClass('table-warning cursor-pointer');
          row.addClass('table-danger cursor-auto');
          row.attr('data-state', evaluation.state);
          row.attr('title', '');
          row.attr('data-bs-original-title', '');
          $(`${trId} > td[class*=state]`).text('エラー');
          bs.Tooltip.getInstance(row).dispose();
          break;
        default:
          this.updateProgress(trId, evaluation);
      }
    } else {
      let elements = document.querySelectorAll('[data-bs-toggle="tooltip"]');
      elements.forEach(function (element) {
        bs.Tooltip.getInstance(element).dispose();
      });

      $.ajax({
        url: location.href,
        dataType: 'script',
      }).done(function() {
        elements = document.querySelectorAll('[data-bs-toggle="tooltip"]');
        elements.forEach(function (element) {
          new bs.Tooltip(element);
        });
      });
    }
  },

  addDownloadButton(trId, evaluation) {
    if (evaluation.data_source === 'text' || evaluation.data_source === 'file') {
      return;
    }

    const href = `/alterf/evaluations/${evaluation.evaluation_id}/download`;
    const button = $(
      `<a data-remote='true' href='${href}'>` +
        '<button class="btn btn-success" title="評価レースをダウンロード" ' +
          'data-bs-toggle="tooltip" data-bs-trigger="hover">' +
          '<span class="bi bi-download"></span>' +
        '</button>' +
      '</a>'
    );
    $(`${trId} > td.download`).append(button);
    button.ready(function() {
      new bs.Tooltip($(`${trId} > td.download > a > button`));
    });
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
