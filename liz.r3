REBOL [
	Title: "LIZ - receiver for PLESK"
	Date: 19-11-2013
	Notes: [
		#1 http://stackoverflow.com/questions/14123618/how-to-write-a-hello-world-cgi-with-rebol-3
	]
]

read-string: func [
	"Return file content as string! or return empty string! when file not found"
	filename
][
	either exists? filename [
		to string! read file
	][
		copy ""
	]
]


handle-post: funct [] [
	data: none
	data: to string! read system/ports/input
	if data [ data: parse data "&=" ]
	data
]



solve-recaptcha: func [
	recaptcha [object!]
	/local reply
][
	reply: to string! write http://www.google.com/recaptcha/api/verify to-www-form recaptcha
	reply: parse reply "^/"
	either equal? "true" reply/1 [
		true
	][
		; should return as error?
		reply/2
	]
]

make-password: funct [
	{Make random password. Unless WITH is specified, MAKE-PASSWORD uses ^/
	all charsets, but doesn't check if they're present in generated password.}
	length		"Password length in characters"
	/with 		"Required charsets: uppercase, lowercase, numbers, symbols, all"
		required 	[word! block!]
	; TODO: exclude similar chars (i, I, 1, l, o, O, 0, etc.)
][
	uppercase:			"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	lowercase:			"abcdefghijklmnopqrstuvwxyz"
	numbers:			"0123456789"
	symbols:			"!@#$%^^&*()+-=-/|\()[]{}'§"

	; normalize REQUIRED block!
	unless block? required [ required: append copy [] required ]	
	if any [
		not with
		find required 'all
	][
		required: [ uppercase lowercase numbers symbols ]
	]

	; check for errors
	unless parse required [ 
		some [ 'uppercase | 'lowercase | 'numbers | 'symbols ] 
	][
		return make error! "Invalid charset in WITH block. Allowed charsets are: uppercase, lowercase, numbers, symbols, all."
	]
	if all [ 
		with 
		length < length? required
	][ 
		return make error! rejoin [ "Password is too short, at least " length? required " characters are expected." ]
	]

	; set some variables
	out:	make string! length
	chars:	make string! 100
	used:	array/initial length? required false

	; this does what it says
	this:	func [what][get bind what 'out]

	; create pool of chars to choose from 
	foreach set required [
		append chars this set
	]

	; get some entropy
	random/seed now/time/precise

	; create password and check if all required chars were used
	loop length [ 
		char: random/secure/only chars
		append out char
		repeat i length? required [
			if find this required/:i char [
				used/:i: true
			]
		]
	]

	; if something's missing, create new password
	if all [
		with 
		not all used
	][
		out: make-password/with length required
	]

	; return result
	out
]

make-salt: func [
	"Return unique string (date, time and random value)"
][
	rejoin [ now/date ", " now/time/precise ", " random/secure 4294967296 ]
]

make-salted-hash: func [
	"Salt data and return SHA1 hash"
	data
	salt
][
	data: checksum/method join salt data 'sha1
]

comment {
	Storing password:
	* make salt
	* cloak salt with salt masterkey
	* store cloaked salt in user/<username>/salt
	* get checksum of plain salt + plain password
	* store checksum in user/<username>/pass

	Checking password:
	* get cloaked salt from user/<username>/salt
	* decloak salt with master massword
	* get checksum of plain salt + plain password
	* compare checksum with user/<username>/pass

}


; -------- DB


make-key: func [
	data
][
	make path! reduce data
]


; TODO NOTE: add to redis = send-redis port data : [ parse-reply write port data ]

store-password: funct [
	port 		"Redis database"
	username 			
	password
][
	salt: make-salt
	cloaked-salt: encloak salt salt-key
	id: parse-reply write port [ GET ( make-key [ 'user username 'id ] ) ]
	write port [ SET ( make-key [ 'user id 'salt ] cloaked-salt ) ]
	hash: checksum/method join salt password 'mda1
	write port [ SET ( make-key [ 'user id 'password ] hash ) ]

]

check-password: funct [
	port
	username
	password
][
	id: parse-reply write port [ GET ( make-key [ 'user username 'id ] ) ]
	salt: parse-reply write port [ GET ( make-key [ 'user id 'salt ] ) ]
	stored-hash: parse-reply write port [ GET ( make-key [ 'user id 'password ] ) ]
	salt: decloak salt salt-key
	hash: checksum/method join salt password 'mda1
	equal? hash stored-hash
]

store-new-user: func [
	port 
	username
	password
][
	id: parse-reply write port [ GET last-userid ]

comment {
	USER uses following values

	user/<username>/id
	user/<userid>/username
	user/<userid>/password
	user/<userid>/salt

}

	write port [ SET ( make-key [ 'user username 'id ] ) id ]
	write port [ SET ( make-key [ 'user id 'username ] ) username ]
	write port [ SET ( make-key [ 'user id 'salt ] ) username ]

	write port [ INCR last-userid ]
]

store-salt: func [
	"Store encloaked salt"
	user
	salt
	password
][

]