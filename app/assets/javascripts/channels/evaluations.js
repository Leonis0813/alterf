import consumer from './consumer';

consumer.subscriptions.create('EvaluationChannel', {
  received(evaluation) {
    if (location.pathname !== '/alterf/evaluations') {
      return;
    }

    const displayedState = {processing: '実行中', completed: '完了', error: 'エラー'};

    const trId = '#' + evaluation.evaluation_id;
    if ($(trId).length) {
      switch (evaluation.state) {
        case 'processing':
          this.changeRowColor(trId, evaluation.state);
          $(trId + ' > td[class*=performed_at]').text(evaluation.performed_at);
          break;
        case 'completed':
          this.changeRowColor(trId, evaluation.state);
          const column = $(trId + ' > td[class*=state] button');
          column.removeClass('btn-warning');
          column.addClass('btn-success');
          $(trId + ' > td[class*=state]').text(displayedState[evaluation.state]);
          this.addDownloadButton(trId, evaluation);
          break;
        case 'error':
          this.changeRowColor(trId, evaluation.state);
          $(trId + ' > td[class*=state]').text(displayedState[evaluation.state]);
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

  changeRowColor: function(trId, state) {
    const stateToClassMap = {processing: 'warning', completed: 'success', error: 'danger'};
    const column = $(trId);
    column.removeClass('warning');
    column.addClass(stateToClassMap[state]);
  },

  addDownloadButton: function(trId, evaluation) {
    if (evaluation.data_source === 'text' || evaluation.data_source === 'file') {
      return;
    }

    const href = '/alterf/evaluations/' + evaluation.evaluation_id + '/download';
    $("#{trId} > td.download").append(
      '<a data-remote="true" href="' + href + '">' +
        '<button class="btn btn-success">' +
          '<span class="glyphicon glyphicon-download-alt"></span>' +
        '</button>' +
      '</a>'
    );
  },

  updateProgress: function(trId, evaluation) {
    $(trId + ' > td[class*=state]').text(evaluation.progress + '%完了');
    $(trId + ' > td[class*=precision]').text(this.round(evaluation.precision));
    $(trId + ' > td[class*=recall]').text(this.round(evaluation.recall));
    $(trId + ' > td[class*=specificity]').text(this.round(evaluation.specificity));
    $(trId + ' > td[class*=f_measure]').text(this.round(evaluation.f_measure));
  },

  round: function(value) {
    return Math.round(value * 1000) / 1000;
  }
});
