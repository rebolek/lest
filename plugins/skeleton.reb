REBOL[
	Title: "Skeleton plugin for LEST"
	Type: 'lest-plugin
	Name: 'skeleton
	Todo: [
	]
]

startup: [
	stylesheet css-path/skeleton.css
]

main: [
	container
|	row	
|	col

]


grid-elems: rule [type] [
	set type ['container | 'row]
	init-div
	opt style
	(insert tag/class type)
	emit-tag
	eval
	match-content
	end-tag
]

abs-col: rule [width] [
	set width ['one | 'two | 'three | 'four | 'five | 'six | 'seven | 'eight | 'nine | 'ten | 'eleven | 'twelve]
	['column | 'columns]
	init-div
	opt style
	(insert tag/class reduce [width 'column])
	emit-tag
	eval
	match-content
	end-tag	
]

rel-col: rule [width] [
	set width ['one-third | 'two-thirds | 'one-half]
	init-div
	opt style
	(insert tag/class reduce [width 'column])
	emit-tag
	eval
	match-content
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
		end-tag
	]
]
