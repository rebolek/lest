REBOL[
	Title: "Lightbox plugin for LEST"
	Type: 'lest-plugin
	Name: 'lightbox
	Todo: [
		"This plugin requires bootstrap, it should be handled in header"
		"insert or append script?"
	]
]

startup: [
	stylesheet css-path/bootstrap-lightbox.min.css
	insert script js-path/bootstrap-lightbox.min.js
]