export default class EvaluationResult {
  static WIDTH = 1100;
  static HEIGHT = 200;
  static X_AXIS = {
    ORIGIN: {x: 50, y: 25},
    RANGE: [0, 1000],
  };
  static Y_AXIS = {
    ORIGIN: {x: 50, y: 0},
    RANGE: [25, 150],
  };
  static LABELS = ['F値', '特異度', '再現率', '適合率'];

  #performanceBar;
  #scale;

  constructor() {
    const width = this.constructor.WIDTH;
    const height = this.constructor.HEIGHT;
    const x_axis = this.constructor.X_AXIS;

    this.#performanceBar = new Bar('performance', width, height);

    this.#scale = {
      x: d3.scaleLinear().range(x_axis.RANGE),
      y: d3.scaleBand().rangeRound([165, 25]),
    };
  }

  drawPerformance(values) {
    const labels = this.constructor.LABELS;
    const x_axis = this.constructor.X_AXIS;
    const y_axis = this.constructor.Y_AXIS;

    this.#scale.x.domain([0, 1]);
    this.#scale.y.domain(labels);

    const bars = this.#createBars(values);
    this.#performanceBar.drawXAxis(x_axis.ORIGIN, this.#scale.x);
    this.#performanceBar.drawYAxis(y_axis.ORIGIN, this.#scale.y);
    this.#performanceBar.drawBars(bars, {color: 'orange', opacity: 0.5});
    this.#appendText(values);
  }

  updateBars(values) {
    const that = this;

    const bars = this.#createBars(values);
    d3.selectAll('.bar')
      .transition()
      .duration(1000)
      .attr('width', function(bar) {
        return that.#scale.x(values[bar.index]);
      });
    this.#appendText(values);
  }

  #createBars(performances) {
    const that = this;
    const labels = this.constructor.LABELS;
    const x_axis = this.constructor.X_AXIS;
    const y_axis = this.constructor.Y_AXIS;

    return performances.map(function(performance, i) {
      return {
        x: x_axis.ORIGIN.x + that.#scale.x(0),
        y: y_axis.ORIGIN.y + that.#scale.y(labels[i]) + 7.5,
        width: that.#scale.x(performance),
        height: that.#scale.y.bandwidth() - 15,
        index: i,
        value: performance,
      };
    });
  }

  #appendText(values) {
    d3.selectAll('text.value').remove();
    d3.selectAll('.bar')
      .append('text')
      .text(function(bar) {
        return values[bar.index];
      })
      .attr('x', function(bar) {
        return bar.x + that.#scale.x(values[bar.index]) + 5;
      })
      .attr('y', function(bar) {
        return bar.y + that.#scale.y.bandwidth() / 2;
      })
      .attr('class', 'value');
  }
};

$(function() {
  $('#nav-link-evaluation').addClass('active');

  document.querySelectorAll('[data-bs-toggle="tooltip"]').forEach(function (tooltip) {
    return new bs.Tooltip(tooltip);
  });

  $('#table-evaluation-result').on('click', 'td', function(event) {
    if (event.target.tagName === 'A') {
      return;
    }

    const evaluationId = $('#table-evaluation-result').data('evaluation-id');
    const raceId = $(this).parents('tr').attr('id');
    open(`/alterf/evaluations/${evaluationId}/races/${raceId}`, '_blank');
  });
});
