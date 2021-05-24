import consumer from '../consumer';

consumer.subscriptions.create('PredictionChannel', {
  received(prediction) {
    const stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'};
    const displayedState = {processing: '実行中', completed: '完了', error: 'エラー'};

    const trId =`#${prediction.prediction_id}`;
    if ($(trId).length) {
      switch (prediction.state) {
        case 'processing':
          $(trId).addClass(`table-${stateToClassMap[prediction.state]}`);
          break;
        case 'completed':
          $(trId).removeClass('table-warning');
          $(trId).addClass(`table-${stateToClassMap[prediction.state]}`);
          this.showResults(trId, prediction.wons);
          break;
        case 'error':
          $(trId).removeClass('table-warning');
          $(trId).addClass(`table-${stateToClassMap[prediction.state]}`);
          $(`${trId} > td[class*=td-result]`).append(
            '<span class="bi bi-x" style="color: red"/>'
          );
      }
    } else {
      $.ajax({
        url: location.href,
        dataType: 'script',
      });
    }
  },

  showResults: function(trId, wons) {
    const colors = ['orange', 'skyblue', 'magenta'];

    const column = $(trId + ' > td[class*=td-result]');
    column.append(`<span title='${wons.join(',')}' style='padding: 4px'>`);

    $.each(wons, function(i, number) {
      column.append(
        `<span class='fa-layers fa-fw fa-2x prediction-result' style='color: ${colors[i] || 'black'}'>` +
          '<i class="fa fa-circle"></i>' +
          `<i class="fa-layers-text fa-inverse fa-xs">${number}</i>` +
        '</span>'
      );
    });
    if (wons.length > 6) {
      column.append('<span>...</span>');
    }
  }
});
