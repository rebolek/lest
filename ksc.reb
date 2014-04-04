REBOL[
	File: 		%ksc.reb
	Title: 		"KSČ - CSSR preprocessor"
	Author: 	"Boleslav Březovský"
	Version:	0.0.1
	Date: 		31-3-2014
	Created: 	31-3-2014
	Email: 		rebolek@gmail.com
	Purpose:	"CSSR preprocessor. Use variables, block replacements, functions... in CSS. See LESS or SASS."
	To-do:		[
		#5 	"color arithmetics: LESS [@light-blue: @nice-blue + #111;]"
		#7	"fadein, fadeout, fade - operations on opacity"
	]
	Done:		[
		#0	"Basic passing of arguments"
		#1 	"Assignment - my-color: 10.20.30 ; usable everywhere, where color is accepted"
		#2 	"Assignment - bw: [black white] <b> bw == b black white"
		#3 	"Hash colors - #000000 - 0.0.0"
		#4	"Functions - for example: saturate color 50%"
		#6	"HSL - is in %colorspaces.reb"
	]
]

do %colorspaces.reb

; ---

load-color: func [
	"Convert hex RGB issue! value to tuple!"
	color 	[issue!] ; add string also? is it needed?
	/local pos
] [
	to tuple! debase/base next form color 16
]

rule: func [
	"Make PARSE rule with local variables"
	local 	[word! block!]  "Local variable(s)"
	rule 	[block!]		"PARSE rule"
] [
	use local reduce [rule]
]

recat: func [
	"Something like COMBINE but with much cooler name, just to piss off @HostileFork."
	block	[block!]
	/with			"Add delimiter between values"
		delimiter
	/trim			"Remove NONE values"
	/only "Do not reduce, but that makes no sense"
] [
	block: either only [block] [reduce block]
    if empty? block [return block]
	if trim [block: lib/trim block]
	if with [
		with: make block! 2 * length? block
		foreach value block [repend with [value delimiter]]
		block: head remove back tail with
	]
    append either string? first block [
    	make string! length? block
    ] [
        make block! length? block
    ] block	
]

; ---

buffer: make string! 0
emit: func [data] [
	switch type?/word data [
		issue!	[data: load-color data]
	]
	append buffer data
]

; ---

color-funcs: [
	darken 		[100% - amount * color]
	lighten 	[white - color * amount + color]
	saturate 	[
		color: rgb-hsv color 
		color/2: min 1.0 max 0.0 color/2 + amount
		hsv-rgb color
	]
	desaturate 	[
		color: rgb-hsv color 
		color/2: min 1.0 max 0.0 color/2 - amount
		hsv-rgb color
	]
	spin		[
		color: rgb-hsv color 
		color/1: color/1 + amount
		hsv-rgb color	
	]
]

get-color: func [color] [
	case/all [
		word? color 	[color: user-ctx/:color]
		issue? color 	[color: load-color color]
		true			[color]
	]
]

user-ctx: object []
ruleset: object [
	user: [fail]
	assign: rule [name value] [
		set name set-word!
		opt functions
		set value any-type! (
			repend user-ctx [name value]
			append user compose [ 
				| 
				pos: (to lit-word! name) 
				(
					to paren! compose [
						change/part pos (to path! reduce ['user-ctx to word! name]) 1
					]
				) 
				:pos some rules
			]

		)
	]
	functions: rule [f f-stack color amount pos] [
		(f-stack: [])
		set f ['darken | 'lighten | 'saturate | 'desaturate | 'hue]
		(append f-stack f)
		opt functions
		set color match-color
		pos:
		set amount number! (
			f: take/last f-stack
			case/all [
				word? color  [color: user-ctx/:color]
				issue? color [color: load-color color]
				tuple? color [color: set-color new-color color 'rgb]
				true         [color: apply-color color f amount]
			]
			change pos color/rgb
		)
		:pos
	]
	em: rule [value] [
		; used to override <em> from following rule (this one needs number)
		'em set value number!
		(emit compose [em (value)])
	]
	canvas: rule [value] [
		'canvas
		set value match-color
		(emit compose [canvas (get-color value)])
	]
	tags: use [data tag-list tag] [
		data: load %tags
		tag-list: make block! 2 * length? data
		foreach value data [repend tag-list [to lit-word! to string! value '|]]
		take/last tag-list
		[
			set tag tag-list 
			(emit to tag! tag)
		]
	]
	google-fonts: rule [value values] [
		; we need to pass this issue! types, so they're not converted to color
		'google 'fonts
		(values: make block! 10)
		some [
			set value [string! | issue!]
			(append values value)
		]
		(emit compose [google fonts (values)])
	]
	pass: rule [value] [
		set value skip
		(emit value)
	]
; Following rule will never be matched, so they can be used like support rules	
	match-color: rule [user-words] [
		(
			user-words: make block! 2 * length? user-ctx
			foreach word words-of user-ctx [
				repend user-words [to lit-word! word '|]
			]
			take/last user-words
		)
		[issue! | tuple! | user-words]
	]
]

rules: none

init: does [
	buffer: make block! 1000
	append clear ruleset/user 'fail
	rules: recat/with words-of ruleset '|
]

ksč: func [
	data
] [
	init
	parse data [some rules]
	buffer
]

ksc: :ksč