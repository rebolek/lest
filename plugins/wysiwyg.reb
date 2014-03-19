REBOL[
	Title: "Wysiwyg plugin for LEST"
	Type: 'lest-plugin
	Name: 'wysiwyg
	Todo: []
]

startup: [
	debug "==ENABLE WYSIWYG"
	emit-stylesheet css-path/bootstrap-wysihtml5.css

	emit-plugin js-path/wysihtml5-0.3.0.min.js
	emit-plugin js-path/bootstrap3-wysihtml5.js
	emit-plugin {$('.wysiwyg').wysihtml5();}
]

rule: [
	'wysiwyg (debug ["==WYSIWYG matched"])
	init-tag
	opt style
	(
		debug ["==WYSIWYG"]
		tag-name: 'textarea
		append tag/class 'wysiwyg
	)
	emit-tag
	end-tag
]