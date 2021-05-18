$(function() {
  $('#nav-link-analysis').addClass('active');

  const executeDialog = new bootstrap.Modal(document.getElementById('dialog-execute'));
  const executeErrorDialog = new bootstrap.Modal(document.getElementById('dialog-execute-error'));

  $('#new_analysis').on('ajax:success', function(event) {
    executeDialog.show();
  });

  $('#new_analysis').on('ajax:error', function(event) {
    executeErrorDialog.show();
  });

  $('#table-analysis').on('ajax:success', '.rebuild', function(event) {
    executeDialog.show();
  });

  $('#table-analysis').on('ajax:error', '.rebuild', function(event) {
    executeErrorDialog.show();
  });

  $('#analysis_data_source').on('change', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-block-data-source').addClass('not-selected');
    $('#analysis_data_' + $(this).val()).prop('disabled', false);
    $('#analysis_data_' + $(this).val()).parents('div').removeClass('not-selected');
  });

  const collapse = document.getElementById('parameter')

  collapse.addEventListener('show.bs.collapse', function () {
    $('#collapse-parameter').removeClass('bi-chevron-right').addClass('bi-chevron-down');
  })

  collapse.addEventListener('hide.bs.collapse', function () {
    $('#collapse-parameter').removeClass('bi-chevron-down').addClass('bi-chevron-right');
  });

  const parameterDialog = new bootstrap.Modal(document.getElementById('dialog-parameter'));

  $('tbody').on('click', '.btn-param', function(event) {
    analysisId = $(this).parents('tr').attr('id')
    $.ajax({
      type: 'GET',
      url: '/alterf/api/analyses/' + analysisId + '/parameter',
    }).done(function(parameter) {
      $('#parameter-max_depth').text(parameter.max_depth || '指定なし');
      $('#parameter-max_features').text(parameter.max_features);
      $('#parameter-max_leaf_nodes').text(parameter.max_leaf_nodes || '指定なし');
      $('#parameter-min_samples_leaf').text(parameter.min_samples_leaf);
      $('#parameter-min_samples_split').text(parameter.min_samples_split);
      $('#parameter-num_tree').text(parameter.num_tree);
      parameterDialog.show();
    }).fail(function(xhr, status, error) {
      bootbox.alert({
        title: 'エラーが発生しました',
        message: 'パラメーターの取得に失敗しました',
      });
    })
  });

  $('#btn-modal-parameter-ok').on('click', function(event) {
    parameterDialog.hide();
  });

  $('#btn-modal-execute-ok').on('click', function(event) {
    executeDialog.hide();
  });

  $('#btn-modal-execute-error-ok').on('click', function(event) {
    executeErrorDialog.hide();
    $('.btn-submit').prop('disabled', false);
  });

  $('#tbody-analysis').on('click', '.download', function(event) {
    analysisId = $(this).parents('tr').attr('id');
    xhr = new XMLHttpRequest();
    xhr.open('GET', '/alterf/analyses/' + analysisId + '/download');
    xhr.responseType = 'blob';
    xhr.onload = function(e) {
      if (this.status == 200) {
        data = this.response;
        blob = new Blob([data], {type: data.type});
        blobUrl = (URL || webkitURL).createObjectURL(blob);
        filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1];
        $('<a>', {href: blobUrl, download: filename})[0].click();
        (URL || webkitURL).revokeObjectURL(blobUrl);
      } else {
        bootbox.alert({
          title: 'エラーが発生しました',
          message: '分析結果が存在しません',
        });
      }
    }
    xhr.send();
  });

  $('#btn-analysis-search').on('click', function(event) {
    allQueries = $('#form-index').serializeArray();
    queries = $.grep(allQueries, function(query) {
      return query.name != "utf8" && query.value != ""
    });

    $.ajax({
      type: 'GET',
      url: '/alterf/analyses?' + $.param(queries)
    }).done(function(data) {
      location.href = '/alterf/analyses?' + $.param(queries);
    }).fail(function(xhr, status, error) {
      $('#dialog-execute-error').modal('show');
    });
  });
});
