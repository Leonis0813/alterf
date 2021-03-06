import consumer from '../consumer';

consumer.subscriptions.create('AnalysisChannel', {
  received(analysis) {
    const trId = `#${analysis.analysis_id}`;

    if ($(trId).length) {
      switch (analysis.state) {
        case 'processing':
          this.changeRowColor(trId, analysis, 'waiting');
          break;
        case 'completed':
          this.changeRowColor(trId, analysis, 'processing');
          this.createDownloadButton(trId);
          break;
        case 'error':
          this.changeRowColor(trId, analysis, 'processing');
          break;
      }

      this.changeStateText(trId, analysis);
      $(`${trId} > td[class*=performed_at]`).text(analysis.performed_at || '');
      $(`${trId} > td[class*=num_feature]`).text(analysis.num_feature || '');
    } else {
      $.ajax({
        url: location.href,
        dataType: 'script',
      });
    }
  },

  changeRowColor(trId, analysis, beforeState) {
    const stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'};

    const column = $(trId);
    column.removeClass(`table-${stateToClassMap[beforeState]}`);
    column.addClass(`table-${stateToClassMap[analysis.state]}`);

    const button = $(`${trId} button[class*=btn-param]`);
    button.removeClass(`btn-${stateToClassMap[beforeState]}`);
    button.addClass(`btn-${stateToClassMap[analysis.state]}`);
  },

  createDownloadButton(trId) {
    $(`${trId} > td.download`).append(
      '<button class="btn btn-light btn-sm" title="結果をダウンロード">' +
        '<span class="bi bi-download"></span>' +
      '</button>'
    );
  },

  changeStateText(trId, analysis) {
    const column = $(`${trId} > td.state`);
    column.text('');

    switch (analysis.state) {
      case 'processing':
        column.append(
          '<span class="processing">実行中</span>' +
          '<i class="fas fa-sync-alt fa-spin"></i>'
        );
        break;
      case 'completed':
        const href = `/alterf/analyses/${analysis.analysis_id}`;
        column.append(
          `<a target='_blank' rel='noopener noreferrer' href=${href}>` +
            '<button class="btn btn-sm btn-success" title="結果を確認">' +
              '完了' +
              '<span class="bi bi-box-arrow-up-right"></span>' +
            '</button>' +
          '</a>'
        );
        break;
      case 'error':
        column.text('エラー');
        break;
    }
  }
});
