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
        console.log(targetTree)
        tree = {
          node_id: targetTree.nodes[0].node_id,
          name: targetTree.nodes[0].feature_name,
          threshold: targetTree.nodes[0].threshold,
          children: _createChildren(targetTree.nodes[0].node_id, targetTree.nodes),
        }
        console.log(tree)

        root = d3.hierarchy(tree, (node) -> return node.children)
        root.x0 = AnalysisResult.HEIGHT / 2
        root.y0 = 0
        root.children.forEach(_collapse)

        d3.select('#decision_tree')
          .attr('width', AnalysisResult.WIDTH)
          .attr('height', AnalysisResult.HEIGHT)
          .append('g')
          .attr('transform', 'translate(90,0)')
        treemap = d3.tree().size([AnalysisResult.HEIGHT, AnalysisResult.WIDTH])
        _update(root, root, treemap)
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

    _createChildren = (node_id, nodes) ->
      children = nodes.filter((node) ->
        return node.parent_node_id == node_id
      )

      if children.length
        children = children.map((child) ->
          {
            node_id: child.node_id,
            name: child.feature_name,
            threshold: child.threshold,
            children: _createChildren(child.node_id, nodes),
          }
        )
        return children
      else
        return []

    _collapse = (node) ->
      if node.children
        node._children = node.children
        node._children.forEach(_collapse)

    _update = (source, root, treemap) ->
      i = 0
      treeData = treemap(root)
      diagonal = (src, dest) ->
        return "M #{src.y} #{src.x}
                C #{(src.y + dest.y) / 2} #{src.x},
                #{(src.y + dest.y) / 2} #{dest.x},
                #{dest.y} #{dest.x}"

      click = (node) ->
        if node.children
          node._children = node.children
          node.children = null
        else
          node.children = node._children
          node._children = null
        _update(node, root, treemap)

      nodes = treeData.descendants()
      links = treeData.descendants().slice(1)

      nodes.forEach((node) -> node.y = node.depth * 180)

      node = d3.select('#decision_tree')
               .selectAll('g.node')
               .data(nodes, (node) -> return node.id || (node.id = ++i))

      nodeEnter = node.enter()
                      .append('g')
                      .attr('class', 'node')
                      .attr('transform', (node) ->
                        return "translate(#{source.y0},#{source.x0})"
                      )
                      .on('click', click)

      nodeEnter.append('circle')
               .attr('class', 'node')
               .attr('r', 1e-6)
               .style('fill', (node) ->
                 return if node._children then 'lightsteelblue' else '#fff'
               )

      nodeEnter.append('text')
               .attr('dy', '.35em')
               .attr('x', (node) ->
                 return if node.children || node._children then -13 else 13
               )
               .attr('text-anchor', (node) ->
                 return if node.children || node._children then 'end' else 'start'
               )
               .text((node) -> return node.data.name)

      nodeUpdate = nodeEnter.merge(node)
      nodeUpdate.transition()
                .duration(750)
                .attr('transform', (node) ->
                  return "translate(#{node.y},#{node.x})"
                )
      nodeUpdate.select('circle.node')
                .attr('r', 10)
                .style('fill', (node) ->
                  return if node._children then 'lightsteelblue' else '#fff'
                )
                .attr('cursor', 'pointer')

      nodeExit = node.exit()
                     .transition()
                     .duration(750)
                     .attr('transform', (node) ->
                       return "translate(#{source.y},#{source.x})"
                     )
                     .remove()
      nodeExit.select('circle').attr('r', 1e-6)
      nodeExit.select('text').style('fill-opacity', 1e-6)

      link = d3.select('#decision_tree')
               .selectAll('path.link')
               .data(links, (node) -> return node.id)

      linkEnter = link.enter()
                      .insert('path', 'g')
                      .attr('class', 'link')
                      .attr('d', (node) ->
                        origin = {x: source.x0, y: source.y0}
                        return diagonal(origin, origin)
                      )

      linkUpdate = linkEnter.merge(link)
      linkUpdate.transition()
                .duration(750)
                .attr('d', (node) -> return diagonal(node, node.parent))

      linkExit = link.exit()
                     .transition()
                     .duration(750)
                     .attr('d', (node) ->
                       origin = {x: source.x, y: source.y}
                       return diagonal(origin, origin)
                     )
                     .remove()

      nodes.forEach((node) ->
        node.x0 = node.x
        node.y0 = node.y
      )
      return
    return
