$(function() {
  $('#nav-link-prediction').addClass('active');

  $('#new_prediction').on('ajax:success', function(event) {
    const dialog = new bs.Modal(document.getElementById('dialog-execute'));
    dialog.show();
  });

  $('#new_prediction').on('ajax:error', function(event) {
    const dialog = new bs.Modal(document.getElementById('dialog-execute-error'));
    dialog.show();
  });

  $('input[name="type"]:radio').on('change', function(event) {
    $('#prediction_test_data').get(0).type = $(this).val();
  });

  $('#btn-reset').on('click', function(event) {
    $('#prediction_test_data').get(0).type = 'file';
  });
});
