import * as common from '../application';

$(function() {
  $('#nav-link-analysis').addClass('active');

  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (element) {
    new bs.Tooltip(element);
  });

  $('#new_analysis').on('ajax:success', function(event) {
    common.showDialog('dialog-execute');
  });

  $('#new_analysis').on('ajax:error', function(event) {
    common.showDialog('dialog-execute-error');
  });

  $('#table-analysis').on('ajax:success', '.rebuild', function(event) {
    common.showDialog('dialog-execute');
  });

  $('#table-analysis').on('ajax:error', '.rebuild', function(event) {
    common.showDialog('dialog-execute-error');
  });

  $('#analysis_data_source').on('change', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-block-data-source').addClass('not-selected');
    $(`#analysis_data_${$(this).val()}`).prop('disabled', false);
    $(`#analysis_data_${$(this).val()}`).parents('div').removeClass('not-selected');
  });

  $('#btn-register-reset').on('click', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-block-data-source').addClass('not-selected');
    $('#analysis_data_random').prop('disabled', false);
    $('#analysis_data_random').parents('div').removeClass('not-selected');
  });

  $('tbody').on('click', '.btn-param', function(event) {
    common.showParameterDialog($(this).parents('tr').attr('id'));
  });

  $('#tbody-analysis').on('click', '.download', function(event) {
    const analysisId = $(this).parents('tr').attr('id');
    const xhr = new XMLHttpRequest();
    xhr.open('GET', `/alterf/analyses/${analysisId}/download`);
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
        common.showDialog('dialog-download-error');
      }
    };
    xhr.send();
  });

  $('#btn-analysis-search').on('click', function(event) {
    const allQueries = $('#form-index').serializeArray();
    const queries = $.grep(allQueries, function(query) {
      return query.name !== "utf8" && query.value !== "";
    });

    $.ajax({
      type: 'GET',
      url: `/alterf/analyses?${$.param(queries)}`,
    }).done(function(data) {
      location.href = `/alterf/analyses?${$.param(queries)}`;
    }).fail(function(xhr, status, error) {
      common.showDialog('dialog-execute-error');
    });
  });
});
