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

; fuck off current module system

do %compile-rules.reb

; /fuck off


debug-print: none
; :print
;none

; SETTINGS

; TODO: move settings to .PAGE files

js-path: %../../js/			; we are in cgi-bin/lib/ so we need to go two levels up
css-path: %../../css/

js-path: %js/			; we are in work dir so we need to go just one level up
css-path: %css/

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
	parse data [some rule]
	output
]

catenate: funct [
	"Joins values with delimiter."
    src [ block! ]
    delimiter [ char! string! ]
    /as-is "Mold values"
][
    out: make string! 200
    forall src [ repend out [ either as-is [mold src/1] [src/1] delimiter ] ]
    len: either char? delimiter [ 1 ][ length? delimiter ]
    head remove/part skip tail out negate len len
]

replace-deep: funct [
	target
	'search
	'replace
][
	rule: compose [
		change (:search) (:replace)
	|	any-string!
	|	into [ some rule ]
	|	skip
	]
	parse target [ some rule ]
	target
]

rule: func [
	"Make PARSE rule with local variables"
	local 	[word! block!]  "Local variable(s)"
	rule 	[block!]		"PARSE rule"
][
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

get-integer: func [
	"Get integer! value from string! or pass integer! (returns NONE otherwise)"
	value
	/local number int-rule
] [
	if integer? value [return value]
	number: 		charset "0123456789"
;	float-rule: 	[opt #"-" some number [opt #"." some number]]
	int-rule: 		[opt #"-" some number]
	if parse value int-rule [to integer! value]
]

lest: use [
	debug-print
	output
	buffer
	page
	tag
	tag-name
	tag-stack
	includes	
	rules
	header?
	pos

	current-text-style
	used-styles

	name
	value

	emit
	emit-label
	emit-stylesheet

	user-rules
	user-words
	user-values

	plugins
	load-plugin
] [

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
	emit entag/with label 'label reduce/no-set [ for: elem class: styles ]
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

import: rule [p value] [
	; LOAD AND EMIT FILE
	'import p: set value [ file! | url! ]
	( p/1: load value )
	:p main-rule
]

text-settings: rule [type] [
	set type ['plain | 'html | 'markdown]
	'text
	(text-style: type)
]

eval: [any [user-values | process-code | commands | plugins]]

process-code: rule [ p value ] [
	; DO PAREN! AND EMIT LAST VALUE
	p: set value paren!
	( 
		p/1: do bind to block! value user-words 
	)
	:p
	]

do-code: rule [ p value ] [
	; DO PAREN! AND EMIT LAST VALUE
	p: set value paren!
	( 
		p/1: append clear [] do bind to block! value user-words 
	)
	:p main-rule
	]

set-rule: rule [labels values] [
	'set
	set labels [word! | block!]
	eval set values any-type!
	(
		unless block? labels [
			labels: reduce [labels]
			values: reduce [values]
		]
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
				append second user-values compose [ 
					|
						(to lit-word! label) 
						(to paren! compose [change pos (to path! reduce ['user-words label])]) 
				]
			]
			; extend user context with new value
			repend user-words [to set-word! label value] 
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
			pos/1: user-words/:value
		]
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

			repend this-rule [ to set-word! 'pos 'set label type ]
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
				parse temp: copy/deep (value) [ some urule ]
				change/only pos temp
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

style-rule: rule [data] [
	'style
	set data block!
	(append includes/style data)
]

; dynamic actions

; currently defined: 
;
;	SET - SET id data
;		- set content of ID element to DATA 
;		- document.getElementById(id).innerHTML = data;

actions: rule [action value data] [
	set action ['on-click]
	(action: replace/all to string! action #"-" "")
	[
		[
			'set eval set value issue! eval set target word! eval set data any-string! (
				append tag reduce [
					to set-word! action
					rejoin [{document.getElementById('} next form value {').} target { = '} data {';}]
				]
			)
		]
	|	
		[
			'action
			set name word!
			opt [set data block!]
			eval set target issue!
			(
				append tag compose [
					onClick: (rejoin [{action('} name {', '}  data {', '} form to word! target {')}])
				]
			)	
		]
	]
]

; === FIXME: ROW needs bootstrap plugin enabled

; ROW WITH 3 COLS [span <name>] REPLACE <name> FROM ["Venus" "Earth" "Mars"]

; (block: ["Venus" "Earth" "Mars"] ...)
; ROW WITH 3 COLS [span <name>] REPLACE <name> FROM block

; ROW WITH 3 COLS [span <name>] REPLACE <name> FROM %data.r

; ROW WITH 3 COLS [span <name>] REPLACE <name> FROM http://www.mraky.net/data.r

make-row: [
	'row
	'with
	(
		index: 1
		offset: none
	)
	some [
		set cols integer!
		[ 'col | 'cols ]
	|	'offset
		set offset integer!
	;
	; --
	; -- TODO: COL x COL y COL ...
	; --
	; -- set DATA and use it later
	; --
	;
	]
	set element block!
	'replace
	set value get-word!
	[
		'from
		set data pos: [ block! | word! | file! | url! ]
		(
			out: make block! length? data
			switch type?/word data [
				word!	[ data: get data ]
				url!	[ data: read data ] 	; CHECK
				file!	[ data: load data ]
			]
			foreach item data [
				current: copy/deep element
				replace-deep current value item
				if offset [
					insert skip find current 'col 2 reduce [ 'offset offset ]
					offset: none
				]
				append out current
			]
			change/only pos compose/deep [ row [ (out) ] ]
		)
		:pos into main-rule
	|	'with
		pos: set data block!
		(
			out: make block! length? data
			; replace <filename> with [ rejoin [ %img/image- index %.jpg ] ]
			repeat index cols [
				current: copy/deep element
				replace-deep current value do bind data 'index
				if offset [
					insert skip find current 'col 2 reduce [ 'offset offset ]
					offset: none
				]
				append out current
			]
			change/only pos compose/deep [ row [ (out) ] ]
		)
		:pos into main-rule
	]

]


init-tag: [
	(
		insert tag-stack reduce [ tag-name tag: context [ id: none class: copy [] ] ]
	)
]

take-tag: [ ( set [tag-name tag] take/part tag-stack 2 ) ]

emit-tag: [ ( emit build-tag tag-name tag ) ]

end-tag: [
	take-tag
	( emit close-tag tag-name )
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

comparison-rule: rule [val1 val2 comparator pos number] [
	; NOTE: all values are formed before comparison
	;			this leads to double conversion if numbers ( 3 -> "3" -> 3 )
	;			and needs to be optimalized
	set val1 any-type!
	set comparator ['= | '> | '< | '>= | '<= | '<>]
	set val2 any-type!
	pos:
	(
		val1: form switch/default type?/word val1 [
			word! [get in user-words :val1]
		][val1]
		val2: form switch/default type?/word val2 [
			word! [get in user-words :val2]
		][val2]
		; numbers - TODO use float rule, add scientific notation
		val1: get-integer val1
		val2: get-integer val2
		pos: back pos
		pos/1: do reduce [val1 comparator val2]
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
		; TODO: should return error on non-integer values or silently ignore?
		action: select [++ + -- -] action
		all [
			value: get in user-words word
			value: get-integer value
			integer? value
			user-words/:word: form do reduce ['value action 1]
		]
	)
]

math-rule: rule [pos action val1 val2] [
	set val1 [string! | integer! | word!]
	set action ['+ | '- | '*]
	pos: set val2 [string! | integer! | word!]
	(
		if word? val1 [val1: get in user-words val1]
		if word? val2 [val2: get in user-words val2]
		val1: get-integer val1
		val2: get-integer val2
		pos/1: form do reduce ['val1 action 'val2]
	)
	:pos
]

commands: [
	if-rule
|	either-rule
|	switch-rule
|	for-rule
|	repeat-rule
|	join-rule
|	math-commands
]

if-rule: rule [cond true-val pos res] [
	'if
	opt comparators
	set cond [logic! | word! | paren!] 
	pos:
	set true-val any-type! 
	(
		res: if/only do bind to block! cond user-words true-val
		either res [
			change/part pos res 1
		] [
			pos: next pos
		]
	)
	:pos
]

either-rule: rule [cond true-val false-val pos] [
	'either
	opt comparators
	set cond [logic! | word! | paren!]
	set true-val any-type! 
	pos:
	set false-val any-type! 
	(
		change/part 
			pos 
			either/only do bind to block! cond user-words true-val false-val 
			1
	)
	:pos
]

switch-rule: rule [value cases defval pos] [
	'switch
	(defval: none)
	set value word!
	pos:
	set cases block!
	opt [
		'default 
		pos:
		set defval any-type!
	]
	(
		forskip cases 2 [cases/2: append/only copy [] cases/2]
		value: get bind value user-words
		change/part
			pos
			switch/default value cases append/only copy [] defval
			1
	)
	:pos
]

; FIXME: FOR set variable with user name in user-words
; 			it doesn't clean it and can rewrite user's variable

for-rule: rule [pos out var src content] [
	'for
	set var [word! | block!]
	'in
	set src [word! | block!]
	pos: set content block! (
		out: make block! length? src
		if word? src [src: get in user-words src]
		forall src [
			either block? var [
				repeat i length? var [
					append out compose/only [set (var/:i) (src/:i)]
				]
				src: skip src -1 + length? var
				append/only out copy/deep content
			] [
				append out compose/only [set (var) (src/1) (copy/deep content)]
			]
		]
		change/only/part pos out 1
	)
	:pos main-rule
]

repeat-rule: rule [offset element count value values data pos current][
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
		set count [integer! | paren!]
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
				change/part pos out 1
			)
			:pos
		]
	|	[
			'with
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
				change/part pos out 1
			)
			:pos
		]
	]
]

join-rule: rule [values delimiter result] [
	'join 
	(delimiter: none)
	set values block!
	opt ['with set delimiter [char! | string!]]
	pos:
	(
		pos: back pos
		result: make string! 100
		forall values [
			append result switch/default type?/word values/1 [
				word! [get in user-words :values/1]
			] [form values/1]
			if all [delimiter not tail? next values] [append result delimiter]
		]
		pos/1: result
	)
	:pos
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
		change/part pos data 1
	)
	:pos
]

style: rule [ pos word continue ] [
	any [
		commands
	|	get-style
	|	set word issue! ( tag/id: next form word )
	|	[
			pos: set word word!
			(
				continue: either #"." = take form word [
					append used-styles word
					append tag/class next form word
					[]
				][
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
	'debug set value string!
	( debug-print ["debug:" value])
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
	'run
	eval
	set file [file! | url!]
	(do file)
]

script: rule [type value] [
	(type: none)
	opt [ set type ['insert | 'append] ]
	'script
	init-tag
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
	header-content
	'body (
		debug-print "==BODY"
		; TODO: hack! move elsewhere
		repend includes/header [{<script src="../js/lest.js">}</script> newline ]
	)
]

header-content: rule [type name value] [
	any [
		'title set value string! (page/title: value debug-print "==TITLE")
	|	['lang | 'language] set value word! (page/lang: value debug-print "==LANG")	
	|	set-rule	
	|	stylesheet
	|	style-rule
	|	'style set value string! (
			append includes/stylesheet entag value 'style
		)
	|	'script [
			set value [ file! | url! ] (
				repend includes/header [{<script src="} value {">}</script> newline ]
			)
		|	set value string! (
				append includes/header entag value 'script
			)
		]
	|	'meta set name word! set value string! (
			repend page/meta [ {<meta name="} name {" content="} value {">}]
		)
	|	'meta set type set-word! set name word! set value string! (
			repend page/meta [ {<meta } to word! type {="} name {" content="} value {">}]
		)	
	|	'favicon set value url! (
			repend includes/header [
				{<link rel="icon" type="image/png" href="} value {">}
			]
	)
	|	import
	|	debug-rule
	|	plugins
	]
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
	opt style
	opt actions
	emit-tag
;	throw "Expected string, tag or block of tags"
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
	any [user-values | process-code]
	set value [ file! | url! | issue! ]
	(append tag compose [ href: (value) ])
	any [user-values | process-code]
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
	some li
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

init-input: rule [value] [
	(
		tag-name: 'input
		default: none
	)
	init-tag
	(
		tag-name: first tag-stack
		tag: second tag-stack
	)
]
emit-input: [
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
input-parameters: rule [data] [
	set name word!
	any [
		set label string!
	|	'default eval set default string!
	|	'value eval set value string!
	|	eval 'checked						(append tag [checked: true])
	|	eval 'required						(append tag [required: true])
	|	'error eval set data string!		(append tag compose [data-error: (data)])
	|	'match eval set data [word! | issue!]		(append tag compose [data-match: (to issue! data)])
	|	'min-length eval set data [string! | integer!] eval set def-error string! (append tag compose [data-minlegth: (data)])
	|	style
	]
]
input: rule [type simple] [
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
	init-input
	( append tag/class 'form-control )
	( append tag reduce/no-set [type: type] )
	input-parameters
	emit-input
	if (validator?) [
		init-div
		(append tag/class [help-block with-errors])
		emit-tag
		(if def-error [emit def-error])
		end-tag
	]
	if (not simple) [end-tag]
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
		eval set label string!
	|	eval 'checked (append tag [checked: true])
	|	eval 'disabled (append tag [disabled: true])
	|	style
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
		size: 50x4
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
			cols: (to integer! size/x)
			rows: (to integer! size/y)
			name: (name)
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
		br
	|	input
	|	textarea
	|	checkbox
	|	radio
	|	submit
	|	hidden
	|	select-input
;	|	plugins ; to enable captcha, password-strength, etc.
	; TODO: elements ?
	]
]
form-type: none
form-rule: rule [value form-type] [
	set tag-name 'form
	( form-type: enctype: validator?: none )
	init-tag
	any [
		'multipart 	(enctype: "multipart/form-data")
	|	'horizontal 	(form-type: 'horizontal)
	|	'validator 	(append tag [data-toggle: 'validator] validator?: true)
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
	take-tag
	emit-tag
	into main-rule
	(emit close-tag 'form)
]

; --- put it all together

elements: rule [] [
	pos: (debug-print ["parse at: " index? pos "::" trim/lines copy/part mold pos 24] )
	[
		text-settings	; FIXME: must be before header so (markdown text) is matched before markdown as plugin
	|	page-header	
	|	basic-elems
	|	form-content
	|	import
	|	do-code
	|	make-row
	|	user-rules
	|	user-rule
	|	set-rule
	|	heading
	|	form-rule
	|	script
	|	run
	|	stylesheet
	|	plugins
	]
	(
		; cleanup buffer
		value: none
	)
]

plugins: rule [name t] [
	; WARNING: very fragile, touch in antistatic handgloves only!
	'enable pos: set name word! (
		; NOTE: [change/part pos t 1] is absolute neccessity,
		; 		because [pos/1: t] crashes Rebol!!!
		either t: load-plugin name [change/part pos t 1] [pos: next pos]
	)
	:pos [main-rule | into main-rule]
]

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
		plugin: object bind plugin rules
		if in plugin 'rule 			[add-rule rules/plugins bind plugin/rule 'emit]
		if in plugin 'startup 	[return plugin/startup]
	]
	none
]

comment [
user-rules: rule [] [ fail ]	; fail is "empty rule", because empty block isn't
user-rule-names: make block! 100
user-words: object []
user-values: copy/deep [ pos: [fail] :pos ]
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
] bind [

	if any [file? data url? data] [
		out-file: replace copy data suffix? data %.html
		data: load data
	]


; init outside vars
	debug-print: none
	if debug [
		debug-print: :print
		debug-print "Debug output ON"
	]

	output: copy ""
	buffer: copy ""

	header?: false

	tag-stack: copy []

	user-rules: copy [ fail ]	; fail is "empty rule", because empty block isn't
	user-rule-names: make block! 100
	user-words: object []
	user-values: copy/deep [ pos: [fail] :pos ]

;	clear head output
;	clear head buffer

	includes: object [
		style:			make block! 1000
		stylesheets: 	copy {}
		header:			copy {}
		body-tag:		make block! 10
		body-start:		make string! 1000
		body-end: 		make string! 1000
	]

	used-styles: make block! 20

; ---

	page: reduce/no-set [
		title: "Page generated with Lest"
		meta: copy {}
		lang: "en-US"
	]

	unless parse data bind rules/main-rule rules [
;		return make error! ajoin ["LEST: there was error in LEST dialect at: " mold pos]
		error: make error! "LEST: there was error in LEST dialect"
		error/near: pos
		do error
	]

	body: head buffer

	unless empty? includes/style [
		write %lest-temp.css prestyle includes/style
		debug-print ["CSS wrote to file %lest-temp.css"]
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
	body
] 'buffer


] ; --- end main context