class Tree {
  #svg;
  #width;
  #height;
  #data;

  constructor(id) {
    this.#svg = d3.select('#' + id);
    this.#width = 0;
    this.#height = 0;
    this.#data = null;
  }

  getWidth() {
    return this.#width;
  }

  getHeight() {
    return this.#height;
  }

  getData() {
    return this.#data;
  }

  buildTreeStructure(tree) {
    root = tree.nodes[0];
    hierarchy = d3.hierarchy({
      node_id: root.node_id,
      name: root.feature_name,
      threshold: root.threshold,
      group: root.group,
      children: this.#buildChildren(root.node_id, tree.nodes),
    });

    depths = hierarchy.descendants().map(function(node) {
      return node.depth;
    });
    maxDepth = depths.reduce(function(a, b) {
      return Math.max(a, b);
    });
    depthCount = {};
    $.each(depths, function(i, depth) {
      if (depthCount[depth]) {
        depthCount[depth] += 1;
      } else {
        depthCount[depth] = 1;
      }
    });
    maxDepthCount = $.map(depthCount, function(depth, count) {
      return count;
    }).reduce(function(a, b) {
      return Math.max(a, b);
    });

    this.#width = maxDepth * 150 + 50;
    this.#height = maxDepthCount * 150 + 50;

    tree = d3.tree().size([this.#height, this.#width]).separation(function(a, b) {
      return 2.0;
    });

    this.#data = tree(hierarchy);
    nodes = this.#data.descendants();
    nodes.forEach(function(node) {
      node.x = node.x * maxDepth * 0.28;
      node.y = node.depth * 170;
    });

    this.#width = $.map(nodes, function(node) {
      return node.y;
    }).reduce(function(a, b) {
      return Math.max(a, b);
    }) + 200;
    this.#height = $.map(nodes, function(node) {
      return node.x;
    }).reduce(function(a, b) {
      return Math.max(a, b);
    }) + 100;
    this.#svg = this.#svg.attr('width', this.#width)
      .attr('height', this.#height)
      .append('g')
      .attr('transform', 'translate(30,0)');
  }

  drawNodes() {
    nodes = this.#data.descendants();

    g = this.#svg.selectAll('g.node')
      .data(nodes)
      .enter()
      .append('g')
      .attr('class', 'node')
      .attr('transform', function(node) {
        return 'translate(' + node.y + ', ' + node.x + ')';
      });
    g.append('circle')
      .attr('class', 'node')
      .attr('r', 10)
      .attr('fill', function(node) {
        if (node.data.type === 'leaf') {
          return "url('#node_" + node.data.node_id + "')";
        } else {
          return 'white';
        }
      });
    g.append('text')
      .attr('dy', '22')
      .attr('x', '-12')
      .attr('text-anchor', 'start')
      .attr('font-size', 10)
      .text(function(node) {
        if (node.data.type === 'leaf') {
          return 'win: ' + node.data.num_win + ' lose: ' + node.data.num_lose
        } else {
          return node.data.name;
        }
      });
    g.append('text')
      .attr('dy', '35')
      .attr('x', '-12')
      .attr('font-size', 10)
      .text(function(node) {
        return node.data.threshold;
      });
    g.append('text')
      .attr('dy', '5')
      .attr('x', '-30')
      .text(function(node) {
        if (node.data.group === 'less') {
          return '<';
        } else if (node.data.group === 'greater') {
          return '>=';
        }
      });

    leaves = $.grep(nodes, function(node, i) {
        return node.data.type === 'leaf';
    });
    linearGradient = this.#svg.selectAll('linearGradient')
      .data(leaves)
      .enter()
      .append('linearGradient')
      .attr('id', function(leaf) {
        return 'node_' + leaf.data.node_id;
      });
    linearGradient.append('stop')
      .attr('offset', '0%')
      .attr('stop-opacity', 0.7)
      .attr('stop-color', 'red');
    linearGradient.append('stop')
      .attr('offset', function(leaf) {
        return this.#winRate(leaf.data) + '%';
      })
      .attr('stop-opacity', 0.7)
      .attr('stop-color', 'red');
    linearGradient.append('stop')
      .attr('offset', function(leaf) {
        return this.#winRate(leaf.data) + '%';
      })
      .attr('stop-opacity', 0.7)
      .attr('stop-color', 'blue')
    linearGradient.append('stop')
      .attr('offset', '100%')
      .attr('stop-opacity', 0.7)
      .attr('stop-color', 'blue');
  }

  drawLinks() {
    this.#svg.selectAll('path.link')
      .data(this.#data.descendants().slice(1))
      .enter()
      .insert('path', 'g')
      .attr('class', 'link')
      .attr('d', function(node) {
        return this.#calcDiagonal(node, node.parent);
      });
  }

  #buildChildren(node_id, nodes) {
    children = nodes.filter(function(node) {
      return node.parent_node_id === node_id;
    });

    if (children.length) {
      children = children.map(function(child) {
        return {
          node_id: child.node_id,
          name: child.feature_name,
          type: child.node_type,
          threshold: child.threshold,
          group: child.group,
          num_win: child.num_win,
          num_lose: child.num_lose,
          children: this.#buildChildren(child.node_id, nodes),
        };
      });
      return children;
    } else {
      return [];
    }
  }

  #calcDiagonal(src, dest) {
    return 'M ' +  src.y + ' ' + src.x +
           'C ' + (src.y + dest.y) / 2 + ' ' + src.x + ',' +
           (src.y + dest.y) / 2 + ' ' + dest.x + ',' +
           dest.y + ' ' + dest.x
  }

  #winRate(data) {
    return 100 * parseFloat(data.num_win) / (data.num_win + data.num_lose);
  }
}
