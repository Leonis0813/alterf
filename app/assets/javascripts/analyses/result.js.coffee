class window.AnalysisResult
  @WIDTH = 1100
  @HEIGHT = 500
  @X_AXIS = {
    ORIGIN: {x: 200, y: 25},
    RANGE: [0, AnalysisResult.WIDTH - 225],
  }
  @Y_AXIS = {
    ORIGIN: {x: 200, y: 0},
    RANGE: [25, AnalysisResult.HEIGHT - 50],
  }

  constructor: ->
    @drawImportance = (analysis_id) ->
      _importanceBar = new Bar(
        'importance',
        AnalysisResult.WIDTH,
        AnalysisResult.HEIGHT,
      )

      d3.json("/alterf/api/analyses/#{analysis_id}").then((analysis) ->
        importances = analysis.result.importances.sort((x, y) ->
          return d3.descending(x.value, y.value)
        )

        scale = {
          x: d3.scaleLinear().range(AnalysisResult.X_AXIS.RANGE),
          y: d3.scaleBand().rangeRound(AnalysisResult.Y_AXIS.RANGE),
        }

        max = d3.max(importances, (importance) -> importance.value)
        scale.x.domain([0, max])
        scale.y.domain(importances.map((importance) -> importance.feature_name))
        _importanceBar.drawXAxis(AnalysisResult.X_AXIS.ORIGIN, scale.x)
        _importanceBar.drawYAxis(AnalysisResult.Y_AXIS.ORIGIN, scale.y)

        bars = _createBars(importances, scale)
        _importanceBar.drawBars(bars)
        _setColor('importance')
        _setEvent('importance', scale)
      )
      return

    _createBars = (importances, scale) ->
      importances.map((importance) ->
        {
          x: AnalysisResult.X_AXIS.ORIGIN.x + scale.x(0),
          y: AnalysisResult.Y_AXIS.ORIGIN.y + scale.y(importance.feature_name) + 2.5,
          width: scale.x(importance.value),
          height: scale.y.bandwidth() - 5,
          value: importance.value,
        }
      )

    _setColor = (id) ->
      d3.select("##{id}")
        .selectAll('.bar')
        .attr('fill', 'green')
        .attr('opacity', 0.3)
      return

    _setEvent = (id, scale) ->
      d3.select("##{id}")
        .selectAll('rect')
        .on('mouseover', (bar) ->
          d3.select("##{id}")
            .append('text')
            .text(bar.value)
            .attr('x', bar.x + 5)
            .attr('y', bar.y + scale.y.bandwidth() / 2)
            .attr('class', 'value')
          return
        )
        .on('mouseout', () ->
          d3.select("##{id}")
            .select('text.value')
            .remove()
        )
      return
    return
