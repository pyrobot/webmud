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