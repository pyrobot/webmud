mt = require 'microtime'
startUpTime = mt.now()
lastTick = 0
console.log "Timer process started"

setInterval ->
	elapsedTime = mt.now() - startUpTime
	elapsedSeconds = elapsedTime * 0.000001
	gameTicks = Math.floor elapsedSeconds
	if gameTicks > lastTick
		lastTick = gameTicks
		process.send lastTick
, 0

process.on 'error', (err) ->
	switch err.message
		when 'channel closed' then console.log "Timer process cannot communicate with main thread, shutting down."
		else console.log "ERROR with timer process \"#{err.message}\", shutting down."
	process.exit(1)

# signals the main thread that process has started up and everything is ok
process.send 0