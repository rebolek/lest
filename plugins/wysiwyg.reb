REBOL[
	Title: "Wysiwyg plugin for LEST"
	Type: 'lest-plugin
	Name: 'wysiwyg
	Todo: []
]

startup: [
	stylesheet css-path/bootstrap-wysihtml5.css
	append plugin js-path/wysihtml5-0.3.0.min.js
	append plugin js-path/bootstrap3-wysihtml5.js
	append plugin {$('.wysiwyg').wysihtml5();}
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