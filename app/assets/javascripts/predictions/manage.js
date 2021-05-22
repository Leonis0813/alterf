$(function() {
  const executeDialog = new bootstrap.Modal(document.getElementById('dialog-execute'));
  const executeErrorDialog = new bootstrap.Modal(document.getElementById('dialog-execute-error'));

  $('#nav-link-prediction').addClass('active');

  $('#new_prediction').on('ajax:success', function(event) {
    executeDialog.show();
  });

  $('#new_prediction').on('ajax:error', function(event) {
    executeErrorDialog.show();
  });

  $('input[name="type"]:radio').on('change', function(event) {
    $('#prediction_test_data').get(0).type = $(this).val();
    if ($(this).val() === 'file') {
      $('#prediction_test_data').removeClass('form-control');
    } else {
      $('#prediction_test_data').addClass('form-control');
    }
  });
});
