const EvaluationResult = class {
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
    this.#performanceBar = new Bar('performance', this.WIDTH, this.HEIGHT);

    this.#scale = {
      x: d3.scaleLinear().range(this.X_AXIS.RANGE),
      y: d3.scaleBand().rangeRound([165, 25]),
    };
  }

  drawPerformance(values) {
    const labels = this.constructor.LABELS;
    const x_axis = this.constructor.X_AXIS;
    const y_axis = this.constructor.Y_AXIS;

    this.#scale.x.domain([0, 1]);
    this.#scale.y.domain(labels);
    this.#performanceBar.drawXAxis(x_axis.ORIGIN, this.#scale.x);
    this.#performanceBar.drawYAxis(y_axis.ORIGIN, this.#scale.y);

    const bars = this.#createBars(values);
    this.#performanceBar.drawBars(bars, {color: 'orange', opacity: 0.5});
  }

  updateBars(values) {
    const that = this;

    const bars = this.#createBars(values);
    d3.selectAll('.bar')
      .transition()
      .duration(1000)
      .attr('width', function(bar) {
        that.#scale.x(values[bar.index]);
      });
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
      };
    });
  }
