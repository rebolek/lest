REBOL[
	Title: "PLESK - Sender for LIZ"
	To-do: [
		"HTML entities"
	]
	Notes: [
		source: https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/HTML5/HTML5_element_list
		metadata:	[head title base link meta style]
		scripting:	[scipt noscript]
		sections:	[
			body section nav article aside 
			h1 h2 h3 h4 h5 h6
			header footer address main
		]
		grouping:	[
			p hr pre blockquote
			ol ul li dl dt dd
			figure figcaption
			div
		]
		text:		[
			a
			em strong small s dite q dfn abbr 
			data time code var samp kbd sub sup
			i b u mark ruby rt rp
			bdi bdo
			span
			br wbr
		]
		edits: [ins del]
		content: [
			img iframe embed object param
			video audio source track canvas
			map area svg math 
		]
		tables: [
			table caption colgroup colgroup
			tbody thead tfoot
			tr td th 
		]
		forms: [
			form fieldset legend label
			input button select datalist optgroup option
			textarea keygen output progress meter
		]
		interactive: [
			details summary menuitem menu
		]
	]
]

; === data structures

page: [
	title: none
]

form-data: context [
	action: none
	method: 'post
]


; === support functions

push: funct [
	stack
	value
][
	insert stack value
]

pop: funct [
	stack
][
	also first stack remove stack
]

peek: funct [
	stack
][
	first stack 
]

catenate: funct [
	"Joins values with delimiter."
    src [ block! ]
    delimiter [ char! string! ]
][
    out: make string! 20
    forall src [ repend out [ src/1 delimiter ] ]
    len: either char? delimiter [ 1 ][ length? delimiter ]
    head remove/part skip tail out negate len len
]


to-www-form: func [
	"Convert object body (block!) to application/x-www-form-urlencoded"
	data
	/local out
][
	out: copy {}
	foreach [ key value ] data [
		if issue? value [ value: next value ]
		repend out [
			to word! key
			#"="
			value 
			#"&"
		]
	]
	head remove back tail out
]


pair-tag: func [
	"Enclose value in tag"
	value
	type
][
	rejoin [
		""
		to tag! type
		value 
		head insert to tag! type "/"
	]
]


