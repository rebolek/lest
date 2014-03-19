REBOL[
	Title: "Lightbox plugin for LEST"
	Type: 'lest-plugin
	Name: 'lightbox
	Todo: [
		"This plugin requires bootstrap, it should be handled in header"
	]
]

startup: [
	debug "==ENABLE LIGHTBOX"
	emit-stylesheet css-path/bootstrap-lightbox.min.css
	emit-plugin js-path/bootstrap-lightbox.min.js
]