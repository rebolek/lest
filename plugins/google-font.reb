REBOL[
	Title: "Google font plugin for LEST"
	Type: 'lest-plugin
	Name: 'google-font
	Todo: [
		"This needs manual addition of fonts to CSS file"
		"Different styles and sizes"
	]
]

startup: [
	stylesheet css-path/bootstrap.min.css 
]

main: [
	'google-font 
	set name string!
	(
		debug-print ["==GFONT:" name]
		; TODO: character sets
		repend includes/header [
			{<link href='http://fonts.googleapis.com/css?family=}
			replace/all name #" " #"+"
			{:400,300&amp;subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
		]
		repend includes/style ['google 'fonts name #400]
	)
]