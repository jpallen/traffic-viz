carrier = require "carrier"

haproxy_stream = carrier.carry(process.stdin)
haproxy_stream.on "line", (line) ->
	data = parseLogEntry(line)
	duration = parseInt(data.timings[4], 10)
	if duration < 800
		duration = 800
	hue = null
	if m = data.url.match(/[0-9a-f]{24}/)
		oid = m[0]
		hue = parseInt(oid.slice(20), 16) & 360
	console.log JSON.stringify {
		name: data.name
		duration: duration
		size: Math.log(data.size)
		ts: data.date
		hue: hue
	}
	
parseLogEntry = (line) ->
	parts = line.split(" ")
	date = new Date(parts[2].replace(/[\[\]]/g, "").replace(/:/, " ")).getTime()
	name = parts[4]
	timings = parts[5].split('/')
	size = parseInt(parts[7], 10)
	url = parts.slice(14).join(" ").replace(/^"/, "").replace(/"$/, "")
	return {name, timings, size, date, url}