$(function() {
  $('#nav-link-analysis').addClass('active');

  $('#new_analysis').on('ajax:success', function(event, xhr, status, error) {
    $('#dialog-execute').modal('show');
  });

  $('#new_analysis').on('ajax:error', function(event, xhr, status, error) {
    $('#dialog-execute-error').modal('show');
  });

  $('#table-analysis').on('ajax:success', '.rebuild', function(event, data, status, xhr) {
    $('#dialog-execute').modal('show');
  });

  $('#table-analysis').on('ajax:error', '.rebuild', function(event, xhr, status, error) {
    $('#dialog-execute-error').modal('show');
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
});
