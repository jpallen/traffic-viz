container = d3
	.select("body")
	.append("svg")
	.attr("height", "100%")
	.attr("width", "100%")

getQueryParams = () ->
	pl     = /\+/g
	search = /([^&=]+)=?([^&]*)/g
	decode = (s) -> return decodeURIComponent(s.replace(pl, " "))
	query  = window.location.search.substring(1)

	urlParams = {}
	while (match = search.exec(query))
		urlParams[decode(match[1])] = decode(match[2]);
	
	return urlParams

randomPointInCircle = (x, y, r) ->
	# Return a uniformly distributed random point in the circle with center
	# at c = {x:..., y:...} and radius r.
	
	# Start outside the circle. (_x, _y) are inside circle centered at 0,0
	_x = r
	_y = r
	while (Math.pow(_x, 2) + Math.pow(_y, 2) > Math.pow(r, 2))
		_x = 2 * r * Math.random() - r
		_y = 2 * r * Math.random() - r
	return {x: x + _x, y: y + _y}

drawPacket = (size, duration, hue, from_node, to_node) ->
	from = randomPointInCircle(from_node.x, from_node.y, from_node.size - size)
	to = randomPointInCircle(to_node.x, to_node.y, to_node.size - size)
	if hue?
		color = "hsl(#{hue}, 100%, 50%)"
	else
		color = "#ccc"
	packet = container.append("circle")
		.attr("cx", from.x)
		.attr("cy", from.y)
		.attr("r", size)
		.attr("fill", color)
		.transition()
		.ease("linear")
		.duration(duration)
		.attr("cx", to.x)
		.attr("cy", to.y)
		.remove()

NODE_SIZE = 15
PADDING = 20
NODES = []

addNode = (name, size) ->
	node = {name, size}
	NODES.push node
	NODES.sort (a,b) ->
		if a.name > b.name
			return 1
		else if a.name < b.name
			return -1
		else
			return 0
	redrawNodes()
	return node

recalculateNodePositions = () ->
	if getQueryParams()["layout"] == "rows"
		recalculateNodePositionsInRows()
	else if getQueryParams()["layout"] == "columns"
		recalculateNodePositionsInColumns()
	else
		recalculateNodePositionsInCircle()

recalculateNodePositionsInCircle = () ->
	h = document.body.clientHeight
	w = document.body.clientWidth
	size = Math.min(h, w)
	r = size / 2 - NODE_SIZE - PADDING
	for node, i in NODES
		theta = 2 * Math.PI / NODES.length * i
		node.x = r * Math.cos(theta) + w/2
		node.y = r * Math.sin(theta) + h/2
		node.hue = 360 / NODES.length * i

_groupByRegex = (nodes) ->
	regexs = {}
	for key, value of getQueryParams()
		if m = key.match(/^group(\d+)$/)
			bucket_index = parseInt(m[1], 10)
			regexs[value] = bucket_index

	buckets = []
	for node in NODES
		bucket = 0
		for regex, bucket_index of regexs
			if node.name.match(regex)
				bucket = bucket_index
				break
		buckets[bucket] ?= []
		buckets[bucket].push node
	
	return buckets

recalculateNodePositionsInRows = () ->
	height = document.body.clientHeight
	width = document.body.clientWidth
	
	rows = _groupByRegex(NODES)
	vertical_bucket_size = height / rows.length
	for nodes, row_index in rows
		nodes ?= []
		horizontal_bucket_size = width / nodes.length
		for node, node_index in nodes
			node.x = horizontal_bucket_size * (node_index + 0.5)
			node.y = vertical_bucket_size * (row_index + 0.5)

recalculateNodePositionsInColumns = () ->
	height = document.body.clientHeight
	width = document.body.clientWidth
	
	columns = _groupByRegex(NODES)
	horizontal_bucket_size = width / columns.length
	for nodes, column_index in columns
		nodes ?= []
		vertical_bucket_size = height / nodes.length
		for node, node_index in nodes
			node.x = horizontal_bucket_size * (column_index + 0.5)
			node.y = vertical_bucket_size * (node_index + 0.5)
	

drawNode = (node) ->
	if node.hue?
		color = "hsl(#{node.hue}, 50%, 50%)"
		text_color = "hsl(#{node.hue}, 50%, 80%)"
	else
		color = "#ccc"
		text_color = "#eee"

	container.append("circle")
		.attr("cx", node.x)
		.attr("cy", node.y)
		.attr("r", NODE_SIZE)
		.attr("fill-opacity", "0")
		.attr("stroke-width", "2px")
		.attr("stroke", color)
	
	container.append("text")
		.attr("x", node.x)
		.attr("y", node.y + 5)
		.attr("fill", text_color)
		.attr("text-anchor", "middle")
		.text(node.name)

redrawNodes = () ->
	container.selectAll("*").remove()
	recalculateNodePositions()
	for node in NODES
		drawNode(node)

socket = io.connect()
socket.on "packet", (packet) ->
	to_node = null
	from_node = null
	for node in NODES
		if packet.to == node.name
			to_node = node
		if packet.from == node.name
			from_node = node
	if !to_node?
		console.warn "Creating node #{packet.to}"
		to_node = addNode(packet.to, NODE_SIZE)
	if !from_node?
		console.warn "Creating node #{packet.from}"
		from_node = addNode(packet.from, NODE_SIZE)

	drawPacket(packet.size, packet.duration, packet.hue, from_node, to_node)

