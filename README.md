bootrapy
========

A lightweight templating Rebol dialect with support for Bootstrap and JQuery.

Example code:

	head

	enable bootstrap
	enable smooth-scrolling
	stylesheet css-path/bootrapy.css
	google-font "Exo 2"
	title "Hello world!"
	
	body
	
	navbar inverse [
		link active #basics "BASICS"
		link #code "DYNAMIC CODE"
		link #bootstrap "BOOTSTRAP SUPPORT"
		link #plugins "PLUGINS"
	]
	
	h1 #basics "Basic style support"
	span "This is span."
	div .my-style .my-other-style [
	    div "Div in div"
	]
	  
	h2 "Why bootrapy?"
	ul
	li "fast"
	li "small"
	li "easy"
	
	h1 #code "Dynamic page creation"
	
	( either now/time < 12:00 "Good morning!" "Good afternoon" )
	  
	my-custom-style: value string! [b [i value]]
	my-custom-style "Hello world!"
	
	h1 #bootstrap "Bootstrap support"
	
	container [
		row #bootstrap [
			col offset 3 3 [ "Grid support" ]
			col 3 [ "Glyphicons:" glyphicon heart ] 
			col 3 [ "Carousel, dropdown, modal..." ]
		]
	]
	  
	h1 #plugins "Plugins"
	  
	p {Bootrapy supports different plugins:}
	  
	ul
	li "Google fonts"
	li "Google maps"
	li "Google analytics"
	li "Font Awesome glyphs"
	li "Captcha, etc..."
	
	footer [ "more later" ]
