import consumer from '../consumer';

consumer.subscriptions.create('PredictionChannel', {
  received(prediction) {
    const stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'};
    const displayedState = {processing: '実行中', completed: '完了', error: 'エラー'};

    const trId =`#${prediction.prediction_id}`;
    if ($(trId).length) {
      switch (prediction.state) {
        case 'processing':
          $(trId).addClass(stateToClassMap[prediction.state]);
          break;
        case 'completed':
          $(trId).removeClass('warning');
          $(trId).addClass(stateToClassMap[prediction.state]);
          this.showResults(trId, prediction.wons);
          break;
        case 'error':
          $(trId).removeClass('warning');
          $(trId).addClass(stateToClassMap[prediction.state]);
          $(`${trId} > td[class*=td-result]`).append(
            '<span class="glyphicon glyphicon-remove" style="color: red"/>'
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
        `<span class='fa-stack prediction-result' style='color: ${colors[i] || 'black'}'>` +
          '<i class="fa fa-circle fa-stack-2x"></i>' +
          `<i class="fa fa-stack-1x fa-inverse">${number}</i>` +
        '</span>'
      );
    });
    if (wons.length > 6) {
      column.append('<span>...</span>');
    }
  }
});
