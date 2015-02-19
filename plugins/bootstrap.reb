REBOL[
	Title: "Bootstrap plugin for LEST"
	Type: 'lest-plugin
	Name: 'bootstrap
	Todo: [
		"FEAT: button"
	]
]

startup: [
	stylesheet css-path/bootstrap.min.css 
	insert script js-path/jquery-2.1.3.min.js 
	insert script js-path/bootstrap.min.js 
	insert script js-path/validator.min.js 
	meta viewport "width=device-width, initial-scale=1"
	meta http-equiv: X-UA-Compatible "IE=edge"
]

main: [
	grid-elems
|	col
|	bar
|	make-row
|	panel
|	glyphicon
|	address	
|	dropdown
|	carousel
|	modal
|	navbar
|	link-list-group
|	end
]

grid-elems: [
	set type [ 'row | 'container ]
	opt ['fluid (type: 'container-fluid)]
	init-div
	opt style
	( insert tag/class type	)
	emit-tag
;	into [ some elements ]
	eval
	match-content
;	close-div
	end-tag
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
		eval  match-content
		close-div
	]
]

bar: ['bar]

panel: [

; TODO NOTE: FOOTER is all wrong. Currently it's not added to the end of panel.
;	this would require marking position in the output and moving that position
;	for content/footer OR changing the rules so the panel's footer is _after_
;	the panel content. First posibility is harder to write, but preferable.

	'panel
	(
		tag-name: 'div
		panel-type: 'default
	)
	init-tag
	opt [
		[not ['heading | 'footer]]
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
				(value-to-emit: ajoin [<h3 class="panel-title"> value </h3>])
				emit-value
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
	init-div
	(append tag/class 'panel-body)
	emit-tag
;	into [some elements]
	match-content
	end-tag	;/panel-body
	end-tag	;/panel
]

glyphicon: [
	'glyphicon
	set name word!
	(tag-name: 'span)
	init-tag
	(
		debug-print ["==GLYPHICON: " name]
		repend tag/class ['glyphicon join 'glyphicon- name]
	)
	emit-tag
	end-tag
]

address: [
	'address
	(
		value-to-emit: <address>
		first-line?: true
	)
	emit-value
	into [
		some [
			set value string! (
				value-to-emit: rejoin either first-line? [
					first-line?: false
					[ "" <strong> value </strong> <br> ]
				] [
					[ value <br> ]
				]
			)
			emit-value
		|	'email set value string! (
				value-to-emit: rejoin [{<a href="mailto:} value {">} value </a> <br> ]
			)
			emit-value
		|	'phone set value string! (
				; TODO: hardcoded localization
				value-to-emit: rejoin ["" <abbr title="Telefon"> "Tel: " </abbr> value <br>]
			)
			emit-value
		]
	]
	( value-to-emit: </address> )
	emit-value
]

navbar: [
	'navbar
	init-div
	(
		append tag/class [navbar navbar-default navbar-fixed-top]
		append tag [ role: navigation ]
	)
	any [
		'inverse ( append tag/class 'navbar-inverse )
	|	style
	]
	emit-tag
	(value-to-emit: [<div class="container-fluid">] )
	emit-value
	; TODO: add divider
	opt navbar-brand
	(
		value-to-emit: [
			<div class="navbar-collapse collapse" id="page-nav">	; TODO: ID shouln't be hardcoded
			<ul class="nav navbar-nav">
		]
	)
	emit-value
	[some navbar-content | into some navbar-content]
	( value-to-emit: [ </ul> ] )
	emit-value
	opt [
		'right
		(value-to-emit: [<ul class="nav navbar-nav navbar-right">])
		emit-value
		[some navbar-content | into some navbar-content]
		( value-to-emit: [ </ul> ] )
		emit-value
	]
	(value-to-emit: [</div></div>])
	emit-value
	end-tag
]

navbar-brand: [
	'brand
	set value string!
	(
		value-to-emit:  ajoin [
			<div class="navbar-header">
		      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#page-nav"> ; TODO: ID shouln't be hardcoded (see above)
		        <span class="sr-only"> "Toggle navigation" </span>
		        <span class="icon-bar"></span>
		        <span class="icon-bar"></span>
		        <span class="icon-bar"></span>
		      </button>
		      <a class="navbar-brand" href="#"> value </a>
		    </div>
		]
	)
	emit-value
]

navbar-link: [
	'link 
	(active?: false)
	(tag-name: 'li)
	init-tag
	opt ['active ( active?: true)]
	some [
		set target [ file! | url! | issue! ]
	|	set value [string! | block!]
	|	style
	]
	(if active? [append tag/class 'active])
	emit-tag
	pos:
	(
		pos: back pos
		pos/1: reduce ['link target value]
	)
	:pos
	into [elements]
	end-tag
]

navbar-content: [
	opt commands
	opt [navbar-link | form-rule]
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
		debug-print "==CAROUSEL"
		tag-name: 'div
		append tag compose [
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
			repeat i tag/items [
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
		value-to-emit: [
			build-tag tag-name tag
			either carousel-menu [
				;default or custom indicators
				lest carousel-menu
			][
				; no indicators
				""
			]
			<div class="carousel-inner">
			data
			</div>
			lest compose [
				a ( to file! to issue! tag/id ) #left #carousel-control with [ data-slide: prev ] [ glyphicon chevron-left ]
				a ( to file! to issue! tag/id ) #right #carousel-control with [ data-slide: next ] [ glyphicon chevron-right ]
			]
			close-tag 'div
		]
	)
	emit-value
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
			lest data
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
		value-to-emit: [
			build-tag tag-name tag
			<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
			label
			<span class="caret"></span>
			</button>
			<ul class="dropdown-menu" role="menu">
		]
	)
	emit-value
	some [
		menu-item
	|	menu-divider
	]
	( value-to-emit: close-tag 'ul )
	emit-value
	close-div
]
menu-item: [
	set label string!
	set target [ file! | url! ]
	( value-to-emit: [ {<li><a href="} target {">} label {</a></li>} ] )
	emit-value
]
menu-divider: [
	'divider
	( value-to-emit: [ "" <li class="divider"></li> ] )
	emit-value
]

modal: [
	'modal
	init-tag
	( label: 'modal-label )
	set name word!
	opt ['label set label word!]
	(
		debug-print "==MODAL"
		tag-name: 'div
		tag/id: name
		append tag/class [modal fade]
		append tag [
			tabindex: -1
			role: dialog
			aria-labelledby: label
			aria-hidden: true
		]
	)
	emit-tag
	init-div
	(append tag/class 'modal-dialog)
	emit-tag
	init-div
	(append tag/class 'modal-content)
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
	init-div
	(
		append tag/class 'modal-header
		value-to-emit: [
			build-tag tag-name tag
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">
			"&times;"
			</button>
		]
	)
	emit-value
	into [ some elements ]
	end-tag
]
modal-body: [
	opt 'body
	init-div
	(append tag/class 'modal-body)
	emit-tag
	into [ some elements ]
	end-tag
]
modal-footer: [
	'header
	init-div
	(append tag/class 'modal-footer)
	emit-tag
	into [ some elements ]
	end-tag
]

list-badge: [
	'badge
	(tag-name: 'span)
	init-tag
	(append tag/class 'badge)
	emit-tag
	content-rule
	end-tag
]

link-list-group: [
	'link-list
	init-div
	(append tag/class 'list-group)
	emit-tag
	any [
		'link
		(tag-name: 'a)
		init-tag
		(append tag/class 'list-group-item)
		opt ['active (append tag/class 'active)]
		eval
		set value [ file! | url! | issue! ]
		(append tag compose [href: (value)])
		emit-tag
		eval
		match-content
		opt list-badge
		end-tag
	]
	end-tag	
]

old-link-list-group: [
	'link-list
	init-div
	(append tag/class 'list-group)
	emit-tag
	any [
		'link ; link is read and overwritten with basic lest link
		opt [
			'active
			pos:
			(
				remove back pos
				insert pos '.active
				pos: back pos
			)
			:pos
		]
		pos:
		(
			probe pos
			insert next pos '.list-group-item
			pos: probe back pos
		)
		:pos
		link 	; run basic LINK rule
		opt list-badge
	]
	end-tag
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
