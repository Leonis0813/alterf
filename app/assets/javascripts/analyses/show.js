const AnalysisResult = class {
  static WIDTH = 1100;
  static HEIGHT = 1340;
  static X_AXIS = {
    ORIGIN: {x: 200, y: 25},
    RANGE: [0, 875],
  };
  static Y_AXIS = {
    ORIGIN: {x: 200, y: 0},
    RANGE: [25, 1290],
  };

  constructor(analysisId) {
    this.analysisId = analysisId;
  }

  drawImportance() {
    const x_axis = this.constructor.X_AXIS;
    const y_axis = this.constructor.Y_AXIS;
    const importanceBar = new Bar('importance', this.constructor.WIDTH, this.constructor.HEIGHT);

    const that = this;
    d3.json(`${this.basePath()}/importances`).then((response) => {
      const importances = response.importances.sort((x, y) => {
        return d3.descending(x.value, y.value);
      });

      d3.select('#importance').attr('height', importances.length * 14 + 50);

      const scale = {
        x: d3.scaleLinear().range(x_axis.RANGE),
        y: d3.scaleBand().rangeRound([25, importances.length * 14 + 25]),
      };

      const max = d3.max(importances, (importance) => {
        return importance.value;
      });
      scale.x.domain([0, max]);
      scale.y.domain(importances.map((importance) => importance.feature_name));

      importanceBar.drawXAxis(x_axis.ORIGIN, scale.x);
      importanceBar.drawYAxis(y_axis.ORIGIN, scale.y);

      const bars = that.createBars(importances, scale);
      importanceBar.drawBars(bars, {color: 'green', opacity: 0.3});

      importanceBar.setEvent('rect', 'mouseover', (event, bar) => {
        d3.select('#importance')
          .append('text')
          .text(bar.value)
          .attr('x', bar.x + 5)
          .attr('y', bar.y + scale.y.bandwidth() / 2)
          .attr('class', 'value');
      });

      importanceBar.setEvent('rect', 'mouseout', () => {
        d3.select('#importance').select('text.value').remove();
      });
    });
  }

  drawTree(decisionTreeId) {
    d3.json(`${this.basePath()}/decision_trees/${decisionTreeId}`).then((response)  => {
      const decisionTree = new Tree('decision_tree');
      decisionTree.buildTreeStructure(response);

      if (this.constructor.WIDTH < decisionTree.getWidth()) {
        const width = decisionTree.getWidth() + 50;
        d3.select('#tab-decision_tree').style('width', `${width}px`);
      }
      if (this.constructor.HEIGHT < decisionTree.getHeight()) {
        const height = decisionTree.getHeight() + 100;
        d3.select('#tab-decision_tree').style('height', `${height}px`);
      }
      decisionTree.drawNodes();
      decisionTree.drawLinks();
    });
  }

  basePath() {
    return `/alterf/api/analyses/${this.analysisId}/result`;
  }

  createBars(importances, scale) {
    const x_axis = this.constructor.X_AXIS;
    const y_axis = this.constructor.Y_AXIS;

    return importances.map((importance) => {
      return {
        x: x_axis.ORIGIN.x + scale.x(0),
        y: y_axis.ORIGIN.y + scale.y(importance.feature_name) + 2.5,
        width: scale.x(importance.value),
        height: scale.y.bandwidth() - 5,
        value: importance.value,
      };
    });
  }
};

$(function() {
  $('#nav-link-analysis').addClass('active');

  $('#decision_tree_id').on('change', (event) => {
    $('#decision_tree').children().remove();
    result.drawTree(event.target.value);
  });

  const analysisId = location.pathname.replace('/alterf/analyses/', '');
  const result = new AnalysisResult(analysisId);
  result.drawImportance();
});
