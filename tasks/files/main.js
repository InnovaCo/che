var color = d3.scale.category20(),
	svg = d3.select('body')
		.append('svg')
		.attr('width', 1200)
		.attr('height', 1200),
	handler = function(node, index) {
		nodes.style('stroke-opacity', function(nodeItem) {
			var opacity = 1;

			if (node) {
				if (nodeItem.index != index && !conections[index + '-' + nodeItem.index]) {
					opacity = inactiveOpacity;
				}
				this.classList.add('active');

				if (reverseConections[index + '-' + nodeItem.index]) {
					this.classList.add('reverse-connection');
				}
			} else {
				this.classList.remove('active');
				this.classList.remove('reverse-connection');
			}

			this.setAttribute('fill-opacity', opacity);
			this.setAttribute('stroke-opacity', opacity);

			return opacity;
		});

		links.style('stroke-opacity', function(linkItem) {
			var opacity = 1;

			if (linkItem.source !== node) {
				if (node) {
					opacity = inactiveOpacity;
				}
				this.setAttribute('stroke-opacity', opacity);
				this.setAttribute('marker-end', '');
				this.classList.remove('active');
				this.classList.remove('reverse-connection');
			} else {
				this.setAttribute('marker-end', 'url(#regular' + (5 * linkItem.target.priority) + ')');
				this.classList.add('active');
			}

			if (linkItem.target === node) {
				this.setAttribute('marker-end', 'url(#regular' + (5 * node.priority) + ')');
				this.classList.add('reverse-connection');
			}
			return opacity;
		});
	},
	createMarker = function(r) {
		if (!markerCollection[r]) {
			markerCollection[r] = true;
			svg
				.append('defs')
				.selectAll('marker')
				.data(['regular' + r])
				.enter()
				.append('marker')
				.attr('id', String)
				.attr('viewBox', '0 -5 10 10')
				.attr('refX', (r * 2) + 10) 
				.attr('refY', 0)
				.attr('markerWidth', 6)
				.attr('markerHeight', 6)
				.attr('orient', 'auto')
				.append('path')
				.attr('d', 'M0,-5L10,0L0,5');
		}
	},
	inactiveOpacity = .2,
	reverseConections = {},
	markerCollection = {},
	conections = {},
	links,
	nodes;

d3.json('data.json', function (error, graph) {
	var force = d3.layout.force()
		.charge(graph.charge)
		.linkDistance(graph.linkDistance)
		.size([graph.sizeX, graph.sizeY]);

	// Создаем коллекции прямых и обратных связей нодов для последующей быстрой отрисовки линий 
	// связи.
	for (var i = 0, length = graph.links.length, link; i < length; i++) {
		link = graph.links[i];
		conections[link.source + '-' + link.target] = true;
		reverseConections[link.target + '-' + link.source] = true;
	};

	force
		.nodes(graph.nodes)
		.links(graph.links)
		.on('tick', function () {
			links
				.attr('x1', function (d) {
					return d.source.x;
				})
				.attr('y1', function (d) {
					return d.source.y;
				})
				.attr('x2', function (d) {
					return d.target.x;
				})
				.attr('y2', function (d) {
					return d.target.y;
				});

			nodes
				.attr('cx', function(d) {
					return d.x;
				})
				.attr('cy', function(d) {
					return d.y;
				})
				.attr('transform', function(d) {
					return 'translate(' + d.x + ',' + d.y + ')';
				});
		})
		.start();

	// Создаем связи.
	links = svg.selectAll('.link')
		.data(graph.links)
		.enter()
		.append('line')
		.attr('class', function(d) {
			var className = 'link ' + ['link', d.source.index, d.target.index].join('-');

			if (d.forceDependency) {
				className += ' link-force-dep';
			}

			return className;
		})
		.style('stroke-width', function (d) {
			return Math.sqrt(d.value);
		});

	// Создаем группы для кружочка с текстом.
	nodes = svg.selectAll('.node')
		.data(graph.nodes)
		.enter()
		.append('g')
		.attr('class', function(d) {
			return 'node node-' + d.index;
		})
		.call(force.drag);

	// Создаем визуальный кружок символизирующий модуль.
	nodes
		.append('circle')
		.attr('r', function(d) {
			var r = 5 * d.priority;

			createMarker(r);
			return r;
		})
		.style('fill', function (d) {
			return color(d.group);
		})
		.on('mouseover', function(node, index) {
			handler.apply(this, arguments);
		})
		.on('mouseout', function() {
			handler();
		});

	// Так как d3.js не позволяет копировать ноды, то создаем еще один нод текста 
	// белого цвета для того чтоб текст не сливался с фоном.
	nodes
		.append('text')
		.attr('x', 15)
		.attr('y', '.31em')
		.attr('stroke', '#fff')
		.style('stroke-width', 3)
		.text(function (d) {
			return d.id;
		});

	// Создаем уже основной нод текста.
	nodes
		.append('text')
		.attr('x', 15)
		.attr('y', '.31em')
		.attr('stroke', '#000')
		.style('stroke-width', .5)
		.text(function (d) {
			return d.id;
		});
});