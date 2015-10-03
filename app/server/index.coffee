express = require "express"
socketio = require "socket.io"
carrier = require "carrier"
http = require "http"

BUFFER_DELAY = 5000
if process.env["BUFFER_DELAY"]
	BUFFER_DELAY = parseInt(BUFFER_DELAY, 10)

startTime = null
bufferPacket = (packet) ->
	# TODO: Check packet is correct format
	if !startTime?
		startTime = packet.ts
	delta = packet.ts - startTime + BUFFER_DELAY
	if delta < 0
		delta = 0
	setTimeout () ->
		console.log "emitting packet", delta, packet
		io.sockets.emit("packet", packet)
	, delta

packet_lines = carrier.carry(process.stdin)
packet_lines.on "line", (line) ->
	try
		packet = JSON.parse(line)
	catch error
		console.warn "[WARN] Could not parse packet line", error
		return
	bufferPacket packet

app = express()
server = http.createServer(app)
io = socketio(server)

app.use(express.static('public'))

process.env["PORT"] ?= 8000
server.listen process.env["PORT"], () ->
	console.log "Listening on port #{process.env["PORT"]}"