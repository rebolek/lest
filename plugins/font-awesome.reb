REBOL[
	Title: "Font Awesome plugin for LEST"
	Type: 'lest-plugin
	Name: 'font-awesome
	Todo: [
		"remove last space in CLASS"
	]
]

startup: [
	stylesheet css-path/font-awesome.min.css
]

main-rule: use [tag name fixed? size value size-att] [
	[
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
		(debug-print ["==FA-ICON:" name])
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
			; FIXME: tag should be bound by now
			tag: rules/tag
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
]
