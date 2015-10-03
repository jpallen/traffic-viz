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

drawPacket = (size, duration, from_node, to_node) ->
	from = randomPointInCircle(from_node.x, from_node.y, from_node.size - size)
	to = randomPointInCircle(to_node.x, to_node.y, to_node.size - size)
	hue = Math.floor(Math.random() * 360)
	packet = container.append("circle")
		.attr("cx", from.x)
		.attr("cy", from.y)
		.attr("r", size)
		.attr("fill", "hsl(#{hue}, 50%, 70%)")
		.transition()
		.ease("linear")
		.duration(duration)
		.attr("cx", to.x)
		.attr("cy", to.y)
		.remove()

NODE_SIZE = 30
PADDING = 20
BACKEND_NODES = []
for backend in ["web", "web-api", "docstore", "filestore", "clsi"]
	for server in ["web-1", "web-2", "web-3", "web-4", "web-5", "web-6"]
		BACKEND_NODES.push { name: "#{backend}/#{server}", size: NODE_SIZE }

FRONTEND_NODE = {
	name: "lb-0"
	x: document.body.clientWidth / 2
	y: document.body.clientHeight / 2
	size: NODE_SIZE
}

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
	el = container.append("circle")
		.attr("cx", node.x)
		.attr("cy", node.y)
		.attr("r", NODE_SIZE)
	
	el.attr("fill-opacity", "0")
	el.attr("stroke-width", "5px")
	if node.hue?
		el.attr("stroke", "hsl(#{node.hue}, 90%, 50%)")
	else
		el.attr("stroke", "#eeeeee")

recalculateBackendNodePositions()
drawNode(FRONTEND_NODE)
for node in BACKEND_NODES
	drawNode(node)

for i in [0..10000]
	setTimeout () ->
		to_node = BACKEND_NODES[Math.floor(Math.random()*BACKEND_NODES.length)]
		drawPacket(Math.random() * 10 + 3, Math.random() * 1000 + 500, FRONTEND_NODE, to_node)
	, Math.floor(Math.random() * 100000)