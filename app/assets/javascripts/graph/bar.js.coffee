class window.Bar
  constructor: (id, width, height) ->
    _svg = d3.select("##{id}")
      .attr('width', width)
      .attr('height', height)

    @drawXAxis = (origin, scale) ->
      _svg.append('g')
        .attr('class', 'x axis')
        .attr('transform', "translate(#{origin.x}, #{origin.y})")
        .call(d3.axisTop(scale))
      return

    @drawYAxis = (origin, scale) ->
      _svg.append('g')
        .attr('class', 'y axis')
        .attr('transform', "translate(#{origin.x}, #{origin.y})")
        .call(d3.axisLeft(scale))
      return

    @drawBars = (bars) ->
      _svg.selectAll('.bar')
        .data(bars)
        .enter()
        .append('rect')
        .attr('class', 'bar')
        .attr('x', (bar) -> bar.x)
        .attr('y', (bar) -> bar.y)
        .attr('width', (bar) -> bar.width)
        .attr('height', (bar) -> bar.height)
      return
    return
