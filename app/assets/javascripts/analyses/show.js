$(function() {
  $('#tree_id').on('change', function() {
    $('#decision_tree').children().remove();
    result.drawTree(parseInt($(@).val()));
  });
});

class AnalysisResult {
  static WIDTH = 1100;
  static HEIGHT = 1340;
  static X_AXIS = {
    ORIGIN: {x: 200, y: 25},
    RANGE: [0, AnalysisResult.WIDTH - 225],
  };
  static Y_AXIS = {
    ORIGIN: {x: 200, y: 0},
    RANGE: [25, AnalysisResult.HEIGHT - 50],
  };

  #requestAnalysis;

  constructor(analysisId) {
    this.#requestAnalysis = d3.json('/alterf/api/analyses/' + analysisId);
  }

  drawImportance() {
    const importanceBar = new Bar('importance', AnalysisResult.WIDTH, AnalysisResult.HEIGHT);

    this.#requestAnalysis.then(function(analysis) {
      const importances = analysis.result.importances.sort(function(x, y) {
        return d3.descending(x.value, y.value);
      });

      d3.select('#importance').attr('height', importances.length * 14 + 50);

      const scale = {
        x: d3.scaleLinear().range(AnalysisResult.X_AXIS.RANGE),
        y: d3.scaleBand().rangeRound([25, importances.length * 14 + 25]),
      };

      const max = d3.max(importances, function(importance) {
        return importance.value;
      });
      scale.x.domain([0, max]);
      scale.y.domain(importances.map(function(importance) {
        return importance.feature_name;
      }));
      importanceBar.drawXAxis(AnalysisResult.X_AXIS.ORIGIN, scale.x);
      importanceBar.drawYAxis(AnalysisResult.Y_AXIS.ORIGIN, scale.y);

      const bars = this.#createBars(importances, scale);
      importanceBar.drawBars(bars, {color: 'green', opacity: 0.3});

      importanceBar.setEvent('rect', 'mouseover', function(bar) {
        d3.select('#importance')
          .append('text')
          .text(bar.value)
          .attr('x', bar.x + 5)
          .attr('y', bar.y + scale.y.bandwidth() / 2)
          .attr('class', 'value');
      });

      importanceBar.setEvent('rect', 'mouseout', function() {
        d3.select('#importance').select('text.value').remove();
      });
    });
  }

  drawTree(targetTreeId) {
    this.#requestAnalysis.then(function(analysis) {
      const targetTree = analysis.result.decision_trees.find(function(decisionTree) {
        return decisionTree.tree_id === targetTreeId;
      });

      const decisionTree = new Tree('decision_tree');
      decisionTree.buildTreeStructure(targetTree);

      if (AnalysisResult.WIDTH < decisionTree.getWidth()) {
        const width = decisionTree.getWidth() + 50;
        d3.select('#tab-decision_tree').style('width', width + 'px');
      }
      if (AnalysisResult.HEIGHT < decisionTree.getHeight()) {
        const height = decisionTree.getHeight() + 100;
        d3.select('#tab-decision_tree').style('height', height + 'px');
      }
      decisionTree.drawNodes();
      decisionTree.drawLinks();
    });
  }

  #createBars(importances, scale) {
    importances.map(function(importance) {
      return {
        x: AnalysisResult.X_AXIS.ORIGIN.x + scale.x(0),
        y: AnalysisResult.Y_AXIS.ORIGIN.y + scale.y(importance.feature_name) + 2.5,
        width: scale.x(importance.value),
        height: scale.y.bandwidth() - 5,
        value: importance.value,
      };
    });
  }
}
