REBOL[
	Title: "Redis plugin for LEST"
	Type: 'lest-plugin
	Name: 'redis
	Todo: []
]

startup: [
	; TODO: needs some settigns probably
	run %../prot-redis/prot-redis.reb
]

rule: [
	'redis [
		open-conn
	|	send-command
	]
]

redis-conn: none

open-conn: [
	'open set server url!
	(redis-conn: open server)
]

send-command: [
	pos: set cmd block!
	(
;		print mold user-words
		pos/1: send-redis redis-conn bind cmd user-words
	)
	:pos
]