REBOL[
	Title:		"LEST - Low Entropy System for Templating"
	Author:		"Boleslav Brezovsky"
	Name: 		'lest	
	Version:	0.0.5
	Date:		19-9-2014
	Created:	7-12-2013
;	Type: 		'module
;	Exports: 	[lest]
	Needs: 		[prestyle md]
;	Options: 	[isolate]
	Notes: [
		9-1-15 "BB" {LEST sets 'lest-styles word that holds list of all used CSS styles.
This will be later changed to object! that will hold more informations
about the parsed Lest source.
This block can be used with (patched) StyleTalk to check if all styles defined
in StyleTalk file are used by Lest source.
}
		13-1-15 "BB" {LEST now adds ID to radio, when no ID is present. 
ID is in the form: radio_<radio-name>_<radio-value>
Check if not problematic.
}
	]
	To-do: 		[
		"AS and JOIN AS should use same implementation"
		"HTML entities"
		"Cleanup variables in lest"
		"Change header rules to emit to main data"
		{
get rid of lest in rules

currently used in:
	CAROUSEL, CAROUSEL-ITEM
	ENABLE: BOOTSTRAP, SMOOTH-SCROLLING, PRETTY-PHOTO, PASSWORD-STRENGTH

		}
		"support char! as basic input (beside string!)"
		"add anything! type for user rules that will parse anything parsable in bootrapy"
		"Bootstrap BOX component"
		{
Add webserver that can serve pages directly:
	when run with argument (serve index.page) it will open browser and show page
	when run without argument, it will open in current directory with list of files and some help
	... other ideas
		}
		"plugin design: instead of startup just list required css and js files"
		"FORM is Bootstrap optimized, divide"
		"FIX: form leaks default, value, name"
		"FIX: main-rule and match-content mišmaš: one rule with all rules and one rule to match that rule, block, commands and string (not in that order)"

		{
			GET-USER-VALUE: (MATCH-VALUE)

			Rule will check for user content (using get-word! or word!),
			replace it and continue parsing:

			GET-USER-VALUE SET value string!

			so data like: [TAG :USER-VAL] are changed to [TAG "user-val"]
		} 
		{
			REPEAT: remove replace
			instead of: REPEAT [a :link] REPLACE :link WITH [...]
			it will be: REPEAT [a (...)]
		}
	]
]

css-path: %css/
js-path: %js/

; fuck off current module system

do %compile-rules.reb

; /fuck off


;debug-print: none
; :print
;none

; SETTINGS

; TODO: move settings to .PAGE files

plugin-path: %plugins/

text-style: 'html

dot: #"."

