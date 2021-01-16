class window.Tree
  constructor: (id, tree) ->
    _svg = d3.select("##{id}")

    _width = 0
    _height = 0
    _data = null

    @getWidth = () -> _width
    @getHeight = () -> _height
    @getData = () -> _data

    @buildTreeStructure = () ->
      console.log(tree)
      root = tree.nodes[0]
      hierarchy = d3.hierarchy({
        node_id: root.node_id,
        name: root.feature_name,
        threshold: root.threshold,
        group: root.group,
        children: _buildChildren(root.node_id, tree.nodes),
      })

      depths = hierarchy.descendants().map((node) -> node.depth)
      maxDepth = depths.reduce((a, b) -> Math.max(a, b))
      depthCount = {}
      $.each(depths, (i, depth) ->
        if depthCount[depth]
          depthCount[depth] += 1
        else
          depthCount[depth] = 1
      )
      maxDepthCount = $.map(depthCount, (depth, count) -> count)
        .reduce((a, b) -> Math.max(a, b))

      _width = maxDepth * 150 + 50
      _height = maxDepthCount * 150 + 50

      tree = d3.tree().size([_height, _width]).separation((a, b) -> 2.0)

      _data = tree(hierarchy)
      nodes = _data.descendants()
      nodes.forEach((node) ->
        node.x = node.x * 1.5
        node.y = node.depth * 170
      )

      _width = $.map(nodes, (node) -> node.y).reduce((a, b) -> Math.max(a, b)) + 200
      _height = $.map(nodes, (node) -> node.x).reduce((a, b) -> Math.max(a, b)) + 100
      _svg = _svg.attr('width', _width)
        .attr('height', _height)
        .append('g')
        .attr('transform', 'translate(30,0)')
      return

    @drawNodes = () ->
      nodes = _data.descendants()

      g = _svg.selectAll('g.node')
        .data(nodes)
        .enter()
        .append('g')
        .attr('class', 'node')
        .attr('transform', (node) -> "translate(#{node.y},#{node.x})")
      g.append('circle')
        .attr('class', 'node')
        .attr('r', 10)
        .attr('fill', (node) ->
          if node.data.type == 'leaf'
            "url('#node_#{node.data.node_id}')"
          else
            'white'
        )
      g.append('text')
        .attr('dy', '22')
        .attr('x', '-12')
        .attr('text-anchor', 'start')
        .attr('font-size', 10)
        .text((node) ->
          if node.data.type == 'leaf'
            "win: #{node.data.num_win} lose: #{node.data.num_lose}"
          else
            node.data.name
          )
      g.append('text')
        .attr('dy', '35')
        .attr('x', '-12')
        .attr('font-size', 10)
        .text((node) -> node.data.threshold)
      g.append('text')
        .attr('dy', '5')
        .attr('x', '-30')
        .text((node) ->
          if node.data.group == 'less'
            '<'
          else if node.data.group == 'greater'
            '>='
        )

      leaves = $.grep(nodes, (node, i) ->
        node.data.type == 'leaf'
      )
      linearGradient = _svg.selectAll('linearGradient')
        .data(leaves)
        .enter()
        .append('linearGradient')
        .attr('id', (leaf) -> "node_#{leaf.data.node_id}")
      linearGradient.append('stop')
        .attr('offset', '0%')
        .attr('stop-opacity', 0.7)
        .attr('stop-color', 'red')
      linearGradient.append('stop')
        .attr('offset', (leaf) -> "#{_winRate(leaf.data)}%")
        .attr('stop-opacity', 0.7)
        .attr('stop-color', 'red')
      linearGradient.append('stop')
        .attr('offset', (leaf) -> "#{_winRate(leaf.data)}%")
        .attr('stop-opacity', 0.7)
        .attr('stop-color', 'blue')
      linearGradient.append('stop')
        .attr('offset', '100%')
        .attr('stop-opacity', 0.7)
        .attr('stop-color', 'blue')
      return

    @drawLinks = () ->
      _svg.selectAll('path.link')
        .data(_data.descendants().slice(1))
        .enter()
        .insert('path', 'g')
        .attr('class', 'link')
        .attr('d', (node) -> _calcDiagonal(node, node.parent))
      return

    _buildChildren = (node_id, nodes) ->
      children = nodes.filter((node) -> node.parent_node_id == node_id)

      if children.length
        children = children.map((child) ->
          {
            node_id: child.node_id,
            name: child.feature_name,
            type: child.node_type,
            threshold: child.threshold,
            group: child.group,
            num_win: child.num_win,
            num_lose: child.num_lose,
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

    _winRate = (data) ->
      100 * parseFloat(data.num_win) / (data.num_win + data.num_lose)
    return
