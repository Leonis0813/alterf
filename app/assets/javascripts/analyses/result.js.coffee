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

  constructor: (analysis_id) ->
    @requestAnalysis = d3.json("/alterf/api/analyses/#{analysis_id}")

    @drawImportance = ->
      _importanceBar = new Bar('importance', AnalysisResult.WIDTH, AnalysisResult.HEIGHT)

      @requestAnalysis.then((analysis) ->
        importances = analysis.result.importances.sort((x, y) ->
          return d3.descending(x.value, y.value)
        )

        d3.select('#importance').attr('height', importances.length * 14 + 50)

        scale = {
          x: d3.scaleLinear().range(AnalysisResult.X_AXIS.RANGE),
          y: d3.scaleBand().rangeRound([25, importances.length * 14 + 25]),
        }

        max = d3.max(importances, (importance) -> importance.value)
        scale.x.domain([0, max])
        scale.y.domain(importances.map((importance) -> importance.feature_name))
        _importanceBar.drawXAxis(AnalysisResult.X_AXIS.ORIGIN, scale.x)
        _importanceBar.drawYAxis(AnalysisResult.Y_AXIS.ORIGIN, scale.y)

        bars = _createBars(importances, scale)
        _importanceBar.drawBars(bars, {color: 'green', opacity: 0.3})

        _importanceBar.setEvent('rect', 'mouseover', (bar) ->
          d3.select('#importance')
            .append('text')
            .text(bar.value)
            .attr('x', bar.x + 5)
            .attr('y', bar.y + scale.y.bandwidth() / 2)
            .attr('class', 'value')
          return
        )

        _importanceBar.setEvent('rect', 'mouseout', () ->
          d3.select('#importance').select('text.value').remove()
          return
        )
      )
      return

    @drawTree = (targetTreeId) ->
      @requestAnalysis.then((analysis) ->
        targetTree = analysis.result.decision_trees.find((decisionTree) ->
          decisionTree.tree_id == targetTreeId
        )

        _decisionTree = new Tree('decision_tree', AnalysisResult.WIDTH, AnalysisResult.HEIGHT)
        _decisionTree.buildTree(targetTree.nodes, AnalysisResult.WIDTH, AnalysisResult.HEIGHT)
        _decisionTree.getData().children.forEach(_collapse)
        _decisionTree.drawNodes(_decisionTree.getData())
        _decisionTree.drawLinks(_decisionTree.getData())
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

    _collapse = (node) ->
      if node.children
        node._children = node.children
        node._children.forEach(_collapse)
        node.children = null

    return
