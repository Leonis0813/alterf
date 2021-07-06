import 'tablesorter';

$(function() {
  $('#table-evaluation-race-raw-data').tablesorter({
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

  $('#table-evaluation-race-feature').tablesorter({
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

  const racewiseFeatures = [
    'blank',
    'burden_weight',
    'entry_times',
    'horse_average_prize_money',
    'jockey_average_prize_money',
    'jockey_win_rate',
    'jockey_win_rate_last_four_races',
    'rate_within_third',
    'weight',
    'weight_diff',
    'weight_per',
    'win_times',
  ];
  racewiseFeatures.forEach(function(featureName) {
    const elements = $(`#table-evaluation-race-feature td.${featureName}`);
    const values = [];
    elements.each(function(i, e) {
      values.push(parseFloat(e.innerText));
    });

    const scale = d3.scaleLinear()
            .domain([Math.min(...values), Math.max(...values)])
            .range([0, 1.0]);
    const normalizedValues = values.map(value => scale(value));

    elements.each(function(i, e) {
      e.innerText = normalizedValues[i];
    });
  });
});
