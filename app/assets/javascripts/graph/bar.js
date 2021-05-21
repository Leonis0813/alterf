class Bar {
  #svg;

  constructor(id, width, height) {
    this.#svg = d3.select('#' + id)
      .attr('width', width)
      .attr('height', height);
  }

  drawXAxis(origin, scale) {
    this.#svg.append('g')
      .attr('class', 'x axis')
      .attr('transform', 'translate(' + origin.x + ', ' + origin.y + ')')
      .call(d3.axisTop(scale));
  }

  drawYAxis(origin, scale) {
    this.#svg.append('g')
      .attr('class', 'y axis')
      .attr('transform', 'translate(' + origin.x + ', ' + origin.y + ')')
      .call(d3.axisLeft(scale));
  }

  drawBars(bars, options = {}) {
    this.#svg.selectAll('.bar')
      .data(bars)
      .enter()
      .append('rect')
      .attr('class', 'bar')
      .attr('x', function(bar) {
        return bar.x;
      })
      .attr('y', function(bar) {
        return bar.y;
      })
      .attr('height', function(bar) {
        return bar.height;
      })
      .attr('width', 0)
      .transition()
      .duration(1000)
      .attr('width', function(bar) {
        return bar.width;
      });

    if (options['color']) {
      this.#svg.selectAll('.bar').attr('fill', options['color']);
    }

    if (options['opacity']) {
      this.#svg.selectAll('.bar').attr('opacity', options['opacity']);
    }
  }

  setEvent(target, eventType, event) {
    this.#svg.selectAll(target).on(eventType, event);
  }
}