;
;   _____   _    _   _____    _____     ____    _____    _______     ______   _    _   _   _    _____    _____
;  / ____| | |  | | |  __ \  |  __ \   / __ \  |  __ \  |__   __|   |  ____| | |  | | | \ | |  / ____|  / ____|
; | (___   | |  | | | |__) | | |__) | | |  | | | |__) |    | |      | |__    | |  | | |  \| | | |      | (___
;  \___ \  | |  | | |  ___/  |  ___/  | |  | | |  _  /     | |      |  __|   | |  | | | . ` | | |       \___ \
;  ____) | | |__| | | |      | |      | |__| | | | \ \     | |      | |      | |__| | | |\  | | |____   ____) |
; |_____/   \____/  |_|      |_|       \____/  |_|  \_\    |_|      |_|       \____/  |_| \_|  \_____| |_____/
;

attach: function [
	"Append value to block only when not present. Return FALSE when value is present."
	block
	value
] [
	either found: find block value [
		found
	] [
		append block value
		true
	]
]

escape-entities: funct [
	"Escape HTML entities. Only partial support now."
	data
] [
	output: make string! 1.1 * length? data
	; simple map that is modified to parse rule
	entities: [
		#"<" "lt"
		#">" "gt"
		#"&" "amp"
	]
	rule: make block! length? entities
	forskip entities 2 [
		repend rule [
			entities/1
			to paren! reduce ['append 'output rejoin [#"&" entities/2 #";"] ] 
			'| 
		]
	]
	append rule [set value skip (append output value)]
;	debug-print ["parse escape entities"]
	parse data [some rule]
	output
]

catenate: funct [
	"Joins values with delimiter."
    src [ block! ]
    delimiter [ char! string! ]
    /as-is "Mold values"
] [
    out: make string! 200
    forall src [ repend out [ either as-is [mold src/1] [src/1] delimiter ] ]
    len: either char? delimiter [ 1 ][ length? delimiter ]
    head remove/part skip tail out negate len len
]

replace-deep: funct [
	target
	'search
	'replace
] [
	rule: compose [
		change (:search) (:replace)
	|	any-string!
	|	into [some rule]
	|	skip
	]
	parse target [some rule]
	target
]

change-code: func [
	"Replace code at cuurent position (to have unified function for better testing and debugging)"
	pos
	data
	/only 	" Only change a block as a single value (not the contents of the block)"
] [
	pos/1: data
]

rule: func [
	"Make PARSE rule with local variables"
	local 	[word! block!]  "Local variable(s)"
	rule 	[block!]		"PARSE rule"
] [
	if word? local [local: reduce [local]]
	compile-rules use local reduce [rule]
]

add-rule: func [
	"Add new rule to PARSE rules block!"
	rules 	[block!]
	rule 	[block!]
] [
	unless empty? rules [
		append rules '|
	]
	append/only rules rule
]

to-www-form: func [
	"Convert object body (block!) to application/x-www-form-urlencoded"
	data
	/local out
][
	out: copy {}
	foreach [ key value ] data [
		if issue? value [ value: next value ]
		repend out [
			to word! key
			#"="
			value
			#"&"
		]
	]
	head remove back tail out
]

build-tag: funct [
	name 	[ word! ]
	values	[ block! object! map! ]
][
	tag: make string! 256
	repend tag [ #"<" name space ]
	unless block? values [ values: body-of values ]
	foreach [ name value ] values [
		skip?: false
		value: switch/default type?/word value [
			block!	[
				if empty? value [ skip?: true ]
				catenate value #" "
			]
			string!	[ if empty? value [ skip?: true ] value ]
			none!	[ skip?: true ]
		][
			form value
		]
		unless skip? [
			repend tag [ to word! name {="} value {" } ]
		]
	]
;
;	TODO: support attributes without values (version from make-tag)
;
;	unless empty? attributes [
;		append out join #" " form attributes
;	]
;
	head change back tail tag #">"
]

entag: func [
	"Enclose value in tag"
	data
	tag
	/with
		values
] [
	unless with [ values: clear [] ]
	ajoin [
		build-tag tag values
		reduce data
		close-tag tag
	]
]

close-tag: func [
	type
][
	ajoin ["</" type ">"]
]

; TODO: get-integer and lest-integer? should be one function (or get-integer should use lest-integer?)

get-integer: func [
	"Get integer! value from string! or pass integer! (return NONE otherwise)"
	value
	/local number int-rule
] [
	if integer? value [return value]
	unless string? value [return none]
	number: 		charset "0123456789"
;	float-rule: 	[opt #"-" some number [opt #"." some number]]
	int-rule: 		[opt #"-" some number]
	either parse value int-rule [to integer! value] [none]
]

lest-integer?: func [
	value
	/local number int-rule
] [
	number: 		charset "0123456789"
	int-rule: 		[opt #"-" some number]
	any [
		integer? value
		parse value int-rule
	]
]

lest: use [
	debug-print
	buffer
	page
	tag
	tag-name
	tag-stack
	includes	
	rules
	header?
	safe?
	pos
	locals
	local

	current-text-style
	used-styles
	last-id

	name
	value

	emit
	emit-label
	emit-stylesheet

	add-js

	user-rules
	user-words
	user-words-meta
	user-values

	plugins
	load-plugin

] [

add-js: func [
	"Add code do javascript code buffer"
	target
	data
	/only "Do not end command with semicolon"
] [
	head append target rejoin [data either only "" #";"]
]

set-user-word: func [
	name
	value
	/type
		'word-type
	/custom
		custom-data
] [
	name: to lit-word! name
	debug-print ["SET-USER-WORD"]
	debug-print ["uw:" mold user-words]
	debug-print ["SET:" name mold value "(rebol:" type? value ")"]
	debug-print ["word-type" mold word-type get-integer value]
	word-type: case [
		word-type						(to lit-word! word-type)
		get-integer value 				(value: form value 'integer)
		string? value						('string)
		equal? #"." first form value 	('class)		; doesn't check for word! but should be sufficient
		word? value						('word)
		block? value						('block)
		issue? value						('id)
		map? value 						('map)
	]
	debug-print ["SET:" name mold value "(lest:" word-type ")"]
	obj: object reduce/no-set [
		type: quote word-type
;		value: :value
	]
	if custom [append object custom-data]
	append user-words compose/only [
		(to set-word! name) (:value)
	]
	append user-words-meta compose [
		(to set-word! name) (obj)
	]	
]

get-user-word: func [
	'name
] [
	get in user-words name
]

get-user-type: func [
	 name
] [
;	debug-print ["GUT:" mold name "in" mold user-words-meta]
;	debug-print ["GUT:" mold get in user-words-meta :name]
	if name: get in user-words-meta name [
		name/type
	]	
]

; === actions

emit: func [
	data [ string! block! tag! ]
][
	if block? data	[ data: ajoin data ]
	if tag? data	[ data: mold data ]
	append buffer data ;join data newline
]

emit-label: func [
	label
	elem
	/class
	styles
][
	unless empty? label [emit entag/with label 'label reduce/no-set [ for: elem class: styles ]]
]

emit-script: func [
	script
	/insert
	/append
][
	case [
		insert 		[lib/append includes/header script]
		append 	[lib/append includes/body-end script]
		true 		[emit script]
	]
]

emit-stylesheet: func [
	stylesheet
	/local suffix
][
;	if path? stylesheet [ stylesheet: get stylesheet ]
	local: stylesheet
	if all [
		file? stylesheet
		not equal? %.css suffix: suffix? stylesheet
	] [
		write 
			local: replace copy stylesheet suffix %.css 
			prestyle load stylesheet
	]
	unless find includes/stylesheets stylesheet [
		repend includes/stylesheets [{<link href="} local {" rel="stylesheet">} newline ]
	]
]

;  _____    _    _   _        ______    _____
; |  __ \  | |  | | | |      |  ____|  / ____|
; | |__) | | |  | | | |      | |__    | (___
; |  _  /  | |  | | | |      |  __|    \___ \
; | | \ \  | |__| | | |____  | |____   ____) |
; |_|  \_\  \____/  |______| |______| |_____/
;

rules: object [

; -- reference to some words: external plugins are bound to RULES, but cannot see TAG
;		or INCLUDES so we need this references (or multiple binding, which is ugly)

	tag: tag
	tag-name: tag-name

	value-to-emit: none
	emit-value: [
		(emit value-to-emit)
	]


; --- subrules

load-rule: rule [pos value] [
	; LOAD AND RETURN FILE
	'load pos: set value [ file! | url! ]
	(
		debug-print ["##LOAD" value]
		change-code/only pos load value
	)
	:pos
]

import: rule [pos value] [
	; LOAD AND EMIT FILE
	'import pos: set value [ file! | url! ]
	(
		debug-print ["##IMPORT" value]
		change-code/only pos load value
	)
	:pos main-rule
]

text-settings: rule [type] [
	set type ['plain | 'html | 'markdown]
	'text
	(text-style: type)
]

eval: [any [commands | user-values | process-code | plugins |  comparators]]
eval-strict: [any [user-values | process-code | commands ]]		; ignore plugins

process-code: rule [ p value ] [
	; DO PAREN! AND EMIT LAST VALUE
	p: set value paren!
	( 
		p/1: either safe? [
			""
		] [
			do bind to block! value user-words
		] 
	)
	:p
	]

set-at-rule: rule [word index value block] [
	'set
	set word word!
	'at
	eval set index integer!
	eval set value any-type!
	(
		debug-print ["==SET@:" word "@" index "=" value]
		block: get-user-word :word
		block/:index: value
		set-user-word word block
	)
]

set-rule: rule [labels values] [
	[
		'set set labels [word! | block!]
	|	set labels set-word! (labels: to word! labels)
	]
	eval set values any-type!
	(
		unless block? labels [
			labels: reduce [labels]
			values: reduce [values]
		]
		debug-print ["==SET:" length? labels "values"]
		repeat i length? labels [
			label: labels/:i
			value: values/:i
			value: switch/default value [
				; predefined values
				true yes on [lib/true]
				false no off [lib/false]
			][value]
			; add rules, if not exists
			unless in user-words label [
				debug-print ["==SET/create:" label]
				append second user-values compose [ 
					|
						(to lit-word! label) 
						(to paren! compose [change/only pos get-user-word (label)]) 
				]
			]
			; extend user context with new value
			debug-print ["==SET:" label ":" mold value]
			set-user-word label value
		]
	)
]

get-user-value: rule [value] [
	pos:
	set value any-type!
	(
		all [
			word? value 
			in user-words value
;			pos/1: user-words/:value
			change-code/only pos user-words/:value
		]
	)
	:pos
]

new-get-user-value: rule [name] [
	pos:
	set name word!
	(
		change-code/only pos get-user-word name
	)
	:pos
]

user-rule: rule [name label type value urule args pos this-rule] [
	set name set-word!
	(
		args: copy []
		idx: none
		if block? pos: attach user-rule-names name [
			; rule already exists, remove it
			idx: (index? pos) * 2 + 1
		]

		this-rule: reduce [
			to set-word! 'pos
			to lit-word! name
			to paren! compose [debug-print (rejoin ["UU:user-rule: " name " <start> matched."])]
		]
	)
	any [
		set label word!
		set type word!
		(
			add-rule args rule [px] reduce [
				to set-word! 'px to lit-word! label
				to paren! reduce/no-set [ to set-path! 'px/1 label ]
			]

			repend this-rule ['eval to set-word! 'pos 'set label type ]
		)
	]
	set value block!
	(
		append this-rule reduce [
			to paren! compose/only [
				; TODO: move rule outside
				urule: ( compose [
					any-string!
				|	into [ some urule ]
				; FIXME: for rules without args it returns [into [...] | | skip ] so skip cannot be reached
				|	(args)
				|	skip
				] )
				debug-print ["parse in user-rule"]
				parse temp: copy/deep (value) [ some urule ]
;				change/only pos temp
				change-code/only pos temp
			]
			to get-word! 'pos 'into main-rule
		]
		either idx [
			; existing rule, modify
			change/only at user-rules idx this-rule
		] [
			; new rule, add
			add-rule user-rules this-rule
		]
	)
]

template-rule: rule [name label type value urule args pos this-rule] [
	set name set-word!
	'template
	(
		args: copy []
		idx: none
		if block? pos: attach user-rule-names name [
			; rule already exists, remove it
			idx: (index? pos) * 2 + 1
		]

		this-rule: reduce [
			to set-word! 'pos
			to lit-word! name
			to paren! compose [debug-print (rejoin ["UU:user-rule: " name " <start> matched."])]
		]
	)
	opt into [
		set label word!
		(
			add-rule args rule [px] reduce [
				to set-word! 'px to lit-word! label
				to paren! reduce/no-set [ to set-path! 'px/1 label ]
			]
			repend this-rule ['eval to set-word! 'pos 'set label 'any-type! ]
		)
	]
	set value block!
	(
		append this-rule reduce [
			to paren! compose/only [
				; TODO: move rule outside
				urule: ( compose [
					any-string!
				|	into [ some urule ]
				; FIXME: for rules without args it returns [into [...] | | skip ] so skip cannot be reached
				|	(args)
				|	skip
				] )
				debug-print ["parse in user-rule"]
				parse temp: copy/deep (value) [ some urule ]
;				change/only pos temp
				change-code/only pos temp
			]
			to get-word! 'pos 'into main-rule
		]
		set-user-word/type name value template
		either idx [
			; existing rule, modify
			change/only at user-rules idx this-rule
		] [
			; new rule, add
			add-rule user-rules this-rule
		]
	)
]


style-rule: rule [data] [
	'style
	set data [block! | string!]
	(
		either string? data [
			append includes/stylesheet entag data 'style
		] [
			append includes/style data
		]
	)
]

; dynamic actions

; currently defined: 
;
;	SET - SET id data
;		- set content of ID element to DATA 
;		- document.getElementById(id).innerHTML = data;

window-events: [
	'onafterprint | 'onbeforeprint | 'onbeforeunload | 'onerror | 'onhashchange | 'onload | 'onmessage 
	| 'onoffline | 'ononline | 'onpagehide | 'onpageshow | 'onpopstate | 'onresize | 'onstorage | 'onunload
]

form-events: [
	'onblur | 'onchange | 'oncontextmenu | 'onfocus | 'oninput | 'oninvalid | 'onreset | 'onsearch | 'onselect | 'onsubmit
]

keyboard-events: [
	'onkeydown | 'onkeypress 	| 'onkeyup
]

mouse-events: [
	'onclick | 'ondblclick | 'ondrag | 'ondragend | 'ondragenter | 'ondragleave | 'ondragover | 'ondragstart | 'ondrop 
	| 'onmousedown | 'onmousemove | 'onmouseout | 'onmouseover | 'onmouseup | 'onmousewheel | 'onscroll | 'onwheel
]

clipboard-events: [
	'oncopy | 'oncut | 'onpaste
]

media-events: [
	'onabort | 'oncanplay | 'oncanplaythrough | 'oncuechange | 'ondurationchange | 'onemptied | 'onended | 'onerror | 'onloadeddata 
	| 'onloadedmetadata | 'onloadstart | 'onpause | 'onplay | 'onplaying | 'onprogress | 'onratechange | 'onseeked | 'onseeking 
	| 'onstalled | 'onsuspend | 'ontimeupdate | 'onvolumechange | 'onwaiting
]

misc-events: [
	'onerror | 'onshow | 'ontoggle
]

events: [
	window-events | form-events | keyboard-events | mouse-events | clipboard-events | media-events | misc-events
]

; ---------

js-raw: rule [value] [
	set value string!
	(
		debug-print ["!!action fc: RAW"]
		add-js locals/code value
	)	
]

js-debug: rule [value] [
	'debug
	set value any-type!
	(debug-print ["!!action fc: DEBUG"]) 
	(
		unless word? value [value: rejoin [{'} form value {'}]]
		add-js locals/code rejoin ["console.debug(" value ")"]
	)
]

js-assign-value: rule [name] [
	set name set-word!
	(debug-print ["!!action fc: ASSIGN"]) 
	(add-js/only locals/code rejoin ["var " to word! name " = "])
]

js-set: rule [name target data] [
	; name - ID of element, target - field in element (color, innerHTML, etc...), data - new data to set
	'set 
	(debug-print ["!!action fc: SET"]) 
	eval set name issue! eval set target word! eval set data any-string! (
		add-js rejoin [{document.getElementById('} next form name {').} target { = '} data {'}]
	)
]

js-action: rule [name data target] [
	'action
	(data: "")
	(debug-print ["!!action fc: ACTION"]) 
	set name word!
	set data [word! | block! | none!]
	(
		; TODO: process block!
		if any ['none = data] [data: {''}]
		add-js locals/code rejoin [{sendAction('} name {', } data {)}]
	)	
]

js-send: rule [type] [
	(type: 'post)
	'send
	opt set type ['get | 'post]
	set data any-type!
	(
		debug-print ["!!action fc: SEND" type]
	)
]

get-dom: rule [path] [
	set path get-path!
	(
		debug-print ["!!action fc: GET DOM"]
		add-js locals/code rejoin [{getAttr("} path/1 {","} path/2 {")}]
	)
]

set-dom: rule [path value] [
	set path set-path!
	set value any-type!
	(
		debug-print ["!!action fc: SET DOM"]
		unless word? value [value: rejoin [{'} form value {'}]]
		add-js locals/code rejoin [{setAttr('} path/1 {','} path/2 {',} value {)}]
	)
]

call-dom: rule [] [	

]

js-object: rule [key value object] [
	'object
	(object: make string! 200)
	(append object #"{")
	into [
		some [
			set key set-word!
			[
				set value word! 
;			|	set value get-path! ()	
			|	set value any-type! (value: mold value)
			]
			(append object rejoin [#"^"" to word! key {": } value #","])
		]
	]
	(
		change back tail object #"}"
		add-js locals/code object
	)
]

js-code: rule [] [
	(debug-print "^/JS: Match JS code^/---------------")
	some [
		js-raw
	|	js-debug
	|	js-set
	|	js-action
	|	js-assign-value
	|	js-object
	|	get-dom
	|	set-dom
	]
	(debug-print "^/JS: End JS code^/---------------")
	(replace/all locals/code #"^"" #"'") ; change all quotation marks to apostrohes 
	(debug-print mold locals/code)
]

actions: rule [action data] [
	set action events
	(
		local code make string! 1000
		local action action ; replace/all to string! action #"-" ""
		debug-print ["!!action:" action]
	)
	[
		set data string!
		(append tag reduce [to set-word! locals/action data])
	|	into js-code
		(append tag reduce [to set-word! locals/action locals/code])
	]
]

; ----

init-tag: [
	(
		insert tag-stack reduce [ tag-name tag: context [ id: none class: copy [] ] ]
		debug-print ["INIT TAG:" tag-name]
		debug-stack tag-stack
	)
]

take-tag: [(set [tag-name tag] take/part tag-stack 2)]

emit-tag: [ ( 
	emit build-tag tag-name tag 
	debug-print ["EMIT TAG:" tag-name ", stack: " length? tag-stack]
) ]

end-tag: [
	take-tag
	( 
		emit close-tag tag-name 
		debug-print ["END TAG:" tag-name ", stack: " length? tag-stack]
	)
]

init-div: [
	( tag-name: 'div )
	init-tag
]

close-div: [
	(
		tag: take/part tag-stack 2
		emit </div>
	)
]

comparators: [
	comparison-rule
]

comparison-rule: rule [val1 val2 comparator pos res] [
	; NOTE: all values are formed before comparison
	;			this leads to double conversion if numbers ( 3 -> "3" -> 3 )
	;			and needs to be optimalized
	set val1 any-type!
	set comparator ['= | '> | '< | '>= | '<= | '<>]
	set val2 any-type!
	pos:
	(
		debug-print ["<>COMPARE:" mold val1 type? val1 comparator mold val2 type? val2]
		; TODO: simplify this american engineering
		if word? val1 [
			type: get-user-type val1
			val1: get-user-word :val1
			debug-print ["GOT" mold val1]
		;	if type = 'integer [val1: get-integer val1]
		]
		if lest-integer? val1 [val1: get-integer val1]
		if word? val2 [
			type: get-user-type val2
			val2: get-user-word :val2
			debug-print ["GOT" mold val2]
		;	if type = 'integer [val2: get-integer val2]
		]
		if lest-integer? val2 [val2: get-integer val2]
		debug-print ["<>COMPARE:" mold val1 comparator mold val2]
		res: do reduce [val1 comparator val2]
		debug-print ["<>COMPARE:" mold res]
		change-code/only pos: back pos res
	)
	:pos
]

math-commands: [
	incr-rule
|	math-rule	
]

incr-rule: rule [action word value] [
	set action ['++ | '--]
	set word word!
	(
		debug-print ["++MATH  incr:" word action]		
		; TODO: should return error on non-integer values or silently ignore?
		action: select [++ + -- -] action
		all [
			value: get-user-word :word
			value: get-integer value
			integer? value
			value: do reduce ['value action 1]
			set-user-word word form value
		]
	)
]

math-rule: rule [pos action val1 val2] [
	set val1 [string! | integer! | word!]
	set action ['+ | '- | '*]
	pos: set val2 [string! | integer! | word!]
	(
		debug-print ["++MATH  input:" val1 action val2]
		if word? val1 [val1: get-user-word :val1]
		if word? val2 [val2: get-user-word :val2]
		val1: get-integer val1
		val2: get-integer val2
		debug-print ["++MATH output:" val1 action val2]
;		pos/1: form do reduce ['val1 action 'val2]
		change-code pos form do reduce ['val1 action 'val2]
	)
	:pos
]

commands: [
	pos: (debug-print ["match commands@" pos/1])
	[
		if-rule
	|	either-rule
	|	switch-rule
	|	for-rule
	|	repeat-rule
	|	pipe-loop-rule
	|	as-map-rule
	|	as-rule
	|	join-rule
	|	default-rule
	|	length-rule
	|	insert-append-rule
	|	math-commands
	|	load-rule
	|	enable-plugin
	]
]

if-rule: rule [cond true-val pos res] [
	'if
	opt comparators
	set cond [logic! | word! | paren!]
	pos:
	set true-val any-type! 
	(
		if all [safe? paren? cond] [cond: false]
		debug-print ["??COMPARE/if: " cond " +" mold true-val]
		res: if/only do bind to block! cond user-words true-val
		debug-print ["??COMPARE/if: " res]
		either res [
			change/part pos res 1
;			change-code/only pos res
		] [
			pos: next pos
		]
	)
	:pos
]

either-rule: rule [cond true-val false-val pos ret] [
	'either
	opt comparators
	set cond [logic! | word! | paren!]
	set true-val any-type! 
	pos:
	set false-val any-type! 
	(
		if all [safe? paren? cond] [cond: false]
		debug-print ["??COMPARE/either: " cond " +" mold true-val " -" mold false-val]
;		change/part 
;			pos 
;			either/only do bind to block! cond user-words true-val false-val 
;			1
		change-code/only pos either/only do bind to block! cond user-words true-val false-val 
		debug-print ["??COMPARE/either[out]: " pos/1]
	)
	:pos
]

switch-rule: rule [value cases defval pos] [
	'switch
	(defval: none)
	set value word!
	set cases block!
	opt [
		'default
		set defval any-type!
	]
	pos:
	(
		pos: back pos
		forskip cases 2 [
			if integer? cases/1 [cases/1: form cases/1]
			cases/2: append/only copy/deep [] cases/2
		]
		value: get bind value user-words
		defval: append/only copy [] defval
		debug-print ["??COMPARE/switch: " mold value " ?" mold cases "-" mold defval]
		change-code/only pos switch/default value cases defval
	)
	:pos
]

; FIXME: FOR set variable with user name in user-words
; 			it doesn't clean it and can rewrite user's variable

for-rule: rule [pos out var src content] [
	'for
	(debug-print "FOR command")
	set var [word! | block!]
	[
			'in eval set src [word! | block! | file! | url!]
		|	set src integer! 'times
	]
	pos: set content block! (
		debug-print "FOR matched"
		src: case [
			any [url? src file? src] [load src]
			word? src [get-user-word :src]
			integer? src [use 'i [reverse array/initial i: src func [][-- i]]]
			true [src]
		]
		out: make block! length? src
		forall src [
			append out compose [set index (index? src)]
			either block? var [
				repeat i length? var [
					append out compose/only copy/deep [set (var/:i) (src/:i)]
				]
				src: skip src -1 + length? var
				append/only out copy/deep content
			] [
				append out compose/only copy/deep [set (var) (src/1) (copy/deep content)]
			]
		]
		change-code/only pos out
	)
	:pos
	if (not locals/lazy?)
	main-rule
	(local lazy? true)
]

repeat-rule: rule [offset element count value values data pos current out] [
	'repeat
	( 
		offset: none 
		values: make block! 4
	)
	get-user-value
	set element block!
	'replace
	some [set value get-word! (append values value)]
	opt [
		set count [integer! | if (not safe?) paren!]
		'times
	]
	opt [
		'offset
		set offset integer!
	]
	[
		[
			'from
			pos: set data [ block! | word! ]
			(
				if word? data [ data: get data ]
				out: make block! length? data
				foreach item data [
					current: copy/deep element
					foreach value values [
						replace-deep current value item
						; FIXME: won't work for multiple values
					]
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				]
;				change/part pos out 1
				change-code pos out
			)
			:pos
		]
	|	[
			'with
			if (not safe?)
			pos: set data paren!
			(
				if paren? count [count: do bind to block! count user-words]
				data: to block! data
				out: make block! length? data
				repeat index count [
					current: copy/deep element
					result: do bind bind data 'index user-words
					either 1 = length? values [
						replace-deep current values/1 result
					] [
						foreach value values [
							replace-deep current value (take result)
						]
					]
					append out current
				]
;				change/part pos out 1
				change-code pos out
			)
			:pos
		]
	]
]

pipe-loop-rule: rule [pos content data out] [
	set data [word! | block!]
	'<<
	(content: append copy [] data)
	(debug-print ["pipe-loop-rule matched:" mold content])
	eval
	pos:
	set data block!
	(
		debug-print ["pipe-loop-rule data:" mold data]
		out: make block! 100
		foreach value data [
			append out append copy content value
		]
		debug-print ["pipe-loop-rule out:" mold out]
		change-code pos out
	)
	:pos
]

default-rule: rule [value word default] [
	'default
	set word word!
	set default any-type!
	(
		value: get-user-word :word
		unless value [set-user-word :word default]
	)
]

as-map-rule: rule [pos value] [
	'as 'map
	; TODO: move datatypes to separate rule for reusability
	eval pos: set value any-type!
	(
		debug-print ["++AS MAP -" mold value ":" mold pos]
		value: to map! value
		change-code pos value
	)
	:pos
]

as-rule: rule [pos value type] [
	'as
	; TODO: move datatypes to separate rule for reusability
	eval set type ['string | 'date | 'integer | 'class | 'file]
	eval pos: set value any-type!
	(
		debug-print ["++AS" type "-" mold value ":" mold pos]
		unless block? value [value: reduce [value]]
		value: map-each val value [
			switch type [
				string 		[form val]
				date 		[attempt [to date! val]]
				integer 	[attempt [to integer! val]]
				file 		[to file! val]
				class 		[to word! join #"." form val]
			]
		]
		debug-print ["++AS" type "=" mold value]
		either 1 = length? value [
			change-code pos value/1
		] [
			change-code pos value
		]
	)
	:pos
]

join-rule: rule [values type delimiter result] [
	;TODO: support commands?
	;
	;TODO: change JOIN dialect: word is word, to access variables, use get-word [set x "zdar" join as class [na :x]] -> .nazdar
	;
	'join 
	(delimiter: type: none)
	opt ['as set type word!]
	eval set values block!
	opt ['with set delimiter [char! | string!]]
	pos:
	(
		debug-print ["++JOIN AS" type]
		pos: back pos
		result: make string! 100
		forall values [
			append result switch/default type?/word values/1 [
				word! 		[get-user-word :values/1]
				lit-word! 	[form to word! values/1]
				issue!		[form to word! values/1]
			] [form values/1]
			all [
				delimiter 
				not tail? next values
				append result delimiter
			]
		]
		if type [
			result: switch type [
				class 	[to word! head insert result #"."]
				id 		[to issue! result]
				file 	[to file! result]
			]
		]
;		pos/1: result
		change-code pos result
	)
	:pos
]

length-rule: rule [series] [
	'length?
	eval
	pos: set series block! 
	(change-code pos form length? series)
	:pos
]

insert-append-rule: rule [command series value] [
	set command ['append | 'insert]
	; FIXME: currently very dangerous!
	; you could do: [set x [] insert x now] and NOW will get executed
	eval
	set series block!
	eval
	set value any-type!
	(do reduce [command series 'value]) ; <- temporary fix for above problem until final solution is found
]

;---/commands

get-style: rule [pos data type] [
	set type ['id | 'class]
	pos:
	set data [word! | block!] (
;	NOTE: folowing line throws " not in the specified context" error
;			and I'm not sure what's it's purpose
		data: either word? data [get bind data user-words] [rejoin bind data user-words]
		data: either type = 'id [to issue! data] [to word! head insert to string! data dot]
;		change/part pos data 1
		change-code pos data
	)
	:pos
]

style: rule [pos word continue] [
	any [
		get-style
	|	set word issue! (tag/id: next form word debug-print ["** " tag-name "/id: " tag/id])
	|	[
			pos: set word word!
			(
				continue: either #"." = take form word [
					append used-styles word
					append tag/class next form word
					debug-print ["** " tag-name "/class: " tag/class]
					[]
				][
					debug-print ["** " tag-name " not a style: " word]
					[end skip]
				]
			)
			continue
		]
	|	'with set word block! ( append tag word )
	]
]

comment: [
	'comment [ block! | string! ]
]

debug-rule: rule [ value ] [
	'debug [
		set value string!
		(debug-print ["debug:" value])
	|	pos: 'words
		(
			value: rejoin ["user-words:" mold user-words]
			pos/1: value
			debug-print value
		)
		:pos
	]
]

body-atts: rule [value] [
	'append
	'body
	set value block!
	(
		append includes/body-tag value
	)
]

run: rule [file] [
	if (not safe?)
	'run
	eval
	set file [file! | url!]
	(do file)
]

script: rule [type value] [
	(type: none)
	opt [ set type ['insert | 'append] ]
	'script
	(debug-print ["$$ SCRIPT:" type])
;	init-tag
	set value [ string! | file! | url! | path! ]
	(
		if path? value [ 
			; This way we get JS-PATH from user words, 
			; if it's been set or global is used when not
			value: get first bind reduce [value] user-words
		]
		value: ajoin either string? value [
			[<script type="text/javascript"> value ]
		] [
			[{<script src="} value {">} ]
		]
		append value close-tag 'script
		(debug-print ["$$SCRIPT emit: " value])
		switch/default type [
			; TODO: rewrite using APPLY
			insert [ emit-script/insert value ]
			append [ emit-script/append value ]
		] [ emit-script value ]
	)
]

; --- header
; TODO: remove custom rules from header (script, style...)
; TODO: better META
; TODO: use EMIT

stylesheet: rule [value] [
	pos:
	'stylesheet some [
		set value [ file! | url! | path! ] (
			if path? value [ 
				; This way we get CSS-PATH from user words, 
				; if it's been set or global is used when not
				value: get first bind reduce [value] user-words 
			]
			emit-stylesheet value
			debug-print ["==STYLESHEET:" value]
		)		
	]
]

page-header: [
	'head (debug-print "==HEAD")
	(header?: true)
	header-rule
	pos: 
	'body (
		debug-print "==BODY"
		; TODO: UGLY hack! move elsewhere
		repend includes/header [{<script src="} js-path {lest.js">}</script> newline ]
	)
]

header-title: rule [value] [
	'title eval set value string! (page/title: value debug-print "==TITLE")
]

header-language: rule [value] [
	['lang | 'language] set value word! (page/lang: value debug-print "==LANG")
]

meta-rule: rule [type name value] [
	'meta [
		set name word! set value string! (
			repend page/meta [ {<meta name="} name {" content="} value {">}]
		)
	|	set type set-word! set name word! set value string! (
			repend page/meta [ {<meta } to word! type {="} name {" content="} value {">}]
		)	
	]
]

favicon-rule: rule [value] [
	'favicon set value [file! | url!] (
		repend includes/header [
			{<link rel="icon" type="image/png" href="} value {">}
		]
	)
]

header-rule: [
	any [
		eval 
		pos:
		[header-content | into header-content]
	]
	:pos
	; NOTE: without this :pos, position is not preserved when returning to PAGE-HEADER rule
	; TODO: check for possible problems
]

header-content: [
	header-title
|	header-language
|	stylesheet
|	style-rule
|	script
|	meta-rule
|	favicon-rule
|	import
|	debug-rule
|	plugins
]


;  ____                _____   _____    _____     ______   _        ______   __  __    _____
; |  _ \      /\      / ____| |_   _|  / ____|   |  ____| | |      |  ____| |  \/  |  / ____|
; | |_) |    /  \    | (___     | |   | |        | |__    | |      | |__    | \  / | | (___
; |  _ <    / /\ \    \___ \    | |   | |        |  __|   | |      |  __|   | |\/| |  \___ \
; | |_) |  / ____ \   ____) |  _| |_  | |____    | |____  | |____  | |____  | |  | |  ____) |
; |____/  /_/    \_\ |_____/  |_____|  \_____|   |______| |______| |______| |_|  |_| |_____/
;

br: [ 'br ( emit <br> ) ]
hr: [ 'hr ( emit <hr> ) ]

main-rule: rule [] [
	throw "Unknown tag, command or user template"
	[some content-rule]
]

content-rule: [
	commands
|	[
		basic-string-match		; must match string! first, or INTO will eat it!
		basic-string-processing
		(emit value)
	]
|	elements
|	into main-rule
]


match-content: rule [] [
	throw "Expected string, tag or block of tags"
	content-rule
]

paired-tags: [ 'i | 'b | 'p | 'pre | 'code | 'div | 'span | 'small | 'em | 'strong | 'header | 'footer | 'nav | 'section | 'button ]
paired-tag: rule [] [
	set tag-name paired-tags
	init-tag
	eval
	opt style
	opt actions
	emit-tag
	eval
	match-content
	end-tag
]

image: rule [value] [
	['img | 'image]
	(
		debug-print "==IMAGE"
		tag-name: 'img
	)
	init-tag
	some [
		set value [ file! | url! ] (
			append tag compose [ src: (value) alt: "Image" ]	; TODO: support ALT in LEST dialect
		)
	|	set value pair! (
			append tag compose [
				width: (to integer! value/x)
				height: (to integer! value/y)
			]
		)
	|	style
	]
	take-tag
	emit-tag
]

; <a>
link: rule [value] [
	['a | 'link] ( tag-name: 'a )
	init-tag
	eval
	set value [ file! | url! | issue! ]
	(append tag compose [ href: (value) ])
	eval
	opt style
	emit-tag
	match-content
	end-tag
]

; lists - UL, OL, LI, DL

li: [
	set tag-name 'li
	init-tag
	opt style
	emit-tag
	match-content
	end-tag
]

ul: [
	set tag-name 'ul
	(debug-print "--UL--")
	init-tag
	opt style
	emit-tag
	eval
	match-content
	end-tag
]

ol: rule [value] [
	set tag-name 'ol
	init-tag
	any [
		; NOTE: if I change order of rules, it stops working. Not sure why
		set value integer! ( append tag compose [ start: (value) ] )
	|	style
	]
	emit-tag
	some li
	end-tag
]

dl: [
	set tag-name 'dl
	init-tag
	opt [
		'horizontal ( append tag/class 'dl-horizontal )
	|	style
	]
	emit-tag
	some [
		; NOTE: we need to match string first before initializing tag
		;		or it will be added to tag-stack
		basic-string-match
		(tag-name: 'dt)
		init-tag
		basic-string-processing
		style
		emit-tag
		(emit value)
		end-tag

		basic-string-match
		(tag-name: 'dd)
		init-tag		
		basic-string-processing
		style
		emit-tag
		(emit value)
		end-tag
	]
	end-tag
]

list-elems: [
	ul
|	ol
|	dl
]

list-content: [
	some li
]

basic-elems: [
	[
		basic-string-match
		basic-string-processing
		(emit value)
	]
|	comment
|	debug-rule
|	body-atts
|	pass
|	stop
|	br
|	hr
|	table
|	paired-tag
|	image
|	link
|	list-elems
;|	dom-rules
]

basic-string: [
	(current-text-style: none)
	opt [set current-text-style ['plain | 'html | 'markdown]]
	opt [user-values]
	set value [string! | date! | time! | number!] ; TODO: support integer?
	(
		unless current-text-style [current-text-style: text-style]
		value: form value
		value: switch current-text-style [
			plain		[value]
			html 		[escape-entities value]
			markdown 	[markdown value]
		]
	)
	(emit value)	
]

basic-string-match: [
	(current-text-style: none)
	opt [set current-text-style ['plain | 'html | 'markdown]]
	opt [user-values]
	set value [string! | date! | time! | number!] ; TODO: support integer?
]

basic-string-processing: [
	(
		unless current-text-style [current-text-style: text-style]
		value: form value
		value: switch current-text-style [
			plain		[value]
			html 		[escape-entities value]
			markdown 	[markdown value]
		]
	)
]

pass: [
	'pass
]

stop: [
	'stop
	to end
]

; --- headings
; TODO: headings can contain Phrasing elements (see HEADER/NOTE)
heading: [
	set tag-name [ 'h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6 ]
	init-tag
	opt style
	emit-tag
	eval
	match-content
	end-tag
]

; table

table: rule [value] [
	set tag-name 'table
	init-tag
	(append tag/class 'table)
	style
	emit-tag
	opt [
		'header
		(tag-name: 'tr)
		init-tag
		emit-tag
		into [
			some [
				set value string!
				(tag-name: 'th)
				init-tag
				emit-tag
				(emit value)
				end-tag
			]
		]
		end-tag
	]
	any [
		into [
			(tag-name: 'tr)
			init-tag
			emit-tag
			some [
				pos: block! :pos 	; check for value before initing <TD>
				(tag-name: 'td)
				init-tag
				emit-tag
				into main-rule
				end-tag
			]
			end-tag
		]
	]
	end-tag
]

;  ______    ____    _____    __  __    _____
; |  ____|  / __ \  |  __ \  |  \/  |  / ____|
; | |__    | |  | | | |__) | | \  / | | (___
; |  __|   | |  | | |  _  /  | |\/| |  \___ \
; | |      | |__| | | | \ \  | |  | |  ____) |
; |_|       \____/  |_|  \_\ |_|  |_| |_____/
;

label-rule: rule [value elem] [
	set tag-name 'label
	(elem: none)
	opt [set elem issue!]
	set value string!
	init-tag
	(
		all [
			elem
			append tag compose [for: (next form elem)]
		]
		value-to-emit: value
	)
	emit-tag
	emit-value
	end-tag
]

init-input: rule [value] [
	(
		tag-name: 'input
		default: none
	)
	init-tag
]
emit-input: [
	(append tag compose [name: (name) placeholder: (default) value: (value)])
	emit-tag
	close-tag
]
old-emit-input: [
	(
		switch/default form-type [
			horizontal [
				unless empty? label [
					emit-label/class label name	[col-sm-2 control-label]
				]
				emit <div class="col-sm-10">
				set [tag-name tag] take/part tag-stack 2
				append tag compose [ name: (name) placeholder: (default) value: (value) ]
				emit build-tag tag-name tag
				emit </div>
			]
		][
			unless empty? label [
				emit-label label name
			]
			set [tag-name tag] take/part tag-stack 2
			append tag compose [ name: (name) placeholder: (default) value: (value) ]
			emit build-tag tag-name tag
		]
	)
]
input-parameters: rule [list data] [
	set name word!
	(
		debug-print ["INPUT:name=" name]
		local datalist none
	)
	any [
		eval-strict any [
			set label string! (debug-print ["INPUT:" name " label:" label])
		|	'default eval set default string! (debug-print ["INPUT:" name " default:" default])
		|	'value eval set value string! (debug-print ["INPUT:" name " value:" value]) 
		|	'checked	(debug-print ["INPUT:" name " checked"])					(append tag [checked: true])
		|	'required	 (debug-print ["INPUT:" name " required"])					(append tag [required: true])
		|	'error (debug-print ["INPUT:" name " error"]) eval set data string!		(append tag compose [data-error: (data)])
		|	'match (debug-print ["INPUT:" name " match"]) eval set data [word! | issue!]		(append tag compose [data-match: (to issue! data)])
		|	'min-length (debug-print ["INPUT:" name " minlength"]) eval set data [string! | integer!] eval set def-error string! (append tag compose [data-minlegth: (data)])
		|	'datalist (list: none debug-print ["INPUT:" name " minlength"]) eval opt [set list word!] eval set data block! (local datalist data local datalist-id list)
		|	actions (debug-print ["INPUT:" name " after actions"])
		|	style (debug-print ["INPUT:" name " after style"])
		]
	]
]

input: rule [type simple continue] [
	(simple: default: value: label: def-error: none)
	opt ['simple (simple: true)]
	set type [
		'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
	|	'number | 'email | 'url | 'search | 'tel | 'color | 'file
	]
	if (not simple) [
		init-div
		(append tag/class 'form-group)
		emit-tag	
	]
	(tag-name: 'input)
	init-tag
	(append tag/class 'form-control)
	(append tag reduce/no-set [type: type])
	(debug-print "<input-parameters>")
	input-parameters
	(
;		unless tag/id [tag/id: rejoin [type '- get-id]]
		if locals/datalist [
			append tag compose [
				list: (
					either locals/datalist-id [
						locals/datalist-id
					] [
						rejoin [type '- get-id]
					]
				)
			]
			local datalist-id tag/list
		]
		debug-print "</input-parameters>"
		append tag compose [name: (name) placeholder: (default) value: (value)]
		emit-label label name
	)
	emit-tag
	take-tag ; INPUT has no closing tag
	if (locals/validator?) [
		init-div
		(append tag/class [help-block with-errors])
		emit-tag
		(if def-error [emit def-error])
		end-tag
	]
	if (not simple) [end-tag]
	if (locals/datalist) [
		(tag-name: 'datalist)
		init-tag
		(tag/id: locals/datalist-id)
		emit-tag
		(
			foreach value locals/datalist [
				emit build-tag 'option compose [value: (value)]
			]
		)
		end-tag
	]
]
checkbox: rule [] [
	'checkbox
	init-div
	(append tag/class 'checkbox)
	emit-tag
	(tag-name: 'label)
	init-tag
	emit-tag		; start <LABEL>
	init-input
	input-parameters
	(append tag compose [type: 'checkbox name: (name)])
	emit-tag
	take-tag
	(emit label)
	end-tag
	end-tag
]
radio: rule [] [
	'radio
	init-div
	(append tag/class 'radio)
	emit-tag
	init-input
	set name word!
	set value [ word! | string! | number! ]
	some [
		eval [
			set label string!
		|	'checked (append tag [checked: true])
		|	'disabled (append tag [disabled: true])
		|	style
		]
	]
	(
		unless tag/id [tag/id: ajoin ["radio_" name #"_" value]]
		append tag compose [ type: 'radio name: (name) value: (value) ]
	)
	emit-tag	; this emits <INPUT>
	take-tag	; we need to remove tag from stack, because <INPUT> has no close tag
	(emit-label label tag/id)
	end-tag
]
textarea: [
	; TODO: DEFAULT
	set tag-name 'textarea
	(
		size: none
		label: ""
	)
	init-tag
	set name word!
	(
		value: ""
		default: ""
	)
	some [
		set size pair!
;	|	set label string!
	|	basic-string-match (label: value value: "")
	|	'default get-user-value set default string!
	|	'value get-user-value set value string!
	|	style
	]
	take-tag
	(
		unless empty? label [ emit-label label name ]
		append tag compose [
			name: (name)
		]		
		if size [
			append tag compose [
				cols: (to integer! size/x)
				rows: (to integer! size/y)
			]
		]
		emit entag/with value tag-name tag
	)
]
hidden: rule [name value] [
	'hidden
	init-input
	set name word!
	some [
		get-user-value set value string!
	|	style
	]
	take-tag
	(
		append tag compose [ type: 'hidden name: (name) value: (value) ] 
	)
	emit-tag
]
submit: rule [label name value] [
	'submit
	(tag-name: 'button name: value: none)
	init-tag
	opt ['with set name word! set value string!]
	(
		append tag [type: submit]
		append tag/class [btn btn-default]
		if all [name value] [
			append tag compose [
				name: (name)
				value: (value)
			]
		]
	)
	opt style
	emit-tag
	[main-rule | into main-rule]
	; TODO: horizontal variant (see below)
	end-tag
]

select-input: rule [label name value] [
	set tag-name 'select 
	init-tag
	set name word! (append tag compose [name: (name)])
	emit-tag
	some [
		set value word!
		set label string!
		(tag-name: 'option)
		init-tag
		(append tag compose [value: (value)])
		opt [
			'selected
			(append tag [selected: "selected"])
		]
		emit-tag
		(emit label)
		end-tag	
	]
	end-tag
]

form-content: [
	[
		input
	|	textarea
	|	checkbox
	|	radio
	|	submit
	|	hidden
	|	select-input
;	|	plugins ; to enable captcha, password-strength, etc.
	]
]
form-type: none
form-rule: rule [value form-type enctype] [
	set tag-name 'form
	( 
		form-type: enctype: none 
		local validator? none
	)
	init-tag
	any [
		'multipart 	(enctype: "multipart/form-data")
	|	'horizontal 	(form-type: 'horizontal)
	|	'validator 	(append tag [data-toggle: 'validator] local validator? true)
	]
	(
		append tag compose [
			action:		(value)
			method:		'post
			role:			'form
			enctype: 		(enctype)
		]
		if form-type [append tag/class join "form-" form-type]
	)
	some [
		set value [file! | url!] (
			append tag compose [action: (value)]
		)
	|	style
	]
	emit-tag
	match-content
	end-tag
]

; --- put it all together

elements: rule [] [
	pos: (debug-print ["parse at: " index? pos "::" trim/lines copy/part mold pos 64 "..."] )
	[
		text-settings	; FIXME: must be before header so (markdown text) is matched before markdown as plugin
	|	page-header	
	|	basic-elems
	|	list-content
	|	form-content
	|	import
	|	process-code main-rule
	|	user-rules
	|	template-rule
	|	user-rule
	|	set-at-rule	; TODO: move to commands	
	|	set-rule 		; TODO: move to commands
	|	heading
	|	label-rule
	|	form-rule
	|	script
	|	meta-rule 	; FIXME: header only
	|	run
	|	stylesheet
	|	plugins
	]
	(
		; cleanup buffer
		value: none
	)
]

enable-plugin: rule [name t] [
	; WARNING: very fragile, touch in antistatic handgloves only!
	'enable pos: set name word! (
		; NOTE: [change/part pos t 1] is absolute neccessity,
		; 		because [pos/1: t] crashes Rebol!!!
		either t: load-plugin name [
;			change/part pos t 1
			change-code pos t
		] [pos: next pos]
	)
	:pos [main-rule | into main-rule]
]

plugins: []

] ; -- end rules context

load-plugin: func [
	name
	/local plugin header
] [
	debug-print ["load plugin" name]
	either value? 'plugin-cache [
		plugin: select plugin-cache name
		header: object [type: 'lest-plugin]
	][
		plugin: load/header rejoin [plugin-path name %.reb]
		header: take plugin
	]
	; FIXME: should use 'construct to be safer, but that doesn't work with USE for local words in rules
	; TODO: parse both rules and user-words in one step
	if equal? 'lest-plugin header/type [
		plugin: bind plugin object compose [user-words: (user-words)]
		plugin: bind plugin 'debug-print 	; TODO solve all binding inone pass
		plugin: bind plugin 'user-words
		plugin: object bind plugin rules
		if in plugin 'main 		[add-rule rules/plugins bind plugin/main 'emit]
		if in plugin 'startup 	[return plugin/startup]
	]
	none
]

;  __  __              _____   _   _
; |  \/  |     /\     |_   _| | \ | |
; | \  / |    /  \      | |   |  \| |
; | |\/| |   / /\ \     | |   | . ` |
; | |  | |  / ____ \   _| |_  | |\  |
; |_|  |_| /_/    \_\ |_____| |_| \_|
;

out-file: none

func [
	"Parse simple HTML dialect"
	data [block! file! url!]
	/save
		"If data is file!, save output as HTML file with same name"
	/debug
		"Turn on debug-print mode"
	/into
		"Generate input into given series"
		out
	/safe
		"Ignore some constructs"

] [
	start-time: now/time/precise

	if any [file? data url? data] [
		out-file: replace copy data suffix? data %.html
		data: load data
	]

; init outside vars
	safe?: safe
	debug-print: func [value] [
		if debug [print rejoin reduce [value]]
	]
	debug-stack: func [stack] [
		out: make block! 20
		forskip stack 2 [append out stack/1]
		debug-print ["##stack: " mold reverse out]
	]

	debug-lest: func [
		type 	"Debug type: words, rules, stack ...."
	] [
		switch type [
			local 		[print mold locals]
			words 	[print mold user-words print mold user-words-meta]
			rules 		[print mold user-rule-names print mold user-rules]
			values 	[print mold user-values]
			plugins 	[print mold rules/plugins]
			stack 		[
				out: make block! 20
				forskip stack 2 [append out stack/1]
				print mold reverse out
			]
		]
	]

	if debug [
		debug-print "Debug output ON"
	]

	buffer: either into [out] [make string! 10000]

	header?: false

	last-id: 0
	get-id: does [++ last-id]

	tag-stack: copy []

	user-rules: copy [ fail ]	; fail is "empty rule", because empty block isn't
	user-rule-names: make block! 100
	user-words: object []
	user-words-meta: object []
	user-values: copy/deep [ pos: [fail] :pos ]
	rules/plugins: copy/deep [ pos: [fail] :pos ]

	includes: object [
		style:			make block! 1000
		stylesheets: 	copy {}
		header:		copy {}
		body-tag:		make block! 10
		body-start:	make string! 1000
		body-end: 	make string! 1000
	]

	used-styles: make block! 20
	; LOCALS is context for variables that can be shared across rules (note: isn't it global??)
	locals: context []
	local: func [
		"Set word in LOCALS context for sharing values between PARSE rules"
		'word value
	] [
		append locals reduce [to set-word! :word value]
	]
	local validator? none
	local lazy? false
; ---

	page: reduce/no-set [
		title: "Page generated with Lest"
		meta: copy {}
		lang: "en-US"
	]
	debug-print "run main parse"
	unless parse data bind rules/main-rule rules [
;		return make error! ajoin ["LEST: there was error in LEST dialect at: " mold pos]
		error: make error! "LEST: there was error in LEST dialect"
		error/near: pos
		do error
	]

	body: head buffer

	unless empty? includes/style [
;		write %lest-temp.css prestyle includes/style
;		debug-print ["CSS wrote to file %lest-temp.css"]
	]

	body: either header? [
		ajoin [
<!DOCTYPE html> newline
{<html lang="} page/lang {">} newline
	<head> newline
		<title> page/title </title> newline
		<meta charset="utf-8"> newline
		page/meta newline
		includes/stylesheets
		includes/header
	</head> newline
;	<body data-spy="scroll" data-target=".navbar">	; WHAT AN UGLY HACK!!!
	build-tag 'body includes/body-tag
		includes/body-start
		body
		includes/body-end
	</body>
</html>
		]
	][
		body
	]
	if out-file [
		write out-file body
	]
	debug-print ["== generated in " now/time/precise - start-time]
	body
]


] ; --- end main context