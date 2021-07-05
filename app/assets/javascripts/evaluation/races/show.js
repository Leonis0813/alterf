import 'tablesorter';

$(function() {
  $('#table-evaluation-race').tablesorter({
    headers: {
      3: { sorter: false },
      4: { sorter: false },
      7: { sorter: false },
      13: { sorter: false },
      15: { sorter: false },
      17: { sorter: false },
      21: { sorter: false },
      22: { sorter: false },
    }
  });
});
