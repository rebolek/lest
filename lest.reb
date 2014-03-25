REBOL[
	Title:		"LEST - Low Entropy System for Templating"
	Author:		"Boleslav Brezovsky"
	Name: 		'lest	
	Version:	0.0.4
	Date:		18-3-2013
	Started:	7-12-2013
;	Type: 		'module
;	Exports: 	[lest]
;	Options: 	[isolate]
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
		"REPEAT: support multiple variables"
		"REPEAT: support for lists (or vice versa - lists, support for repeat"
		"REPEAT should be universal"
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
	]
]

debug:
:print
none

; SETTINGS

; TODO: move settings to .PAGE files

js-path: %../../js/			; we are in cgi-bin/lib/ so we need to go two levels up
css-path: %../../css/

js-path: %js/			; we are in work dir so we need to go just one level up
css-path: %css/

; FIXME: should be moved to markdown plugin (once it works)
do %md.reb
markdown?: yes

;
;   _____   _    _   _____    _____     ____    _____    _______     ______   _    _   _   _    _____    _____
;  / ____| | |  | | |  __ \  |  __ \   / __ \  |  __ \  |__   __|   |  ____| | |  | | | \ | |  / ____|  / ____|
; | (___   | |  | | | |__) | | |__) | | |  | | | |__) |    | |      | |__    | |  | | |  \| | | |      | (___
;  \___ \  | |  | | |  ___/  |  ___/  | |  | | |  _  /     | |      |  __|   | |  | | | . ` | | |       \___ \
;  ____) | | |__| | | |      | |      | |__| | | | \ \     | |      | |      | |__| | | |\  | | |____   ____) |
; |_____/   \____/  |_|      |_|       \____/  |_|  \_\    |_|      |_|       \____/  |_| \_|  \_____| |_____/
;

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
	if word? local [ local: reduce [ local ] ]
	use local reduce [ rule ]
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

lest: use [
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

	name
	value

	emit
	emit-label
	emit-stylesheet

	user-rules
	user-words

	plugins
	plugin-path
	load-plugin
] [

output: copy ""
buffer: copy ""

header?: false

tag-stack: copy []

includes: object [
	stylesheets: 	copy {}
	header:			copy {}
	body-start:		copy {}
	body-end: 		copy {}
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
	emit entag/with label 'label reduce/no-set [ for: elem class: styles ]
]

emit-script: func [
	script
	/insert
	/append
][
	if insert [lib/append includes/body-start script]
	if append [lib/append includes/body-end script]
]

emit-stylesheet: func [
	stylesheet
][
	if path? stylesheet [ stylesheet: get stylesheet ]
	unless find includes/stylesheets stylesheet [
		repend includes/stylesheets [{<link href="} stylesheet {" rel="stylesheet">} newline ]
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
;	includes: object [
;		stylesheets: 	copy {}
;		header:			copy {}
;		body-start:		copy {}
;		body-end: 		copy {}
;	]

; --- subrules

import: rule [p value] [
	; LOAD AND EMIT FILE
	'import p: set value [ file! | url! ]
	( p/1: load value )
	:p into elements
]

; NOTE: this works

;	parse [ ( [print "a"] ) ] [
;		[set value paren! (value result: to paren! first value) result]
;	]

do-code: rule [ p value ] [
	; DO PAREN! AND EMIT LAST VALUE
	p: set value paren!
	( p/1: append clear [] do value )
	:p into elements
	]

set-rule: rule [ label value ] [
	'set
	set label word!
	set value any-type!
	( repend user-words [to set-word! label value] )
]

user-rule: rule [ name label type value urule args ] [
	set name set-word!
	(
		args: copy [ ]
		add-rule user-rules reduce [
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

			repend last user-rules [ to set-word! 'pos 'set label type ]
		)
	]
	set value block!
	(
		append last user-rules reduce [
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
	)
]

;FIXME:
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
	set value tag!
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

; FIXME

repeat-rule: [
	'repeat
	( offset: none )
	opt [
		'offset
		set offset integer!
	]
	set element block!
	'replace
	set value tag!
	[
		[
			'from
			set data [ block! | word! ]
			(
				if word? data [ data: get data ]
				out: make block! length? data
				foreach item data [
					current: copy/deep element
					replace-deep current value item
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				]
				emit lest compose/deep [ row [ (out) ] ]
			)
		]
	|	[
			'with
			set data block!
			(

			)
		]
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

commands: [
	if-rule
|	either-rule
|	switch-rule
]

if-rule: rule [cond true-val] [
	'if
	set cond [logic! | word! | block!] 
	pos:
	set true-val any-type! 
	(
		res: if/only do cond true-val
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
	set cond [logic! | word! | block!]
	set true-val any-type! 
	pos:
	set false-val any-type! 
	(
		change/part 
			pos 
			either/only do cond true-val false-val 
			1
	)
	:pos
]

switch-rule: rule [value cases defval] [
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
		probe cases
		value: probe get value
		probe defval
		change/part
			pos
			probe switch/default value cases append/only copy [] defval
			1
	)
	:pos
]

style-id: rule [data] [
	'id
	set data [word! | block!] 
]

style-class: rule [data] [
]

style: rule [ word continue ] [
	any [
		commands
;	|	
	|	set word issue! ( tag/id: next form word )
	|	[
			pos: set word word!
			(
				continue: either #"." = take form word [
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
	( print ["DEBUG:" value])
]

script: rule [type value] [
	opt [ set type ['insert | 'append] ]
	'script
	init-tag
	set value [ string! | file! | url! | path! ]
	(
		if path? value [ value: get value ]
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
		] [ emit value ]
	)
]

; --- header
; TODO: remove custom rules from header (script, style...)
; TODO: better META
; TODO: use EMIT

stylesheet: rule [value] [
	pos:
	'stylesheet set value [ file! | url! | path! ] (
		if path? value [ value: get value ]
		emit-stylesheet value
		debug ["==STYLESHEET:" value]
	)
]

page-header: [
	'head (debug "==HEAD")
	(header?: true)
	header-content
	'body (debug "==BODY")
]

header-content: rule [name value] [
	any [
		'title set value string! (page/title: value debug "==TITLE")
	|	stylesheet
	|	'style set value string! (
			append includes/stylesheet entag value 'style ;ajoin [ <style> value </style> ]
		)
	|	'script [
			set value [ file! | url! ] (
				repend includes/header [{<script src="} value {">}</script> newline ]
			)
		|	set value string! (
				append includes/header entag value 'script ;ajoin [ <script> value </script> newline ]
			)
		]
	|	'meta set name word! set value string! (
			repend page/meta [ {<meta name="} name {" content="} value {">}]
		)
	|	'favicon set value url! (
			repend includes/header [
				{<link rel="icon" type="image/png" href="} value {">}
			]
	)
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

main-rule: [
	some match-content
]
match-content: [
	commands
|	basic-string		; must match string! first, or INTO will eat it!
|	elements
|	into main-rule
]

paired-tags: [ 'i | 'b | 'p | 'pre | 'code (markdown?: no) | 'div | 'span | 'small | 'em | 'strong | 'footer | 'nav | 'section | 'button ]
paired-tag: [
	set tag-name paired-tags
	init-tag
	opt style
	emit-tag
	match-content
	end-tag
]

image: rule [value] [
	['img | 'image]
	(
		debug "==IMAGE"
		tag-name: 'img
	)
	init-tag
	some [
		set value [ file! | url! ] (
			append tag compose [ src: (value) ]
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
	set value [ file! | url! | issue! ]
	( append tag compose [ href: (value) ] )
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

dl: rule [value] [
	set tag-name 'dl
	init-tag
	opt [
		'horizontal ( append tag/class 'dl-horizontal )
	|	style
	]
	emit-tag
	some [
		set value string!
		( emit entag value 'dt )
		set value string!
		( emit entag value 'dd )
	]
	end-tag
]

list-elems: [
	ul
|	ol
|	dl
]

basic-elems: [
	basic-string
|	comment
|	debug-rule
|	stop
|	br
|	hr
|	table
|	paired-tag
|	image
|	link
|	list-elems
]

basic-string: rule [value] [
	set value [string! | date! | time!] ; TODO: support integer?
	(
		emit either markdown? [markdown value] [markdown?: yes value]
	)
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
	style
	( insert tag/class 'table )
	emit-tag
	opt [
		'header
		( emit <tr> )
		into [
			some [
				set value string!
				( emit ajoin [<th> value </th>] )
			]
		]
		( emit </tr> )

	]
	some [
		into [
			( emit <tr> )
			some [
				( pos: tail buffer )
				basic-elems
				( insert pos <td>)
				( emit </td> )
			]
			( emit </tr> )
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
input-parameters: [
	set name word!
	some [
		set label string!
	|	'default set default string!
	|	'value set value string!
	|	style
	]
]
input: rule [type] [
	set type [
		'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
	|	'number | 'email | 'url | 'search | 'tel | 'color
	]
	( emit <div class="form-group"> )
	init-input
	( append tag/class 'form-control )
	( append tag reduce/no-set [type: type] )
	input-parameters
	emit-input
	( emit </div> )
]
checkbox: rule [type] [
	set type 'checkbox
	( emit [ "" <div class="checkbox"> <label> ] )
	init-input
	input-parameters
	take-tag
	(
		append tag compose [ type: (type) name: (name) ]
		emit [ build-tag tag-name tag label </label> </div> ]
	)
]
radio: rule [type] [
	set type 'radio
	(
		debug "==RADIO"
		emit [ "" <div class="radio"> ]
		special: copy []
	)
	init-input
	set name word!
	set value [ word! | string! | number! ]
	some [
		set label string!
	|	'checked ( append special 'checked )
	|	style
	]
	take-tag
	(
		append tag compose [ type: (type) name: (name) value: (value) ]
		emit [
			make-tag/special tag special
				{<label for="} tag/id {">} label
				</label>
			</div>
		]
	)
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
	|	set label string!
	|	'default set default string!
	|	'value set value string!
	|	style
	]
	take-tag
	(
		unless empty? label [ emit-label label name ]
		append tag compose [
			cols: (to integer! size/x)
			rows: (to integer! size/y)
			name: (name)
;				id: (id)
		]
;			emit make-tag tag
;			emit value
;			emit close-tag tag/element
		emit entag/with value tag-name tag
	)
]
hidden: rule [name value] [
	'hidden
	init-input
	set name word!
	some [
		set value string!
	|	style
	]
	take-tag
	( append tag compose [ type: 'hidden name: (name) value: (value) ] )
	emit-tag
]
submit: rule [label] [
	'submit
	(
		insert tag-stack reduce [
			'button
			context [
				type:		'submit
				id:			none
				class: copy [btn btn-default]
			]
		]
	)
	some [
		set label string!
	|	style
	]
	take-tag
	(
		switch/default form-type [
			horizontal [
				emit [
					<div class="form-group">
					<div class="col-sm-offset-2 col-sm-10">
					build-tag tag-name tag
					label
					</button>
					</div>
					</div>
				]

			]
		][
			emit [ build-tag tag-name tag label </button> ]
		]
	)
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
;	|	plugins ; to enable captcha, password-strength, etc.
	; TODO: elements ?
	]
]
form-type: none
form-rule: rule [value form-type] [
	set tag-name 'form
	( form-type: none )
	init-tag
	opt [
		'horizontal
		( form-type: 'horizontal )
	]
	(
		append tag compose [
			action:	(value)
			method:	'post
			role:	'form
		]
		if form-type [ append tag/class join "form-" form-type ]
	)
	some [
		set value [ file! | url! ] (
			append tag compose [ action: (value) ]
		)
	|	style
	]
	take-tag
	emit-tag
	into main-rule
	( emit close-tag 'form )
]

; --- put it all together

elements: rule [] [
	pos: ( debug ["parse at: " index? pos "::" ] )
	[
;		basic-string
		page-header
	|	basic-elems
	|	form-content
	|	import
	|	do-code
	|	repeat-rule
	|	make-row
	|	user-rules
	|	user-rule
	|	set-rule
	|	heading
	|	form-rule
	|	script
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

; FIXME: because of testing in separate directory, we need absolute path
plugin-path: %/home/sony/repo/lest/plugins/

load-plugin: func [
	name
	/local plugin header
] [
	debug ["load plugin" name]
	plugin: load/header rejoin [plugin-path name %.reb]
	header: take plugin
	; FIXME: should use 'construct to be safer, but that doesn't work with USE for local words in rules
	plugin: object bind plugin rules
	if equal? 'lest-plugin header/type [
		add-rule rules/plugins bind plugin/rule 'emit
		if in plugin 'startup [return plugin/startup]
	]
	none
]

user-rules: rule [] [ fail ]	; fail is "empty rule", because empty block isn't
user-words: object []

;  __  __              _____   _   _
; |  \/  |     /\     |_   _| | \ | |
; | \  / |    /  \      | |   |  \| |
; | |\/| |   / /\ \     | |   | . ` |
; | |  | |  / ____ \   _| |_  | |\  |
; |_|  |_| /_/    \_\ |_____| |_| \_|
;

func [
	"Parse simple HTML dialect"
	data [block! file! url!]
][

	if any [file? data url? data] [data: load data]

; init outside vars

	tag-stack: copy []
	user-rules: copy [ fail ]	; fail is "empty rule", because empty block isn't
	user-words: object []

	output: copy ""
	buffer: copy ""

	includes: object [
		stylesheets: 	copy {}
		header:			copy {}
		body-start:		copy {}
		body-end: 		copy {}
	]

; ---

	page: reduce/no-set [
		title: "Page generated with Bootrapy"
		meta: copy {}
		lang: "en-US"
	]

	header?: false

	make-tag: funct [
		tag [object!]
		/special "Special attributes (without value):"
			attributes	[block!]
	][
		out: make string! 256
		skip?: false
		repend out [ "<" tag/element ]
		tag: head remove/part find body-of tag to set-word! 'element 2
		foreach [ key value ] tag [
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
				repend out [ " " to word! key {="} value {"} ]
			]
		]
		unless empty? attributes [
			append out join #" " form attributes
		]
		append out #">"
	]

	unless parse data bind rules/main-rule rules [
;		return make error! ajoin ["LEST: there was error in LEST dialect at: " mold pos]
		return ajoin ["LEST: there was error in LEST dialect at: " mold pos]
	]

	body: head buffer

	either header? [
		ajoin [
<!DOCTYPE html> newline
<html lang="en-US"> newline
	<head> newline
		<title> page/title </title> newline
		<meta charset="utf-8"> newline
		page/meta newline
		includes/stylesheets
		includes/header
	</head> newline
	<body data-spy="scroll" data-target=".navbar">	; WHAT AN UGLY HACK!!!
		includes/body-start
		body
		includes/body-end
	</body>
</html>
		]
	][
		body
	]
]


] ; --- end main context