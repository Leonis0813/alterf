$(function() {
  $('#nav-link-prediction').addClass('active');

  $('#new_prediction').on('ajax:success', function(event) {
    bootbox.alert({
      title: '予測を開始しました',
      message: '終了後、メールにて結果を通知します',
      callback: function() {
        $('.btn-submit').prop('disabled', false);
      }
    });
  });

  $('#new_prediction').on('ajax:error', function(event) {
    bootbox.alert({
      title: 'エラーが発生しました',
      message: '入力値を見直してください',
      callback: function() {
        $('.btn-submit').prop('disabled', false);
      }
    });
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
