REBOL[
	Title: "Redis plugin for LEST"
	Type: 'lest-plugin
	Name: 'redis
	Todo: []
]

startup: [
;	lets expect (for now) that prot-redis is already loaded
; 	proper startup will be added later
	stylesheet css-path/bootstrap.min.css 
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
	(pos/1: send-redis redis-conn cmd)
	:pos
]