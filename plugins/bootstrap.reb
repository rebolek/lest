REBOL[
	Title: "Bootstrap plugin for LEST"
	Type: 'lest-plugin
	Name: 'bootstrap
	Todo: []
]

startup: [
	stylesheet css-path/bootstrap.min.css 
	append script js-path/jquery-2.1.0.min.js 
	append script js-path/bootstrap.min.js 
]

rule: [
	grid-elems
|	col
|	bar
|	panel
|	glyphicon
|	address	
|	dropdown
|	carousel
|	modal
|	navbar
|	end
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
		ps: 
		(print ["col 0:" mold copy/part ps 16])
		'col
		(
			print "col 1"
			grid-size: 'md
			width: 2
			offset: none
		)
		init-div
		(print "col 2")
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

bar: [ 'bar (print "ahoj!")]

panel: [

; TODO NOTE: FOOTER is all wrong. Currently it's not added to the end of panel.
;	this would require marking position in the output and moving that position
;	for content/footer OR changng the rules so the panel's footer is _after_
;	the panel content. First posibilit is harder to write, but preferable.

	'panel
	(
		tag-name: 'div
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
		emit [
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
		emit [
			build-tag tag-name tag
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
		tag-name: 'div
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
	init-div
	( append tag/class 'modal-dialog )
	emit-tag
	init-div
	( append tag/class 'modal-content )
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
		emit [
			build-tag tag-name tag
			<button type="button" class="close" data-dismiss="modal" aria-hidden="true">
			&times;
			</button>
		]
	)
	into [ some elements ]
	end-tag
]
modal-body: [
	opt 'body
	init-div
	( append tag/class 'modal-body )
	emit-tag
	into [ some elements ]
	end-tag
]
modal-footer: [
	'header
	init-div
	( append tag/class 'modal-footer )
	emit-tag
	into [ some elements ]
	end-tag
]
