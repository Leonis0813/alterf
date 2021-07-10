import 'tablesorter';

$(function() {
  ['raw-data', 'feature'].forEach(function(type) {
    $(`#table-evaluation-race-${type}`).tablesorter({
      headers: {
        4: { sorter: false },
        5: { sorter: false },
        8: { sorter: false },
        14: { sorter: false },
        16: { sorter: false },
        18: { sorter: false },
        22: { sorter: false },
        23: { sorter: false },
      }
    });
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

    const min = Math.min(...values);
    const max = Math.max(...values);
    const scale = d3.scaleLinear().domain([min, max]).range([0, 1.0]);
    const normalizedValues = values.map(value => scale(value));

    elements.each(function(i, e) {
      e.innerText = min === max ? 0.0 : normalizedValues[i];
    });
  });

  const mapping = {
    direction: {'右': 0, '左': 1, '直': 2, '障': 3},
    grade: {'N': 0, 'G1': 1, 'G2': 2, 'G3': 3, 'G': 4, 'J.G1': 5, 'J.G2': 6, 'J.G3': 7, 'L': 8, 'OP': 9},
    place: {'中京': 0, '中山:': 1, '京都': 2, '函館': 3, '小倉': 4, '新潟': 5, '札幌': 6, '東京': 7, '福島': 8, '阪神': 9},
    running_style: {'逃げ': 0, '先行': 1, '差し': 2, '追込': 3},
    sex: {'牝': 0, '牡': 1, 'セ': 2},
    track: {'芝': 0, 'ダート': 1, '障': 2},
    weather: {'晴': 0, '曇': 1, '小雨': 2, '雨': 3, '小雪': 4, '雪': 5},
  };

  Object.keys(mapping).forEach(function(featureName) {
    let featureMap = mapping[featureName];

    $(`#table-evaluation-race-feature td.${featureName}`).each(function(i, e) {
      e.innerText = featureMap[e.innerText.trim()];
    });
  });
});
