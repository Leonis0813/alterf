class window.EvaluationResult
  @WIDTH = 1100
  @HEIGHT = 200
  @X_AXIS = {
    ORIGIN: {x: 50, y: 25},
    RANGE: [0, AnalysisResult.WIDTH - 100],
  }
  @Y_AXIS = {
    ORIGIN: {x: 50, y: 0},
    RANGE: [25, AnalysisResult.HEIGHT - 50],
  }
  @LABELS = ['F値', '特異度', '再現率', '適合率']

  constructor: ->
    _performanceBar = new Bar(
      'performance',
      EvaluationResult.WIDTH,
      EvaluationResult.HEIGHT
    )

    _scale = {
      x: d3.scaleLinear().range(EvaluationResult.X_AXIS.RANGE),
      y: d3.scaleBand().rangeRound([165, 25]),
    }

    @drawPerformance = (values) ->
      _scale.x.domain([0, 1])
      _scale.y.domain(EvaluationResult.LABELS)
      _performanceBar.drawXAxis(EvaluationResult.X_AXIS.ORIGIN, _scale.x)
      _performanceBar.drawYAxis(EvaluationResult.Y_AXIS.ORIGIN, _scale.y)

      bars = _createBars(values, _scale)
      _performanceBar.drawBars(bars, {color: 'orange', opacity: 0.5})
      return

    @updateBars = (values) ->
      bars = _createBars(values, _scale)
      d3.selectAll('.bar')
        .transition()
        .duration(1000)
        .attr('width', (bar) -> _scale.x(values[bar.index]))
      return

    _createBars = (performances, scale) ->
      performances.map((performance, i) ->
        {
          x: EvaluationResult.X_AXIS.ORIGIN.x + scale.x(0),
          y: EvaluationResult.Y_AXIS.ORIGIN.y + scale.y(EvaluationResult.LABELS[i]) + 7.5,
          width: scale.x(performance),
          height: scale.y.bandwidth() - 15,
          index: i,
        }
      )

    return