make-tag: funct [
	name
	values
][
comment {
	TODO: better key/value handling - ignore empty keys


	Ignores none! values, but inserts key
	so ID: NONE becomes id=""
	TODO: look for better solution
}

	value: clear ""
	out: clear {}
	append out rejoin [ "<" name ]

	; TODO: should work without parse, look into it

	parse compose values [
		some [
			set key set-word!
			some [
				set value [ none! | word! | issue! | file! | url! | number! | string! | block! ]
			]
			(
				if issue? value [ value: to word! value ]
				unless any [ 
					not value
					all [ block? value empty? value ]
				][
					append out rejoin [ #" " to word! key {="} value {"} ]
				]
			)
		]
	]
	head append out ">"
]

close-tag: func [
	type
][
	rejoin ["</" type ">"]
]



; === parse fucntions

stylesheets: copy {^/}

parse-html: funct [
	"Parse simple HTML dialect"
	data	
][
	; === variables

	styles:		copy []
	name:		copy ""
	value:		copy ""
	default:	copy ""
	size: 		50x4
	temp:		none
	tag:		none

	tag-stack: copy []

	output: copy ""
	temp: copy ""
	buffer: copy ""
	form-buffer: copy ""

	; === actions

	emit: func [ 
		data [ string! block! tag! ]
	][ 
		if block? data	[ data: rejoin data ]
		if tag? data	[ data: mold data ]
		append buffer data ;join data newline
	]

	emit-tag: funct [
		tag [object!]
	][
		?? tag
		out: clear make string! 256
		skip?: false
		repend out [ "<" tag/name ]
		tag: head remove/part find body-of tag to set-word! 'name 2
		foreach [ key value ] tag [
			skip?: false
			value: switch/default type?/word value [
				block!	[ 
					if empty? value [ skip?: true ]
					catenate value #" " 
				]
				string!	[ if empty? value [ skip?: true ] ]
				none!	[ skip?: true ]
			][
				form value
			]
			unless skip? [
				repend out [ " " to word! key {="} value {"} ]
			]
		]
;		remove back tail out
		append buffer head append out #">"
	]


	make-label: func [
		label
		element
	][
		rejoin [ 
			emit-tag 'label [ for: (element) ] 
			label 
			close-tag 'label 
		]
	]

	; === rules

	; --- subrules

	init-tag: [
		(
			print [ #init-tag mold name ]
			value:		none
			default:	copy ""
			temp: 		none
			target:		none
			push tag-stack context [ id: none class: copy [] ]
			tag: peek tag-stack
			append tag probe compose [ name: (name) ] 	; TODO: this should work in CONTEXT above 
		)
	]

	style: [
		( print "style start" )
		some [
			'id set temp word! ( print "id" probe tag/id: temp )
		|	set temp issue! ( print "class" append tag/class to word! temp )
		]
	]

	comment: [
		'comment block!
	]

	script: [
		'script
		init-tag
		set value [ string! | file! | url! ]
		(
			emit [
				either string? value [
					rejoin ["" <script> value]
				][
					rejoin [{<script src="} value {">} ]
				]
				close-tag 'script
			]
		)
	]

	; --- header
	; TODO: remove custom rules from header (script, style...)
	; TODO: add META

	header: [
		'header (header?: true)
		some [
			'title set value string! (page/title: value)
		|	'stylesheet set value [ file! | url! ] (
				repend stylesheets [{<link href="} value {" rel="stylesheet">} newline ]
			) 
		|	'style set value string! (
				repend stylesheets ["" <style> value </style> newline ]
			)
		|	'script [
				set value [ file! | url! ] (
					repend stylesheets [{<script src="} value {">}</script> newline ]
				)
			|	set value string! (
					repend stylesheets ["" <script> value </script> newline ]
				)
			]
		]
		'body

	]
	
	; --- basic elements

	br: [ 'br ( emit <br> ) ]
	hr: [ 'hr ( emit <hr> ) ]	

	match-content: [
		set value string!
	|	into elements
	]

	paired-tags: [ 'i | 'b | 'p | 'div | 'span | 'small | 'em | 'strong | 'footer ]
	paired-tag: [
		set name paired-tags 
		init-tag
		opt style
		(
			emit-tag tag
		)
		match-content
		(
			tag: pop tag-stack
			if value [ emit value ]
			emit close-tag tag/name
		)
	]

	image: [
		'image
		init-tag
		some [
			set target [ file! | url! ] 
		|	style 
		]
		(
			emit-tag 'img reduce/no-set [ src: target id: id class: styles]
		)
	]

	; <a>
	link: [
		'link 
;		init-tag
		( link-tag: context [] )
		some [
			style (
				append link-tag reduce/no-set [ id: id class: styles ]
			)
		|	
		set target [ file! | url! ] (
			append link-tag compose [ href: (target) ]
		)

		] pos: 
		(
			value: none 
			emit-tag 'a body-of link-tag
		)
		match-content
		(
			if value [ emit value ]
			emit close-tag 'a
		)
	]

	; lists - UL, OL, LI

	li: [
		'li
		opt style
		(
			value: none
			emit-tag 'li [ id: (id) class: (styles) ]
		)
		match-content
		(
			if value [emit value]
			emit close-tag 'li
		)
	]

	ul: [
		'ul
		opt style
			( emit-tag 'ul [ id: (id) class: (styles) ] )
		some li
			( emit close-tag 'ul )
	]

	ol: [
		; TODO: uses some custom values, make better handling
		'ol
		any [
			style
		|	set start integer!
		]
		( emit-tag 'ul [ id: (id) class: (styles) ] )
		some li
		( emit close-tag 'ul )

	]

	list-elems: [
		ul
	|	ol
	]

	basic-elems: [
		comment
	|	br
	|	hr
	|	paired-tag
	|	image
	|	link 
	|	list-elems
	]

	; --- headings

	h1: [ 'h1 ( elem: 'h1 ) ]
	h2: [ 'h2 ( elem: 'h2 ) ]
	h3: [ 'h3 ( elem: 'h3 ) ]
	h4: [ 'h4 ( elem: 'h4 ) ]
	h5: [ 'h5 ( elem: 'h5 ) ]
	h6: [ 'h6 ( elem: 'h6 ) ]	
	heading: [ 
		[ h1 | h2 | h3 | h4 | h5 | h6 ] 
		some [
			set value string!
		|	style	
		]
		( 
			emit-tag tag
			emit [	
				value
				close-tag elem
			]
		)
	]

	; --- forms

	field: [ 
		'field
		init-tag 
		set name word! 
		some [
			set label string! 
;		|	opt [set default string!]
		|	style
		]
		(
			unless id [ id: name ]			
			emit [ 
				make-label label name
				make-tag 'input [ type: "text" name: (name) id: (id) class: (styles)]
			] 
		) 
	]
	password: [ 
		'password 
		init-tag
		set name word! 
		some [
			set label string! 
		|	style
		]
		(
			unless id [ id: name ]
			emit [
				make-label label name
				make-tag 'input [ type: "password" name: (name) id: (id) ]
			]
		)
	]
	textarea: [
		'textarea (size: 50x4)
		set name word!
		some [
			set size pair!
		|	set label string!
		|	style
		]
		(
			unless id [ id: name ]
			emit [
				make-label label name
				make-tag 'textarea [ 
					cols: (to integer! size/x) 
					rows: (to integer! size/y) 
					name: (name) 
					id: (id) 
				]
				close-tag 'textarea
			]
		)
	]
	checkbox: [
		'checkbox
		set name word!
		some [
			set label string!
		|	style
		]
		(
			unless id [ id: name ]
			emit [
				make-label label name
				make-tag 'input [type: "checkbox" name: (name) id: (id)]
			]
		)
	]
	hidden: [
		'hidden
		set name word!
		some [
			set value string!
		|	style
		]
		(
			emit make-tag 'input [ type: "hidden" name: (name) value: (value) ]
		)
	]	
	submit: [
		'submit 
		set label string!
		(
			emit make-tag 'input [ type: "submit" value: (label) ]
		)
	]


	form-content: [
		some [
			br	
		|	field
		|	password
		|	textarea
		|	checkbox
		|	submit
		|	hidden
		|	captcha
		]
	]
	form: [ 
		'form 
		set value [ file! | url! ] ( form-data/action: value )
		(
			buffer: copy form-buffer
			emit make-tag 'form body-of form-data
		)
		into form-content (
			emit </form>
			buffer: output
			emit form-buffer
		)
	]

	; --- "plugins"
	captcha: [
		'captcha set value string! (
			emit replace {
<script type="text/javascript"
     src="http://www.google.com/recaptcha/api/challenge?k=#public-key">
  </script>
  <noscript>
     <iframe src="http://www.google.com/recaptcha/api/noscript?k=#public-key"
         height="300" width="500" frameborder="0"></iframe><br>
     <textarea name="recaptcha_challenge_field" rows="3" cols="40">
     </textarea>
     <input type="hidden" name="recaptcha_response_field"
         value="manual_challenge">
  </noscript>
} #public-key value
		)
	]
	ga: [ 
		; google analytics
		'ga set value word! (
			emit replace {
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', '#value', 'mraky.net');
  ga('send', 'pageview');

</script>
} #value value
		)
	]

	map: [
		; google maps
		'map set location pair!
		(
			emit rejoin [ ""
   				<div id="contact" class="map"> newline 
   					<div id="map_canvas"></div> newline
   				</div> newline
   				<script> 
   				{google.maps.event.addDomListener(window, 'load', setMapPosition(} location/x #"," location/y {));}
   				</script>
    		]
		)
	]

	plugins: [
		ga
	|	map	
	]


	; --- put it all together

	elements: [
		[
			basic-elems
		|	heading
		|	form
		|	script
		|	bootstrap-elems
		|	plugins	
		]
		(
			; cleanup buffer
			value: none
		)
	]

	; bootstrap elements

	bootstrap-elems: [
		container
	|	row	
	]

	container: [
		'container
		( emit make-tag 'div [class: #container] )
		into elements
		(emit close-tag 'div)	
	]

	row: [
		'row
		( emit make-tag 'div [class: #row] )
		into elements
		(emit close-tag 'div)	
	]

	; === do something useful

	main-rule: [
		opt header
		some elements
	]

	unless parse data main-rule [
		return none!
	]
	head buffer
]

parse-page: funct [
	data
][
	header?: false
	body: parse-html compose/deep data
	; move header to make-header funct (input is header object)
	either header? [
		rejoin [ ""
<!DOCTYPE html> newline 
<html lang="en-US"> newline 
	<head> newline
		<title> page/title </title> newline 
		<meta charset="utf-8"> newline
		stylesheets
	</head> newline
	<body>
		body
	</body>
</html>
		]
	][
		body
	]
]