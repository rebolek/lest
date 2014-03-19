REBOL[
	Title: "Google font plugin for LEST"
	Type: 'lest-plugin
	Name: 'google-font
	Todo: [
		"This needs manual addition of fonts to CSS file"
	]
]

rule: [
	'google-font
	set name string!
	(
		debug ["==GFONT:" name]
		; TODO: character sets
		repend includes/header [
			{<link href='http://fonts.googleapis.com/css?family=}
			replace/all name #" " #"+"
			{:400,300&subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
		]

	)
]