LEST
====

Low Entropy System for Templating
---------------------------------

**Lest** is template engine/static site generator/whatever with low entropy and
high customization. It removes unnecessary visual noise as `<`and `>` or end tags. 
Instead it uses efficient and rich Rebol syntax to describe the document.
Custom plugins can be added very easily and basic distribution includes plugin
for advanced [Bootstrap](http://www.getbootstrap.com) support.

### Overview

**Lest** describes HTML document in clutter-free way that is then translated
to the mess that rules the world. See some examples *(Lest source is
prefixed with `>>` and HTML output with `==`):*

	>> lest [div "Hello World"]
	== <div>Hello World</div>

	>> lest [div #example "Hello World"]
	== <div id="example">Hello World"</div>

	>> lest [div #example .big .outline "Hello World"]
	== <div id="example" class="big outline">Hello World"</div>

	>> lest [div with [custom-tag: "custom value"] "Hello World"]
	== <div custom-tag="custom value">Hello World</div>

Ok, the last example is getting bit out of hand, so let's rewrite this using
custom tags:

	>> lest [
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World"
	]
	== <div custom-tag="custom value">Hello World</div>	

Now we have this nonsense carried in custom tag, cleverly called CUSTOM,
that accepts one parameter of STRING! datatype, called VALUE. So we can do this:

	>> lest [
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World" 
		custom "Hello completely unrelated World"
	]
	== <div custom-tag="custom value">Hello World</div>	
	== <div custom-tag="custom value">Hello completely unrelated World</div>

Let's be fancy:

	>> lest [
		custom: what string! who string! [div [span .action what ", " span .name who "!"]]
		custom "Hello" "world"
		custom "Cheer up" "Brian"
	]
	== <div><span class="action">Hello</span>, <span class="name">world</span>!</div>
	== <div><span class="action">Cheer up</span>, <span class="name">Brian</span>!</div>

These user templates can be used to construct complex layouts:

	>> lest [
		user-post: name string! avatar url! title string! content string! [
			div .user-post [
				div .user-info [
					div .user-name name
					img avatar
				]
				div .message [
					h3 .post-title title
					p .post-content content
				]
			]
		]

		user-post "Karel" http://myface.com/karel.jpg "First Message" "Hello, this is my first message"
		user-post "Jana" http://myface.com/jana.jpg "You are a Hero!" "I'm glad you've made it!"
		user-post "Bot" http://myface.com/default.jpg "Broadcast to all" "Please, don't polute this channel."
	]

	==	<div class="user-post">
	== 		<div class="user-info">
	==			<div class="user-name">Karel</div>
	==			<img src="http://myface.com/karel.jpg">
	==		</div>
	==		<div class="message">
	==			<h3 class="post-title">First Message</h3>
	== 			<p class="post-content">Hello, this is my first message</p>
	== 		</div>
	== 	</div>
	== 	<div class="user-post">
	==		<div class="user-info">
	==			<div class="user-name">Jana</div>
	== 			<img src="http://myface.com/jana.jpg">
	==		</div>
	==		<div class="message">
	==			<h3 class="post-title">You are a Hero!</h3>
	== 			<p class="post-content">I'm glad you've made it!</p>
	==		</div>
	==	</div>
	==	<div class="user-post">
	==		<div class="user-info">
	==			<div class="user-name">Bot</div>
	==			<img src="http://myface.com/default.jpg">
	==		</div>
	==		<div class="message">
	==			<h3 class="post-title">Broadcast to all</h3>
	==			<p class="post-content">Please, don't polute this channel.</p>
	==		</div>
	==	</div>

So this is how you construct your templates, instead of repeating the same stuff over and over.

But this is still somehow static. So you can get the data from file or database:

	... TODO: add example

### Plugins

Plugins are easy-to-write extensions that add more functionaliy than user rules.
Lest come with plugins that add support for Bootstrap, different Google services
(Maps, Analytics, Fonts, ...) and others.

	>> lest [
		enable bootstrap 
		container [
			row [col 6 .upper "left column" col 6 .upper "right column"] 
			row [col 4 offset 4 .lower "middle column with 1/3 width"]
		]
	]

	==	<div class="container">
	==		<div class="row">
	==			<div class="upper col-md-6">
	==				<span>left column</span>
	==			</div>
	==			<div class="upper col-md-6">
	==				<span>right column</span>
	==			</div>
	==		</div>
	==		<div class="row">
	==			<div class="lower col-md-4 col-md-offset-4">
	==				<span>middle column with 1/3 width</span>
	==			</div>
	==		</div>
	==	</div>

### Requirements

**Lest** is written in [Rebol](http://www.rebol.com) language. You can get latest Rebol binaries from
http://www.rebolsource.com or build a binary yourself from [source at GitHub](https://github.com/rebol/rebol).

### Example code

	head

	enable bootstrap
	enable smooth-scrolling
	stylesheet css-path/lest.css
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

	h2 "Why Lest?"
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

	p {Lest supports different plugins:}

	ul
	li "Google fonts"
	li "Google maps"
	li "Google analytics"
	li "Font Awesome glyphs"
	li "Captcha, etc..."

	footer [ "more later" ]

### Basic usage

#### REPEAT

#### ROW

	ROW WITH 3 COLS [span <name>] REPLACE <name> FROM ["Venus" "Earth" "Mars"]

	(block: ["Venus" "Earth" "Mars"] ...)
	ROW WITH 3 COLS [span <name>] REPLACE <name> FROM block

	ROW WITH 3 COLS [span <name>] REPLACE <name> FROM %data.r

	ROW WITH 3 COLS [span <name>] REPLACE <name> FROM http://www.mraky.net/data.r