$(function() {
  $('#nav-link-evaluation').addClass('active');

  const collapse = document.getElementById('form-evaluation');

  collapse.addEventListener('show.bs.collapse', function(event) {
    $('button#collapse-form > span')
      .removeClass('bi-plus-circle')
      .addClass('bi-dash-circle');
  });

  collapse.addEventListener('hide.bs.collapse', function(event) {
    $('button#collapse-form > span')
      .removeClass('bi-dash-circle')
      .addClass('bi-plus-circle');
  });

  $('#new_evaluation').on('ajax:success', function(event) {
    bootbox.alert({
      title: '評価を開始しました',
      message: '終了後、メールにて結果を通知します',
    });
  });

  $('#new_evaluation').on('ajax:error', function(event) {
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: function() {
        $('.btn-submit').prop('disabled', false);
      }
    })
  });

  $('#evaluation_data_source').on('change', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-data-source').addClass('not-selected');
    $('#evaluation_data_' + $(this).val()).prop('disabled', false);
    $('#evaluation_data_' + $(this).val()).removeClass('not-selected');
  });

  $('#table-evaluation').on('click', 'td', function(event) {
    const row = $(this).parents('tr');
    const state = row.data('state');

    if (state === 'waiting' || state === 'error') {
      return;
    }
    if ($(this).attr('class') === 'download') {
      return;
    }

    open('/alterf/evaluations/' + row.attr('id'), '_blank');
  });

  $('#table-evaluation').on('ajax:success', function(event) {
    const blob = new Blob([data], {type: 'text/plain'});
    const blobUrl = (URL || webkitURL).createObjectURL(blob);
    const filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1];
    $('<a>', {href: blobUrl, download: filename})[0].click();
    (URL || webkitURL).revokeObjectURL(blobUrl);
  });

  $('#table-evaluation').on('ajax:error', function(event) {
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '評価データが存在しません',
    });
  });
});
