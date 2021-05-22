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
    if ($(this).val() === 'file') {
      $('#prediction_test_data').removeClass('form-control');
    } else {
      $('#prediction_test_data').addClass('form-control');
    }
  });
});
