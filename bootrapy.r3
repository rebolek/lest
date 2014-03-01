REBOL[
	Title:		"BOOTRAPY - HTML/Bootstrap dialect"
	Author:		"Boleslav Brezovsky"
	Version:	0.0.2
	Date:		14-1-2013
	Started:	7-12-2013
	To-do: [
		"HTML entities"
		"Cleanup variables in emit-html"
		"Change header rules to emit to main data"
		{
get rid of EMIT-HTML in rules

currently used in:
	EMIT-PLUGIN (func)
	CAROUSEL, CAROUSEL-ITEM
	ENABLE: BOOTSTRAP, SMOOTH-SCROLLING, PRETTY-PHOTO, PASSWORD-STRENGTH

		}
	]
	Notes: [
		source: https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/HTML5/HTML5_element_list
		metadata:	[head title base link meta style]
		scripting:	[scipt noscript]
		sections:	[
			body section nav article aside
			h1 h2 h3 h4 h5 h6
			header footer address main
		]
		grouping:	[
			p hr pre blockquote
			ol ul li dl dt dd
			figure figcaption
			div
		]
		text:		[
			a
			em strong small s dite q dfn abbr
			data time code var samp kbd sub sup
			i b u mark ruby rt rp
			bdi bdo
			span
			br wbr
		]
		edits: [ins del]
		content: [
			img iframe embed object param
			video audio source track canvas
			map area svg math
		]
		tables: [
			table caption colgroup colgroup
			tbody thead tfoot
			tr td th
		]
		forms: [
			form fieldset legend label
			input button select datalist optgroup option
			textarea keygen output progress meter
		]
		interactive: [
			details summary menuitem menu
		]

{
See: http://dev.w3.org/html5/markup/common-models.html#common.elem.phrasing


Flow-elements: [
	phrasing elements  a  p  hr  pre  ul  ol  dl  div  h1  h2  h3  h4  h5  h6
	hgroup  address  blockquote  ins  del  object  map  noscript
	section  nav  article  aside  header  footer  video  audio
	figure  table  fm  fieldset  menu  canvas  details
]
Metadata-elements: [
	link  style  meta name
	meta http-equiv=refresh
	meta http-equiv=default-style
	meta charset
	meta http-equiv=content-type
	script  noscript  command
]
Phrasing-elements: [
	a  em  strong  small  mark  abbr  dfn
	i  b  s  u  code  var  samp  kbd  sup  sub
	q  cite  span  bdo  bdi  br  wbr  ins  del  img
	embed  object  iframe  map  area  script  noscript
	ruby  video  audio  input  textarea  select  button
	label  output  datalist  keygen  progress  command  canvas  time  meter
]

}
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

make-rule: func [
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


pair-tag: func [
	"Enclose value in tag"
	value
	type
][
	rejoin [
		""
		to tag! type
		value
		head insert to tag! type "/"
	]
]

close-tag: func [
	type
][
	rejoin ["</" type ">"]
]



; === parse fucntions

emit-html: funct [
	"Parse simple HTML dialect"
	data
	/with
		custom-rule
][
;	print "emit-html"
	; === variables

	stylesheets: copy {^/}
	styles:		copy []
	name:		copy ""
	value:		copy ""
	default:	copy ""
	size: 		50x4
	tag:		none
	type: 		none
	add-plugins: copy {}

	tag-stack: copy []
	user-rules: copy [ fail ]	; fail is "empty rule", because empty block isn't
	user-words: object []

	page: reduce/no-set [
		title: "Page generated with Bootrapy"
		meta: copy {}
	]

	output: copy ""
	buffer: copy ""
	form-buffer: copy ""

	header?: false

	; === actions

	emit: func [
		data [ string! block! tag! ]
	][
		if block? data	[ data: ajoin data ]
		if tag? data	[ data: mold data ]
		append buffer data ;join data newline
	]

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
				lib/form value
			]
			unless skip? [
				repend out [ " " to word! key {="} value {"} ]
			]
		]
		unless empty? attributes [
			append out join #" " lib/form attributes
		]
		append out #">"
	]

	emit-label: func [
		label
		elem
		/class
		styles
	][
		emit-tag context [ element: 'label for: elem class: styles ]
		emit join label close-tag 'label
	]

	emit-stylesheet: func [
		stylesheet
	][
		debug ".-emit-."
		if path? stylesheet [ stylesheet: get stylesheet ]
		debug ["EMIT SS:" stylesheet]
		repend stylesheets [{<link href="} stylesheet {" rel="stylesheet">} newline ]
	]

	emit-plugin: func [
		plugin
	][
		append add-plugins emit-html reduce [ 'script plugin ]
	]

;  _____    _    _   _        ______    _____
; |  __ \  | |  | | | |      |  ____|  / ____|
; | |__) | | |  | | | |      | |__    | (___
; |  _  /  | |  | | | |      |  __|    \___ \
; | | \ \  | |__| | | |____  | |____   ____) |
; |_|  \_\  \____/  |______| |______| |_____/
;

	; --- subrules

	import: [
		; LOAD AND EMIT FILE
		'import p: set value [ file! | url! ]
		( p/1: load value )
		:p into elements
	]

; NOTE: this works

;	parse [ ( [print "a"] ) ] [
;		[set value paren! (value result: to paren! first value) result]
;	]

	do-code: use [p] [
		[
			; DO PAREN! AND EMIT LAST VALUE
			p: set value paren!
			( p/1: append clear [] do value )
			:p into elements
		]
	]

	set-rule: [
		'set
		set label word!
		set value any-type!
		(
			repend user-words [to set-word! label value]
		)
	]

	user-rule: use [ name label type ] [
		[
			set name set-word!
			(
				parameters: copy [ ]
				add-rule user-rules reduce [
					to set-word! 'pos
					to lit-word! name
				]
			)
			any [
				set label word!
				set type word!
				(
					add-rule parameters reduce [ 'change to lit-word! label label ]
					repend last user-rules [ 'set label to set-word! 'pos type ]
				)
			]
			set value block!
			(
				append last user-rules reduce [
					to paren! compose/only [
						; TODO: move rule outside
						rule: (compose [
							any-string!
						|	into [ some rule ]
						|	(parameters)
						|	skip
						])
						parse temp: copy/deep (value) [ some rule ]
						change/only pos temp
					]
					to get-word! 'pos 'into [some elements]
				]
			)
		]
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
			:pos into [some elements]
		|	'with
			pos: set data block!
			(
				out: make block! length? data
				; replace <filename> with [ rejoin [ %img/image- index %.jpg ] ]
				lib/repeat index cols [
					current: probe copy/deep element
					replace-deep current value probe do bind data 'index
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				]
				change/only pos compose/deep [ row [ (out) ] ]
			)
			:pos into [some elements]
		]

	]

	; FIXME

	repeat: [
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
					emit emit-html compose/deep [ row [ (out) ] ]
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
			value:		none
			default:	copy ""
			target:		none
			insert tag-stack tag: context [ id: none class: copy [] element: name ]
		)
	]

	take-tag: [ ( tag: take tag-stack ) ]

	emit-tag: [ ( debug ["emit:" tag/element] emit make-tag tag ) ]

	end-tag: [
		take-tag
		( emit close-tag tag/element )
	]

	init-div: [
		( name: 'div )
		init-tag
	]

	close-div: [
		(
			tag: take tag-stack
			emit </div>
		)
	]

	style: use [ word continue ] [
		[
			any [
				set word issue! ( tag/id: next lib/form word )
			|	[
					pos: set word word!
					(
						continue: either #"." = take lib/form word [
							append tag/class next lib/form word
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

	]

	comment: [
		'comment [ block! | string! ]
	]

	debug-rule: use [ value ] [
		[
			'debug set value string!
			( print ["DEBUG:" value])
		]
	]

	script: [
		opt ['append ( append?: true )]
		'script
		init-tag
		set value [ string! | file! | url! | path! ]
		(
			if path? value [ value: get value ]
			value: rejoin either string? value [
				["" <script type="text/javascript"> value ]
			] [
				[{<script src="} value {">} ]
			]
			append value close-tag 'script
			either append? [ append add-plugins value ] [ emit value ]
		)
	]

	; --- header
	; TODO: remove custom rules from header (script, style...)
	; TODO: better META
	; TODO: use EMIT

	page-header: [
		'head (debug "==HEAD")
		(header?: true)
		some [
			'title set value string! (page/title: value debug "==TITLE")
		|	'stylesheet set value [ file! | url! | path! ] (
				if path? value [ value: get value ]
				emit-stylesheet value
				debug ["==STYLESHEET:" value]
			)
		|	'style set value string! (
				repend stylesheets ["" <style> value </style> newline ]
			)
		|	'script [
				set value [ file! | url! ] (
					repend stylesheets [{<script src="} value {">}</script> newline ]
				)
			|	set value string! (
					repend stylesheets ["" <script> value </script> newline ]
				)
			]
		|	'meta set name word! set value string! (
				repend page/meta [ {<meta name="} name {" content="} value {">}]
			)
		|	google-font
		|	enable
		|	ga
		]
		'body (debug "==BODY")

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

	match-content: [
		basic-string		; must match string! first, or INTO will eat it!
	|	into [ some elements ]
	]

	paired-tags: [ 'i | 'b | 'p | 'div | 'span | 'small | 'em | 'strong | 'footer | 'nav | 'section | 'button ]
	paired-tag: [
		set name paired-tags
		init-tag
		opt style
		emit-tag
		match-content
		end-tag
	]

	image: [
		['img | 'image]
		(
			debug "==IMAGE"
			name: 'img
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
	link: [
		['a | 'link] ( name: 'a )
		init-tag
		some [
			set value [ file! | url! | issue! ]
			( append tag compose [ href: (value) ] )
		|	style
		]
		emit-tag
		match-content
		end-tag
	]

	; lists - UL, OL, LI, DL

	li: [
		set name 'li
		init-tag
		opt style
		emit-tag
		match-content
		end-tag
	]

	ul: [
		set name 'ul
		init-tag
		opt style
		emit-tag
		some li
		end-tag
	]

	ol: [
		set name 'ol
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
		set name 'dl
		init-tag
		opt [
			'horizontal ( append tag/class 'dl-horizontal )
		|	style
		]
		emit-tag
		some [
			set value string!
			( emit ajoin [ <dt> value </dt> ] )
			set value string!
			( emit ajoin [ <dd> value </dd> ] )
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

	basic-string: [
		set value string!
		( emit value )
	]

	stop: [
		'stop
		to end
	]

	; --- headings
	; TODO: headings can contain Phrasing elements (see HEADER/NOTE)
	heading: [
		set name [ 'h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6 ]
		init-tag
		opt style
		emit-tag
		match-content
		end-tag
	]

	; table

	table: [
		set name 'table
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

	init-input: [
		(
			name: 'input
			default: none
		)
		init-tag
		( tag: first tag-stack )
	]
	emit-input: [
		(
			switch/default form-type [
				horizontal [
					unless empty? label [
						emit-label/class label name	[col-sm-2 control-label]
					]
					emit <div class="col-sm-10">
					tag: take tag-stack
					append tag compose [ type: (type) name: (name) placeholder: (default) value: (value) ]
					emit make-tag tag
					emit </div>
				]
			][
				unless empty? label [
					emit-label label name
				]
				tag: take tag-stack
				append tag compose [ type: (type) name: (name) placeholder: (default) value: (value) ]
				emit make-tag tag
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
	input: [
		set type [
			'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
		|	'number | 'email | 'url | 'search | 'tel | 'color
		]
		( emit <div class="form-group"> )
		init-input
		( append tag/class 'form-control )
		input-parameters
		emit-input
		( emit </div> )
	]
	checkbox: [
		set type 'checkbox
		( emit [ "" <div class="checkbox"> <label> ] )
		init-input
		input-parameters
		take-tag
		(
			append tag compose [ type: (type) name: (name) ]
			emit [ make-tag tag label </label> </div> ]
		)
	]
	radio: [
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
		set name 'textarea
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
			emit make-tag tag
			emit value
			emit close-tag tag/element
		)
	]
	hidden: [
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
	submit: [
		'submit
		(
			insert tag-stack tag: context [
				element:	'button
				type:		'submit
				id:			none
				class: copy [btn btn-default]
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
					emit <div class="form-group">
					emit <div class="col-sm-offset-2 col-sm-10">
					emit make-tag tag
					emit [ label </button> </div> </div> ]

				]
			][
				emit make-tag tag
				emit [ label </button> ]
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
		|	captcha
		|	password-strength
		]
	]
	form-type: none
	form: [
		set name 'form
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
;				role:	'form
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
		into [ some elements ]
		( emit close-tag 'form )
	]

	; --- put it all together

	elements: [
		pos: (debug ["parse at: " index? pos "::" mold first pos] set 'p pos)
		[
			set value string! ( emit value )
		|	page-header
		|	basic-elems
		|	form-content
		|	import
		|	do-code
		|	repeat
		|	make-row
		|	user-rules
		|	user-rule
		|	set-rule
		|	heading
		|	form
		|	script
		|	bootstrap-elems
		|	plugins
		]
		(
			; cleanup buffer
			value: none
		)
	]

;
;  ____     ____     ____    _______    _____   _______   _____               _____
; |  _ \   / __ \   / __ \  |__   __|  / ____| |__   __| |  __ \      /\     |  __ \
; | |_) | | |  | | | |  | |    | |    | (___      | |    | |__) |    /  \    | |__) |
; |  _ <  | |  | | | |  | |    | |     \___ \     | |    |  _  /    / /\ \   |  ___/
; | |_) | | |__| | | |__| |    | |     ____) |    | |    | | \ \   / ____ \  | |
; |____/   \____/   \____/     |_|    |_____/     |_|    |_|  \_\ /_/    \_\ |_|
;


	bootstrap-elems: [
		grid-elems
	|	col
	|	bar
	|	panel
	|	glyphicon
	|	dropdown
	|	carousel
	|	modal
	|	address
	|	navbar
	]

	grid-elems: [
		set type [ 'row | 'container ]
		init-div
		opt style
		( insert tag/class type	)
		emit-tag
		into [ some elements ]
		close-div
	]

	col: use [ grid-size width offset ] [
		[
			'col
			(
				grid-size: 'md
				width: 2
				offset: none
			)
			init-div
			some [
				'offset set offset integer!
			|	set grid-size [ 'xs | 'sm | 'md | 'lg ]
			|	set width integer!
			]
			opt style
			(
				append tag/class rejoin [ "col-" grid-size "-" width ]
				if offset [
					append tag/class rejoin [ "col-" grid-size "-offset-" offset ]
				]
			)
			emit-tag
			into [ some elements ]
			close-div
		]
	]

	bar: [
		'bar
	]

	panel: [

; TODO NOTE: FOOTER is all wrong. Currently it's not added to the end of panel.
;	this would require marking position in the output and moving that position
;	for content/footer OR changng the rules so the panel's footer is _after_
;	the panel content. First posibilit is harder to write, but preferable.

		'panel
		(
			name: 'div
			panel-type: 'default
		)
		init-tag
		opt [
			[ not ['heading | 'footer] ]
			and
			[set panel-type word!]
			skip
		]
		(
			repend tag/class [
				'panel
				to word! join 'panel- panel-type
			]
		)
		emit-tag
		any [
			[
				'heading
				init-div
				( append tag/class 'panel-heading )
				emit-tag
				[
					set value string!
					( emit ajoin [<h3 class="panel-title"> value </h3>] )
				|	into [ some elements ]
				]
				end-tag
			]
		|	[
				'footer
				init-div
				( append tag/class 'panel-footer )
				emit-tag
				into [ some elements ]
				end-tag
			]
		]
		into [ some elements ]
		end-tag

	]

	glyphicon: [
		'glyphicon
		set name word!
		(
			debug ["==GLYPHICON: " name]
			emit rejoin [ {<span class="glyphicon glyphicon-} name {"></span>} ]
		)
	]

	address: [
		'address
		(
			emit <address>
			first-line?: true
		)
		into [
			some [
				set value string! (
					emit rejoin either first-line? [
						first-line?: false
						[ "" <strong> value </strong> <br> ]
					] [
						[ value <br> ]
					]
				)
			|	'email set value string! (
					emit rejoin [{<a href="mailto:} value {">} value </a> <br> ]
				)
			|	'phone set value string! (
					; TODO: hardcoded localization
					emit rejoin ["" <abbr title="Telefon"> "Tel: " </abbr> value <br>]
				)
			]
		]
		( emit </address> )
	]

	navbar: [
		'navbar
		init-div
		(
			append tag/class [navbar navbar-fixed-top navtext]
			append tag [ role: navigation ]
		)
		some [
			'inverse ( append tag/class 'navbar-inverse )
		|	style
		]
		emit-tag
		( emit [
			<div class="container">
			<div class="navbar-collapse collapse">
			<ul id="page-nav" class="nav navbar-nav">
		] )
		; TODO: add divider
		into [
			some [
				'link ( active?: false )
				opt [ 'active ( active?: true ) ]
				set target [ file! | url! | issue! ]
				set value string!
				( emit ajoin [
					{<li}
					either active? [ { class="active">}] [ #">" ]
					{<a href="} target {">} value
					</a>
					</li>
				] )
			]
		]
		( emit [ </ul></div></div> ] )
		end-tag
	]

	carousel: [
		;
		;
		;	There are three types of CAROUSEL INDICATORS:
		;	1. default (CAROUSE name [...carousel items...]) - dafult indicators that can be styled using CSS
		;	2. custom (CAROUSEL name INDICATORS [...indicators...] [...carousel items...]) -
		;		replace default indicators
		;	3. no indicators (CAROUSEL name NO INDICATORS [...carousel items...]) -
		;		do not add indicators to carousel - controls can be outside of carousel
		;
		;
		'carousel
		init-tag
		(
			debug "==CAROUSEL"
			append tag compose [
				element: div
				inner-html: ( copy {} )
				items: 0
				active: 0
				data-ride: carousel
				class: [ carousel slide ]
			]
			carousel-menu: none
		)
		set name word!
		( tag/id: name )
		any [
			style
		|	'no 'indicators	( carousel-menu: false )
		|	'indicators set carousel-menu block!
		]
		into [ some carousel-item ]
		take-tag
		(
			if none? carousel-menu [
				; create default carousel indicators
				carousel-menu: copy [ ol #carousel-indicators ]
				; NOTE: REPEAT was redefined with rule of same name, so we use original from LIB context
				lib/repeat i tag/items [
					append carousel-menu reduce [
						'li 'with compose [
							data-target: ( to issue! tag/id )
							data-slide-to: ( i - 1 )
							( either i = tag/active [ [ class: active ] ] [] )
						]
						""
					]
				]
			]
			data: tag/inner-html
			tag/items:
			tag/active:
			tag/inner-html: none
			emit [
				make-tag tag
				either carousel-menu [
					;default or custom indicators
					emit-html carousel-menu
				][
					; no indicators
					""
				]
				<div class="carousel-inner">
				data
				</div>
				emit-html compose [
					a ( to file! to issue! tag/id ) #left #carousel-control with [ data-slide: prev ] [ glyphicon chevron-left ]
					a ( to file! to issue! tag/id ) #right #carousel-control with [ data-slide: next ] [ glyphicon chevron-right ]
				]
				close-tag 'div
			]
		)
	]

	carousel-item: [
		'item
		( active?: false )
		opt [
			'active
			( active?: true )
		]
		set data block!
		(
			append tag/inner-html rejoin [
				{<div class="item}
				either active? [ " active" ] [ "" ]
				{">}
				emit-html data
				</div>
			]
			tag/items: tag/items + 1
			if active? [ tag/active: tag/items ]
		)
	]

	dropdown: [
		'dropdown
		init-div
		copy label string!
		(
			tag/class: [ btn-group ]
			emit [
				make-tag tag
				<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
				label
				<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
			]
		)
		some [
			menu-item
		|	menu-divider
		]
		( emit close-tag 'ul )
		close-div
	]
	menu-item: [
		set label string!
		set target [ file! | url! ]
		( emit [ {<li><a href="} target {">} label {</a></li>} ] )
	]
	menu-divider: [
		'divider
		( emit [ "" <li class="divider"></li> ] )
	]

	modal: [
		'modal
		init-tag
		( label: 'modal-label )
		set name word!
		opt [ 'label set label word! ]
		(
			debug "==MODAL"
			tag/element: 'div
			tag/id: name
			append tag/class [ modal fade ]
			append tag [
				tabindex: -1
				role: dialog
				aria-labelledby: label
				aria-hidden: true
			]
		)
		emit-tag
		init-tag
		(
			tag/element: 'div
			append tag/class 'modal-dialog
		)
		emit-tag
		init-tag
		(
			tag/element: 'div
			append tag/class 'modal-content
		)
		emit-tag
		opt modal-header
		modal-body
		opt modal-footer
		end-tag	; modal-content
		end-tag	; modal-dialog
		end-tag	; modal
	]
	modal-header: [
		'header
		init-tag
		(
			tag/element: 'div
			append tag/class 'modal-header
			emit make-tag tag
			emit {<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>}
		)
		into [ some elements ]
		end-tag
	]
	modal-body: [
		opt 'body
		init-tag
		(
			tag/element: 'div
			append tag/class 'modal-body
		)
		emit-tag
		into [ some elements ]
		end-tag
	]
	modal-footer: [
		'header
		init-tag
		(
			tag/element: 'div
			append tag/class 'modal-footer
		)
		emit-tag
		into [ some elements ]
		end-tag
	]

;  _____    _        _    _    _____   _____   _   _    _____
; |  __ \  | |      | |  | |  / ____| |_   _| | \ | |  / ____|
; | |__) | | |      | |  | | | |  __    | |   |  \| | | (___
; |  ___/  | |      | |  | | | | |_ |   | |   | . ` |  \___ \
; | |      | |____  | |__| | | |__| |  _| |_  | |\  |  ____) |
; |_|      |______|  \____/   \_____| |_____| |_| \_| |_____/
;

	captcha: [
		'captcha set value string! (
			emit reword {
<script type="text/javascript" src="http://www.google.com/recaptcha/api/challenge?k=$public-key"></script>
<noscript>
	<iframe src="http://www.google.com/recaptcha/api/noscript?k=$public-key" height="300" width="500" frameborder="0"></iframe>
	<br>
	<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
	<input type="hidden" name="recaptcha_response_field" value="manual_challenge">
</noscript>
} reduce [ 'public-key value ]
		)
	]
	ga: [
		; google analytics
		'ga
		set value word!
		set web word!
		(
			debug ["==GOOGLE ANALYTICS:" value web]
			append add-plugins reword {
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '$value', '$web');
  ga('send', 'pageview');

</script>
} [
	'value value
	'web web
]
		)
	]

	map: [
		; google maps

;
; TODO: worked, now does not. Probably needs some requirements.
;
; currently uses iframe method (but that's not dynamic)
		'map
		set location pair!
		(
;			emit rejoin [ ""
;   				<div id="contact" class="map"> newline
;   					<div id="map_canvas"></div> newline
;   				</div> newline
;   				<script>
;   				{google.maps.event.addDomListener(window, 'load', setMapPosition(} location/x #"," location/y {));}
;   				</script>
;    		]
			emit ajoin [
{<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=cs&amp;geocode=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;z=14&amp;ll=} location/x #"," location/y {&amp;output=embed">}
</iframe><br /><small>
{<a href="https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=cs&amp;geocode=&amp;aq=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;hnear=Mez%C3%ADrka,+Brno,+%C4%8Cesk%C3%A1+republika&amp;z=14&amp;ll=} location/x #"," location/y {" style="color:#0000FF;text-align:left">Zvětšit mapu}
</a></small>
			]


		)
	]

	google-font: [
		'google-font
		set name string!
		(
			debug ["==GFONT:" name]
			; TODO: character sets
			repend stylesheets [
				{<link href='http://fonts.googleapis.com/css?family=}
				replace/all name #" " #"+"
				{:400,300&subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
			]

		)
	]

	fa-icon: [
		; TODO: add link for font awesome CSS to header
		'fa-icon
		init-tag
		(
			name: none
			fixed?: ""
		)
		[
			'stack set name block!
		|	set name word!
		]
		(debug ["==FA-ICON:" name])
		any [
			set size integer!
		|	'fixed ( fixed?: " fa-fw" )
		; TODO: Add ROTATE and FLIP support
		|	'rotate set value integer!
		|	'flip set value [ 'horizontal | 'vertical ]
		|	style
		]
		take-tag
		(
			size-att: case [
				size = 1 	( { fa-lg} )
				size 		( rejoin [ { fa-} size {x}] )
				true 		( {} )
			]
			either word? name [
				; single icon
				emit rejoin [ {<i class="fa fa-} name size-att fixed? " " tag/class {"></i>} ]
			][
				; stacked icons
				; TODO: support size for stacked icons
				emit rejoin [
					""
					<span class="fa-stack fa-lg">
					  {<i class="fa fa-} first name { fa-stack-2x} fixed? {">}</i>
					  {<i class="fa fa-} second name { fa-stack-1x fa-inverse } fixed? catenate tag/class " " {">}</i>
					</span>
				]
			]

		)
	]

	password-strength: [
		;
		; https://github.com/ablanco/jquery.pwstrength.bootstrap
		;
		; USAGE:
		;
		; password-strength
		; password-strength username user
		; password-strength username user verdicts ["Slabé" "Normální" "Středně silné" "Silné" "Velmi silné"]
		;
		'password-strength
		(
			verdicts: ["Weak" "Normal" "Medium" "Strong" "Very Strong"]
			too-short: "<font color='red'>The Password is too short</font>"
			same-as-user: "Your password cannot be the same as your username"
			username: "username"
		)
		any [
			'username
			set username word!
		|	'verdicts
			set verdicts block!
		|	'too-short
			set too-short string!
		|	'same-as-user
			set same-as-user string!
		]
		(
			append add-plugins trim/lines reword
{<script type="text/javascript">
	jQuery(document).ready(function () {
		"use strict";
		var options = {
			minChar: 8,
			bootstrap3: true,
			errorMessages: {
			    password_too_short: "$too-short",
			    same_as_username: "$same-as-user"
			},
			scores: [17, 26, 40, 50],
			verdicts: [$verdicts],
			showVerdicts: true,
			showVerdictsInitially: false,
			raisePower: 1.4,
			usernameField: "#$username",
		};
		$(':password').pwstrength(options);
	});
</script>}
			compose [
				verdicts		(catenate/as-is verdicts ", ")
				too-short		(too-short)
				same-as-user	(same-as-user)
				username		(username)
			]
		)
	]

	wysiwyg: [
		'wysiwyg (debug ["==WYSIWYG matched"])
		init-tag
		opt style
		(
			debug ["==WYSIWYG"]
			tag/element: 'textarea
			append tag/class 'wysiwyg
		)
		emit-tag
		end-tag
	]

	enable: [
		'enable (debug "==ENABLE") [
			'bootstrap (
				debug "==ENABLE BOOTSTRAP"
				emit-stylesheet css-path/bootstrap.min.css
				append add-plugins emit-html [
					script js-path/jquery-1.10.2.min.js
					script js-path/bootstrap.min.js
				]
			)
		|	'smooth-scrolling (
				debug "==ENABLE SMOOTH SCROLLING"
				; TODO: this expect all controls to be part of UL with ID #page-nav
				; make more generic, but do not break another anchors!!!
				append add-plugins emit-html [
					script {
					  $(function() {
					    $('ul#page-nav > li > a[href*=#]:not([href=#])').click(function() {
					      if (location.pathname.replace(/^^\//,'') == this.pathname.replace(/^^\//,'') && location.hostname == this.hostname) {

					        var target = $(this.hash);
					        var navHeight = $("#page-nav").height();

					        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
					        if (target.length) {
					          $('html,body').animate({
					            scrollTop: target.offset().top - navHeight
					          }, 1000);
					          return false;
					        }
					      }
					    });
					  });
					}
				]
			)
		|	'pretty-photo (
				debug "==ENABLE PRETTY PHOTO"
				append add-plugins emit-html [
					script js-path/jquery.prettyPhoto.js
					script {
					  $(document).ready(function(){
					    $("a[rel^='prettyPhoto']").prettyPhoto();
					  });
					}
				]
			)
		|	'password-strength (
				debug "==ENABLE PASSWORD STRENGTH"
				debug js-path
				append add-plugins emit-html [
					script js-path/pwstrength.js
				]
			)
		|	'wysiwyg (
				debug "==ENABLE WYSIWYG"
				emit-stylesheet css-path/bootstrap-wysihtml5.css

				emit-plugin js-path/wysihtml5-0.3.0.min.js
				emit-plugin js-path/bootstrap3-wysihtml5.js
				emit-plugin {$('.wysiwyg').wysihtml5();}
			)
		|	'lightbox (
				debug "==ENABLE LIGHTBOX"
				emit-stylesheet css-path/bootstrap-lightbox.min.css
				emit-plugin js-path/bootstrap-lightbox.min.js
			)
		|	'font-awesome (
				debug "==ENABLE FONT AWESOME"
				emit-stylesheet css-path/font-awesome.min.css
			)
		]
	]

	plugins: [
		ga 					; GOOGLE ANALYTICS
	|	map 				; GOOGLE MAP (TODO: more engines?)
	|	google-font			; GOOGLE FONT
	|	fa-icon				; FONT AWESOME ICON - http://fontawesome.io/icons/
	|	password-strength	; PASSWORD STRENGTH - bootstrap/jquery plugin
	|	wysiwyg 			; WYSIWYG EDITOR - https://github.com/mindmup/bootstrap-wysiwyg/
	|	enable
	]



;  __  __              _____   _   _
; |  \/  |     /\     |_   _| | \ | |
; | \  / |    /  \      | |   |  \| |
; | |\/| |   / /\ \     | |   | . ` |
; | |  | |  / ____ \   _| |_  | |\  |
; |_|  |_| /_/    \_\ |_____| |_| \_|
;


	main-rule: either with [
		bind custom-rule 'value
	] [
		[
;			opt page-header
			some elements
		]
	]

	unless parse data main-rule [
		return none!
	]

	body: head buffer

	debug ["Stylesheets: " mold stylesheets ]

	either header? [
		rejoin [ ""
<!DOCTYPE html> newline
<html lang="en-US"> newline
	<head> newline
		<title> page/title </title> newline
		<meta charset="utf-8"> newline
		page/meta newline
		stylesheets
	</head> newline
	<body data-spy="scroll" data-target=".navbar">	; WHAT AN UGLY HACK!!!
		body
		add-plugins
	</body>
</html>
		]
	][
		body
	]
]
