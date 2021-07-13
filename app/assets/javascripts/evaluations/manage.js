$(function() {
  const formCollapse = document.getElementById('form-evaluation');
  const collapse = new bs.Collapse(formCollapse);

  const showDialog = function(id) {
    const dialog = new bs.Modal(document.getElementById(id));
    dialog.show();
  };

  formCollapse.addEventListener('show.bs.collapse', function(event) {
    $('button#collapse-form > span')
      .removeClass('bi-plus-circle')
      .addClass('bi-dash-circle');
  });

  formCollapse.addEventListener('hide.bs.collapse', function(event) {
    $('button#collapse-form > span')
      .removeClass('bi-dash-circle')
      .addClass('bi-plus-circle');
  });

  $('#collapse-form').on('click', function() {
    collapse.toggle();
  });

  $('#new_evaluation').on('ajax:success', function(event) {
    const dialog = new bs.Modal(document.getElementById('dialog-execute'));
    dialog.show();
  });

  $('#new_evaluation').on('ajax:error', function(event) {
    const dialog = new bs.Modal(document.getElementById('dialog-execute-error'));
    dialog.show();
  });

  $('#table-evaluation').on('ajax:error', function(event) {
    const dialog = new bs.Modal(document.getElementById('dialog-download-error'));
    dialog.show();
  });

  $('#nav-link-evaluation').addClass('active');

  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (element) {
    new bs.Tooltip(element);
  });

  $('#evaluation_data_source').on('change', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-data-source').addClass('not-selected');
    $(`#evaluation_data_${$(this).val()}`).prop('disabled', false);
    $(`#evaluation_data_${$(this).val()}`).removeClass('not-selected');
  });

  $('#btn-reset').on('click', function(event) {
    $('.form-data-source').prop('disabled', true);
    $('.form-data-source').addClass('not-selected');
  });

  $('#table-evaluation').on('click', 'td', function(event) {
    const row = $(this).parents('tr');
    const state = row.data('state');

    if (state === 'waiting' || state === 'error') {
      return;
    }

    if ($(this).attr('class') === 'model' && event.target.tagName === 'BUTTON') {
      return;
    }

    if ($(this).attr('class') === 'download') {
      return;
    }

    open(`/alterf/evaluations/${row.attr('id')}`, '_blank');
  });

  $('#table-evaluation').on('click', '.model button', function(event) {
    const analysisId = $(this).attr('id');
    $.ajax({
      type: 'GET',
      url: `/alterf/api/analyses/${analysisId}/parameter`,
    }).done(function(parameter) {
      $('#parameter-max_depth').text(parameter.max_depth || '指定なし');
      $('#parameter-max_features').text(parameter.max_features);
      $('#parameter-max_leaf_nodes').text(parameter.max_leaf_nodes || '指定なし');
      $('#parameter-min_samples_leaf').text(parameter.min_samples_leaf);
      $('#parameter-min_samples_split').text(parameter.min_samples_split);
      $('#parameter-num_tree').text(parameter.num_tree);
      showDialog('dialog-parameter');
    }).fail(function(xhr, status, error) {
      showDialog('dialog-parameter-error');
    });
  });

  $('#table-evaluation').on('ajax:success', function(event) {
    const data = event.detail[0];
    const xhr = event.detail[2];
    const blob = new Blob([data], {type: 'text/plain'});
    const blobUrl = (URL || webkitURL).createObjectURL(blob);
    const filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1];
    $('<a>', {href: blobUrl, download: filename})[0].click();
    (URL || webkitURL).revokeObjectURL(blobUrl);
  });

  $('#table-evaluation').on('mouseover', '.download button, .model button', function(event) {
    const rowId = $(this).parents('tr').attr('id');
    const row = document.getElementById(rowId);
    const tooltip = bs.Tooltip.getInstance(row);
    tooltip.hide();
    tooltip.disable();
  }).on('mouseleave', '.download button, .model button', function(event) {
    const rowId = $(this).parents('tr').attr('id');
    const row = document.getElementById(rowId);
    const tooltip = bs.Tooltip.getInstance(row);
    tooltip.enable();
    tooltip.show();
  });
});
