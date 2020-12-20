class window.Tree
  constructor: (id, width, height) ->
    _svg = d3.select("##{id}")
      .attr('width', width)
      .attr('height', height)
      .append('g')
      .attr('transform', 'translate(30,0)')

    _data = null
    _id = 0

    @getData = () -> _data

    @buildTree = (nodes, width, height) ->
      treeData = {
        node_id: nodes[0].node_id,
        name: nodes[0].feature_name,
        threshold: nodes[0].threshold,
        group: nodes[0].group,
        children: _buildChildren(nodes[0].node_id, nodes),
      }
      root = d3.hierarchy(treeData)
      root.x0 = AnalysisResult.HEIGHT / 2
      root.y0 = 0
      tree = d3.tree().size([height, width]).separation((a, b) -> 1.1)
      _data = tree(root)
      return

    @drawNodes = (source) ->
      that = this
      click = (node) ->
        if node.children
          node._children = node.children
          node.children = null
        else
          node.children = node._children
          node._children = null
        that.drawNodes(node)
        that.drawLinks(node)

      nodes = _data.descendants()
      nodes.forEach((node) -> node.y = node.depth * 150)

      oldNodes = _svg.selectAll('g.node')
        .data(nodes, (node) -> node.id || (node.id = ++_id))

      newNodes = oldNodes.enter()
        .append('g')
        .attr('class', 'node')
        .attr('transform', (node) -> "translate(#{source.y0},#{source.x0})")
        .on('click', click)
      newNodes.append('circle')
        .attr('class', 'node')
        .attr('r', 1e-6)
        .style('fill', (node) -> if node._children then 'lightsteelblue' else '#fff')
      newNodes.append('text')
        .attr('dy', '22')
        .attr('x', '-12')
        .attr('text-anchor', 'start')
        .attr('font-size', 10)
        .text((node) -> node.data.name)
      newNodes.append('text')
        .attr('dy', '35')
        .attr('x', '-12')
        .attr('font-size', 10)
        .text((node) -> node.data.threshold)
      newNodes.append('text')
        .attr('dy', '5')
        .attr('x', '-30')
        .text((node) ->
          if node.data.group == 'less'
            '<'
          else if node.data.group == 'greater'
            '>='
        )

      allNodes = newNodes.merge(oldNodes)
      allNodes.transition()
        .duration(750)
        .attr('transform', (node) -> "translate(#{node.y},#{node.x})")
      allNodes.select('circle.node')
        .attr('r', 10)
        .style('fill', (node) -> if node._children then 'lightsteelblue' else '#fff')
        .attr('cursor', 'pointer')

      removedNodes = oldNodes.exit()
        .transition()
        .duration(750)
        .attr('transform', (node) -> "translate(#{source.y},#{source.x})")
        .remove()
      removedNodes.select('circle').attr('r', 1e-6)
      removedNodes.select('text').style('fill-opacity', 1e-6)

      nodes.forEach((node) ->
        node.x0 = node.x
        node.y0 = node.y
      )
      return

    @drawLinks = (source) ->
      oldLinks = _svg.selectAll('path.link')
        .data(_data.descendants().slice(1), (node) -> node.id)

      newLinks = oldLinks.enter()
        .insert('path', 'g')
        .attr('class', 'link')
        .attr('d', (node) ->
          origin = {x: source.x0, y: source.y0}
          _calcDiagonal(origin, origin)
        )

      allLinks = newLinks.merge(oldLinks)
      allLinks.transition()
        .duration(750)
        .attr('d', (node) -> _calcDiagonal(node, node.parent))

      oldLinks.exit()
        .transition()
        .duration(750)
        .attr('d', (node) ->
          origin = {x: source.x, y: source.y}
          _calcDiagonal(origin, origin)
        )
        .remove()

    _buildChildren = (node_id, nodes) ->
      children = nodes.filter((node) -> node.parent_node_id == node_id)

      if children.length
        children = children.map((child) ->
          {
            node_id: child.node_id,
            name: child.feature_name,
            threshold: child.threshold,
            group: child.group,
            children: _buildChildren(child.node_id, nodes),
          }
        )
        return children
      else
        return []

    _calcDiagonal = (src, dest) ->
      "M #{src.y} #{src.x}
       C #{(src.y + dest.y) / 2} #{src.x},
         #{(src.y + dest.y) / 2} #{dest.x},
         #{dest.y} #{dest.x}"
    return
