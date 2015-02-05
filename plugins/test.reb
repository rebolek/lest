REBOL[
	Title: "Test plugin for LEST"
	Type: 'lest-plugin
	Name: 'test
	Todo: []
]

startup: [
	stylesheet css-path/bootstrap.min.css 
	append script js-path/jquery-2.1.0.min.js 
	append script js-path/bootstrap.min.js 
]

rule: [

		set type 'crow
		c
		opt style
		emit-tag
;		into [ some elements ]
		close-div
	
]

c: [init-div]