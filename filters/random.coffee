if process.env["EVENTS_PER_SECOND"]?
	EVENTS_PER_SECOND = parseInt(process.env["EVENTS_PER_SECOND"], 10)
else
	EVENTS_PER_SECOND = 10

if process.env["MIN_SIZE"]?
	MIN_SIZE = parseInt(process.env["MIN_SIZE"], 10)
else
	MIN_SIZE = 4

if process.env["MAX_SIZE"]?
	MAX_SIZE = parseInt(process.env["MAX_SIZE"], 10)
else
	MAX_SIZE = 15

if process.env["MAX_DURATION"]?
	MAX_DURATION = parseInt(process.env["MAX_DURATION"], 10)
else
	MAX_DURATION = 2000

if process.env["MIN_DURATION"]?
	MIN_DURATION = parseInt(process.env["MIN_DURATION"], 10)
else
	MIN_DURATION = 500

if process.env["NODE_COUNT"]?
	NODE_COUNT = parseInt(process.env["NODE_COUNT"], 10)
else
	NODE_COUNT = 6

setInterval generateEvents = () ->
	for i in [1..EVENTS_PER_SECOND]
		setTimeout () ->
			console.log JSON.stringify {
				ts: Date.now()
				from: "src-#{Math.floor(Math.random() * NODE_COUNT)}"
				to: "dest-#{Math.floor(Math.random() * NODE_COUNT)}"
				size: MIN_SIZE + Math.floor(Math.random() * (MAX_SIZE - MIN_SIZE))
				duration: MIN_DURATION + Math.floor(Math.random() * (MAX_DURATION - MIN_DURATION))
			}
		, Math.floor(Math.random() * 1000)
, 1000

generateEvents()