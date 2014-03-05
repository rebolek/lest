bootrapy
========

Bootrapy is a template engine with extremly low entropy. It removes unnecessary
visual noise as `<`and `>` or end tags. Instead it uses efficient and rich
Rebol syntax to describe the document. Bootrapy is optimized for Bootstrap
with direct support for its components, but not limited to. Custom rules can
be added directly in Bootrapy documents to support other toolkits or write
a custom one.

# Overview

Bootrapy describes HTML document in clutter-free way that is then translated
to the mess that rules the world. See some examples *(Bootrapy source is
prefixed with `>>` and HTML output with `==`):*

	>> emit-html [div "Hello World"]
	== <div>Hello World</div>

	>> emit-html [div #example "Hello World"]
	== <div id="example">Hello World"</div>

	>> emit-html [div #example .big .outline "Hello World"]
	== <div id="example" class="big outline">Hello World"</div>

	>> emit-html [div with [custom-tag: "custom value"] "Hello World"]
	== <div custom-tag="custom value">Hello World</div>

Ok, the last example is getting bit out of hand, so let's rewrite this using
custom tags:

	>> emit-html [
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World"
	]
	== <div custom-tag="custom value">Hello World</div>	

Now we have this nonsense carried in custom tag, cleverly called CUSTOM,
that accepts one parameter of STRING! datatype, called VALUE. So we can do this:

	>> emit-html [
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World" 
		custom "Hello completely unrelated World"
	]
	== <div custom-tag="custom value">Hello World</div>	<div custom-tag="custom value">Hello completely unrelated World</div>

Let's be fancy:

	>> emit-html [
		custom: what string! who string! [div [span .action what ", " span .name who "!"]]
		custom "Hello" "world"
		custom "Cheer up" "Brian"
	]
	== <div><span class="action">Hello</span>, <span class="name">world</span>!</div><div><span class="action">Cheer up</span>, <span class="name">Brian</span>!</div>

And also recursive:

	>> emit html [
		red-div: value block! [div .red value]
		red-info: title string! content block! [div .info [h1 title red-div content]]
		red-info "First thing" [span "this is first thing"]
		red-info "Second thing" [div [b "first thing is not enough"]]
		red-info "Last thing" [div [h2 "This is subtitle!" p "But are three things enough?"]]
	]




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

	row with 3 cols [span <planet>] replace <planet> from ["Venus" "Earth" "Mars"]

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

#Basic usage

#REPEAT

# ROW

ROW WITH 3 COLS [span <name>] REPLACE <name> FROM ["Venus" "Earth" "Mars"]

(block: ["Venus" "Earth" "Mars"] ...)
ROW WITH 3 COLS [span <name>] REPLACE <name> FROM block

ROW WITH 3 COLS [span <name>] REPLACE <name> FROM %data.r

ROW WITH 3 COLS [span <name>] REPLACE <name> FROM http://www.mraky.net/data.r