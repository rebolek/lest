REBOL[
	Title: "Redis plugin for LEST"
	Type: 'lest-plugin
	Name: 'redis
	Todo: []
]

startup: [
	; TODO: needs some settings probably
	run redis-path
]

main: [
	'redis [
		open-conn
	|	use-conn
	|	send-command
	]
]

redis-conn: none

open-conn: [
	; open new connection
	'open eval set server url!
	(redis-conn: open server)
]

use-conn: [
	; use existing connection
	'use eval set server word!
	(
		redis-conn: get server
	)
]

send-command: [
	(quiet?: false)
	opt ['quiet (quiet?: true)]
	pos: set cmd block!
	(
;		print mold user-words
		pos/1: send-redis redis-conn bind cmd user-words
		if quiet? [pos/1: ""]
	)
	:pos
]