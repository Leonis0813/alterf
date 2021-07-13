export function showDialog(id) {
  const dialog = new bs.Modal(document.getElementById(id));
  dialog.show();
};

export function showParameterDialog(analysisId) {
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
};
