$(function() {
  const formCollapse = document.getElementById('form-evaluation');

  $('#nav-link-evaluation').addClass('active');

  formCollapse.addEventListener('show.bs.collapse', function(event) {
    console.log('show');
    $('button#collapse-form > span')
      .removeClass('bi-plus-circle')
      .addClass('bi-dash-circle');
  });

  formCollapse.addEventListener('hide.bs.collapse', function(event) {
    console.log('hide');
    $('button#collapse-form > span')
      .removeClass('bi-dash-circle')
      .addClass('bi-plus-circle');
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
    const data = event.detail[0];
    const xhr = event.detail[2];
    const blob = new Blob([data], {type: 'text/plain'});
    const blobUrl = (URL || webkitURL).createObjectURL(blob);
    const filename = /filename="(.*)"/.exec(xhr.getResponseHeader('Content-Disposition'))[1];
    $('<a>', {href: blobUrl, download: filename})[0].click();
    (URL || webkitURL).revokeObjectURL(blobUrl);
  });
});
