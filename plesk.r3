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

{
See: http://dev.w3.org/html5/markup/common-models.html#common.elem.phrasing


Flow-elements: [
	phrasing elements  a  p  hr  pre  ul  ol  dl  div  h1  h2  h3  h4  h5  h6  
	hgroup  address  blockquote  ins  del  object  map  noscript  
	section  nav  article  aside  header  footer  video  audio  
	figure  table  fm  fieldset  menu  canvas  details
]
Metadata-elements: [
	link  style  meta name  
	meta http-equiv=refresh  
	meta http-equiv=default-style  
	meta charset  
	meta http-equiv=content-type  
	script  noscript  command
]
Phrasing-elements: [
	a  em  strong  small  mark  abbr  dfn  
	i  b  s  u  code  var  samp  kbd  sup  sub  
	q  cite  span  bdo  bdi  br  wbr  ins  del  img  
	embed  object  iframe  map  area  script  noscript  
	ruby  video  audio  input  textarea  select  button  
	label  output  datalist  keygen  progress  command  canvas  time  meter
]

}		
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
		prin "emit-tag:: "
		?? tag
		out: make string! 256
		skip?: false
		repend out [ "<" tag/element ]
		tag: head remove/part find body-of tag to set-word! 'element 2
		foreach [ key value ] tag [
			skip?: false
			value: switch/default type?/word value [
				block!	[ 
					if empty? value [ skip?: true ]
					catenate value #" " 
				]
				string!	[ if empty? value [ skip?: true ] value ]
				none!	[ skip?: true ]
			][
				form value
			]
			unless skip? [
				repend out [ " " to word! key {="} value {"} ]
			]
		]
		append buffer head append out #">"
	]


	emit-label: func [
		label
		elem
	][
		emit-tag context [ element: 'label for: elem ]
		emit join label close-tag 'label 
	]

	; === rules

	; --- subrules

	init-tag: [
		(
			value:		none
			default:	copy ""
			temp: 		none
			target:		none
			push tag-stack context [ id: none class: copy [] ]
			tag: peek tag-stack
			append tag compose [ element: (name) ] 	; TODO: this should work in CONTEXT above 
		)
	]

	style: [
		some [
			'id set temp word! ( tag/id: temp )
		|	set temp issue! ( append tag/class to word! temp )
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
			emit close-tag tag/element
		)
	]

	image: [
		['img | 'image] ( name: 'img )
		init-tag
		some [
			set target [ file! | url! ] ( append tag compose [ src: (target) ] )
		|	style 
		]
		(
			tag: pop tag-stack
			emit-tag tag
		)
	]

	; <a>
	link: [
		['a | 'link] ( name: 'a )
		init-tag
		some [
			set target [ file! | url! ] ( append tag compose [ href: (target) ] )
		|	style
		] 
		( emit-tag tag )
		match-content
		(
			tag: pop tag-stack
			if value [ emit value ]
			emit close-tag 'a
		)
	]

	; lists - UL, OL, LI

	li: [
		set name 'li
		init-tag
		opt style
		( emit-tag tag )
		match-content
		(
			tag: pop tag-stack
			if value [emit value]
			emit close-tag 'li
		)
	]

	ul: [
		set name 'ul
		init-tag
		opt style
		( emit-tag tag )
		some li
		( 
			tag: pop tag-stack
			emit close-tag 'ul 
		)
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

	heading: [ 
		set name [ 'h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6 ]
		init-tag
		some [
			set value string!	; TODO: headings can contain Phrasing elements (see HEADER/NOTE)
		|	style	
		]
		( 
			emit-tag tag
			emit [	
				value
				close-tag tag/element
			]
		)
	]

	; --- forms

	field: [ 
		'field ( name: 'input )
		init-tag 
		set name word! 
		some [
			set label string! 
		|	style
		]
		(
			emit-label label name
			tag: pop tag-stack
			append tag compose [ type: "text" name: (name) ] 
			emit-tag tag
		) 
	]
	password: [ 
		'password ( name: 'input )
		init-tag
		set name word! 
		some [
			set label string! 
		|	style
		]
		(
			emit-label label name
			tag: pop tag-stack
			append tag compose [ type: "password" name: (name) ] 
			emit-tag tag
		)
	]
	email: [ 
		'email ( name: 'input )
		init-tag 
		set name word! 
		some [
			set label string! 
		|	style
		]
		(
			emit-label label name
			tag: pop tag-stack
			append tag compose [ type: "email" name: (name) ] 
			emit-tag tag
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
		|	email
		|	textarea
		|	checkbox
		|	submit
		|	hidden
		|	captcha
		]
	]
	form: [ 
		set name 'form
		init-tag
		set value [ file! | url! ] ( 
			tag: peek tag-stack
			append tag compose [ 
				action: (value) 
				method: 'post
			]
			emit-tag tag 
		)
		into form-content ( emit </form> )
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
	|	glyphicon
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

;<span class="glyphicon glyphicon-search"></span>
	glyphicon: [
		'glyphicon 
		set name word!
		(
			emit rejoin [{<span class="glyphicon glyphicon-} name {"></span>}]
		)
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