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

	>> div "Hello World"
	== <div>Hello World</div>

	>> div #example "Hello World"
	== <div id="example">Hello World"</div>

	>> div #example .big .outline "Hello World"
	== <div id="example" class="big outline">Hello World"</div>

	>> div with [custom-tag: "custom value"] "Hello World"
	== <div custom-tag="custom value">Hello World</div>

Ok, the last example is getting bit out of hand, so let's rewrite this using
custom tags:

	>>
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World"

	== 
		<div custom-tag="custom value">Hello World</div>	

Now we have this nonsense carried in custom tag, cleverly called CUSTOM,
that accepts one parameter of STRING! datatype, called VALUE. So we can do this:

	>>
		custom: value string! [div with [custom-tag: "custom value"] value]
		custom "Hello World" 
		custom "Hello completely unrelated World"

	== 
		<div custom-tag="custom value">Hello World</div>	
		<div custom-tag="custom value">Hello completely unrelated World</div>

Let's be fancy:

	>>
		custom: what string! who string! [div [span .action what ", " span .name who "!"]]
		custom "Hello" "world"
		custom "Cheer up" "Brian"
	
	== 
		<div><span class="action">Hello</span>, <span class="name">world</span>!</div>
		<div><span class="action">Cheer up</span>, <span class="name">Brian</span>!</div>

These user templates can be used to construct complex layouts:

	>>
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


	==
		<div class="user-post">
			<div class="user-info">
				<div class="user-name">Karel</div>
				<img src="http://myface.com/karel.jpg">
			</div>
			<div class="message">
				<h3 class="post-title">First Message</h3>
	 			<p class="post-content">Hello, this is my first message</p>
			</div>
	 	</div>
	 	<div class="user-post">
			<div class="user-info">
				<div class="user-name">Jana</div>
	 			<img src="http://myface.com/jana.jpg">
			</div>
			<div class="message">
				<h3 class="post-title">You are a Hero!</h3>
	 			<p class="post-content">I'm glad you've made it!</p>
			</div>
		</div>
		<div class="user-post">
			<div class="user-info">
				<div class="user-name">Bot</div>
				<img src="http://myface.com/default.jpg">
			</div>
			<div class="message">
				<h3 class="post-title">Broadcast to all</h3>
				<p class="post-content">Please, don't polute this channel.</p>
			</div>
		</div>

So this is how you construct your templates, instead of repeating the same stuff over and over.

But this is still somehow static. So you can get the data from file or database:

	... TODO: add example

### Plugins

Plugins are easy-to-write extensions that add more functionaliy than user rules.
Lest come with plugins that add support for Bootstrap, different Google services
(Maps, Analytics, Fonts, ...) and others.

	>>
		enable bootstrap 
		container [
			row [col 6 .upper "left column" col 6 .upper "right column"] 
			row [col 4 offset 4 .lower "middle column with 1/3 width"]
		]
	

	==
		<div class="container">
			<div class="row">
				<div class="upper col-md-6">
					<span>left column</span>
				</div>
				<div class="upper col-md-6">
					<span>right column</span>
				</div>
			</div>
			<div class="row">
				<div class="lower col-md-4 col-md-offset-4">
					<span>middle column with 1/3 width</span>
				</div>
			</div>
		</div>

### Requirements

**Lest** is written in [Rebol](http://www.rebol.com) language. You need Rebol 3 version to run Lest. It's not possible to run itunder Rebol 2. You can get latest Rebol binaries from
http://www.rebolsource.net or build a binary yourself from [source at GitHub](https://github.com/rebol/rebol).

### Example code

	head

	enable bootstrap
	enable smooth-scrolling
	enable google-font
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

	either [now/time < 12:00] "Good morning!" "Good afternoon"

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

	p {Lest supports different plugins:}

	ul
	li "Google fonts"
	li "Google maps"
	li "Google analytics"
	li "Font Awesome glyphs"
	li "Captcha, etc..."

	footer [ "more later" ]

### Variables and user templates

You can set your words in **Lest** there are two types of them. User templates
has been decribed above and are set using the **set-word** syntax.

Variables are words that hold one value and are set using `SET` syntax.

	>> set value "Hello" span value
	== <span>Hello</span>

Variables can also be used to change default settings like **js-path** or **css-path**.

### Structural logic

In **Lest**, you are free to shoot yourself to foot using embeed Rebol code. 
However, **Lest** provides much safer basic structural logic that is preferred
mode of operation. List of available commands follows.

#### IF

`IF` is basic condition, dialect block is processed only if the condition is true.

	>> if [now/time < 12:00][span "good morning"]
	== <span>good morning</span>

	>> if [now/time > 12:00][span "good morning"]
	;; returns nothing

Condition is Rebol code or word of logic datatype.

#### EITHER

`EITHER` is extened `IF` condition that accepts two values. In some languages
this is achieved with crude `IF ... THEN ... ELSE` construct, **Lest** prefers
much simpler `EITHER`

	>> either [now/time < 12:00][span "good morning"][span "good evening"]
	== <span>good morning</span>

One great feature of conditions and other structural logic in **Lest** is that 
it can be placed anywhere. So the above example can be simplified as:

	>> span either [now/time < 12:00] "good morning" "good evening"
	== <span>good morning</span>

	>> span either [now/time < 12:00] .morning .evening "Hello!"
	== <span class="morning">Hello!</span>

You get the idea.

#### SWITCH

`SWITCH` is multiple choice condition.

	>> set x 1 span ["value is " switch x [1 "one" 2 "two" 3 "three"]]
	== <span>value is one</span>

If the choice should return multiple elements, enclose it in block:

	>> set x 2 span ["value is " switch x [1 "one" 2 [b "two"] 3 "three"]]
	== <span>value is <b>two</b></span>

If the value is not in choices, **Lest** throws an error. Therefore it's wise
to include the `DEFAULT` option:

	>> set x 5 span ["value is " switch x [1 "one" 2 "two" 3 "three"] default "out of range"]
	== "<span>value is out of range</span>"

#### FOR

`FOR` command takes block of values and applies a rule on each of them:

	>> for planet in ["Earth" "Venus" "Mars"] [span planet]  
	== <span>Earth</span><span>Venus</span><span>Mars</span>

The block can be of course referenced by name:

	>> set planets ["Earth" "Venus" "Mars"] for planet in planets [span planet]
	== <span>Earth</span><span>Venus</span><span>Mars</span>

Basic syntax is: `FOR <word> IN <block> [...]`

#### other structural logic

will be added later.
