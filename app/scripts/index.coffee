container = d3
	.select("body")
	.append("svg")
	.attr("height", "100%")
	.attr("width", "100%")

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

NODE_SIZE = 30
PADDING = 20
BACKEND_NODES = []

FRONTEND_NODE = {
	name: "lb-0"
	x: document.body.clientWidth / 2
	y: document.body.clientHeight / 2
	size: NODE_SIZE
}

addNode = (name, size) ->
	node = {name, size}
	BACKEND_NODES.push node
	BACKEND_NODES.sort (a,b) ->
		if a.name > b.name
			return 1
		else if a.name < b.name
			return -1
		else
			return 0
	redrawNodes()
	return node

recalculateBackendNodePositions = () ->
	h = document.body.clientHeight
	w = document.body.clientWidth
	size = Math.min(h, w)
	r = size / 2 - NODE_SIZE - PADDING
	for node, i in BACKEND_NODES
		theta = 2 * Math.PI / BACKEND_NODES.length * i
		node.x = r * Math.cos(theta) + w/2
		node.y = r * Math.sin(theta) + h/2
		node.hue = 360 / BACKEND_NODES.length * i

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
		.attr("stroke-width", "5px")
		.attr("stroke", color)
	
	container.append("text")
		.attr("x", node.x)
		.attr("y", node.y + 5)
		.attr("fill", text_color)
		.attr("text-anchor", "middle")
		.text(node.name)

redrawNodes = () ->
	container.selectAll("*").remove()
	recalculateBackendNodePositions()
	drawNode(FRONTEND_NODE)
	for node in BACKEND_NODES
		drawNode(node)

socket = io.connect()
socket.on "packet", (packet) ->
	from_node = FRONTEND_NODE
	to_node = null
	for node in BACKEND_NODES
		if packet.name == node.name
			to_node = node
			break
	if !to_node?
		console.warn "Creating node #{packet.name}"
		to_node = addNode(packet.name, NODE_SIZE)

	drawPacket(packet.size, packet.duration, packet.hue, from_node, to_node)

