REBOL[
	Title: "PLESK - Sender for LIZ"
	To-do: [
		"HTML entities"
		"Cleanup variables in parse-html"
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

parse-html: funct [
	"Parse simple HTML dialect"
	data	
][
	; === variables

	stylesheets: copy {^/}
	styles:		copy []
	name:		copy ""
	value:		copy ""
	default:	copy ""
	size: 		50x4
	temp:		none
	tag:		none
	type: 		none
	grid-size: 'md

	tag-stack: copy []

	page: reduce/no-set [
		title: "Page generated with Bootrapy"
		meta: copy {}
	]

	form-data: context [
		action: none
		method: 'post
	]


	output: copy ""
	temp: copy ""
	buffer: copy ""
	form-buffer: copy ""

	header?: false

	; === actions

	emit: func [ 
		data [ string! block! tag! ]
	][ 
		if block? data	[ data: rejoin data ]
		if tag? data	[ data: mold data ]
		append buffer data ;join data newline
	]

	make-tag: funct [
		tag [object!]
	][
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
		head append out #">"
	]

	emit-tag: funct [
		tag [object!]
	][
		append buffer make-tag tag
	]

	emit-label: func [
		label
		elem
		/class
		styles
	][
		emit-tag context [ element: 'label for: elem class: styles ]
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
			push tag-stack tag: context [ id: none class: copy [] element: name ]
		)
	]

	style: [
		some [
			'id set temp word! ( tag/id: temp )
		|	set temp issue! ( append tag/class to word! temp )
		|	'with set temp block! ( append tag temp )
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

	page-header: [
		'head (header?: true)
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
		|	'meta set name word! set value string! (
				repend page/meta [ {<meta name="} name {" content="} value {">}]
			)

		]
		'body

	]
	
	; --- basic elements

	br: [ 'br ( emit <br> ) ]
	hr: [ 'hr ( emit <hr> ) ]	

	match-content: [
		set value string!
	|	into [ some elements ]
	]

	paired-tags: [ 'i | 'b | 'p | 'div | 'span | 'small | 'em | 'strong | 'footer | 'nav | 'button ]
	paired-tag: [
		set name paired-tags 
		init-tag
		opt style
		( emit-tag tag )
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
		set name 'ol
		init-tag
		any [
			style
		|	set start integer! ( append tag compose [ start: (start) ] )
		]
		( emit-tag tag )
		some li
		( 
			tag: pop tag-stack
			emit close-tag 'ol 
		)

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
			tag: pop tag-stack
			emit-tag tag
			emit [	
				value
				close-tag tag/element
			]
		)
	]

	; --- forms

	init-input: [
		( name: 'input )
		init-tag
		( tag: peek tag-stack )
	]
	emit-input: [
		(
			switch/default form-type [
				horizontal [
					emit-label/class label name	[col-sm-2 control-label]
					emit <div class="col-sm-10">
					tag: pop tag-stack
					append tag compose [ type: (type) name: (name) ] 
					emit-tag tag
					emit </div>
				]
			][
				emit-label label name
				tag: pop tag-stack
				append tag compose [ type: (type) name: (name) ] 
				emit-tag tag
			]
		) 
	]
	input-parameters: [
		set name word! 
		some [
			set label string! 
		|	style
		]
	]
	input: [
		set type [ 
			'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week 
		|	'number | 'email | 'url | 'search | 'tel | 'color
		]
		( emit <div class="form-group"> )
		init-input
		( append tag/class 'form-control )
		input-parameters
		emit-input
		( emit </div> )
	]	
	checkbox: [
		set type 'checkbox
		( emit [ "" <div class="checkbox"> <label> ] )
		init-input
		input-parameters
		(
			tag: pop tag-stack
			append tag compose [ type: (type) name: (name) ] 
			emit-tag tag 
			emit [label </label> </div> ] 
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
		(
			push tag-stack tag: context [
				element:	'button
				type:		'submit	
				id:			none 
				class: copy [btn btn-default]
			]
		)
		some [
			set label string! 
		|	style
		]
		(
			tag: pop tag-stack
			switch/default form-type [
				horizontal [
					emit <div class="form-group">
					emit <div class="col-sm-offset-2 col-sm-10">				
					emit-tag tag
					emit [ label </button> </div> </div> ]

				]
			][
				emit-tag tag
				emit [ label </button> ]
			]
		)
	]


	form-content: [
		
		[
			br	
		|	input
		|	textarea
		|	checkbox
		|	submit
		|	hidden
		|	captcha
		]
	]
	form-type: none
	form: [ 
		set name 'form
		( form-type: none )
		init-tag
		opt [
			'horizontal
			( form-type: 'horizontal )
		]
		(
			append tag compose [ 
				action:	(value) 
				method:	'post
;				role:	'form
			]
			if form-type [ append tag/class join "form-" form-type ]
		)
		some [
			set value [ file! | url! ] ( 
				append tag compose [ action: (value) ]
			)
		|	style
		] 
		( 
			tag: pop tag-stack
			emit-tag tag 
		)
		into [ some form-content ] 
		( emit </form> )
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
			set value string! ( emit value )
		|	basic-elems
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
		grid-elems
	|	col	
	|	glyphicon
	]

	close-div: [
		( 
			tag: pop tag-stack
			emit </div>
		)
	]

	grid-elems: [
		set type [ 'row | 'container ]
		( name: 'div )
		init-tag
		( 
			append tag/class type
			emit-tag tag
		)
		into [ some elements ]
		close-div
	]

	col: [
		'col
		( 
			name: 'div 
			grid-size: 'md
			width: 2
		)
		init-tag
		opt [ set grid-size [ 'xs | 'sm | 'md | 'lg ] ]
		set width integer!
		(
			append tag/class rejoin [ "col-" grid-size "-" width ]
			emit-tag tag
		)
		into [ some elements ]
		close-div
	]

	glyphicon: [
		'glyphicon 
		set name word!
		(
			emit rejoin [{<span class="glyphicon glyphicon-} name {"></span>}]
		)
	]


	; === do something useful

	main-rule: [
		opt page-header
		some elements
	]

	unless parse data main-rule [
		return none!
	]

	body: head buffer

	either header? [
		rejoin [ ""
<!DOCTYPE html> newline 
<html lang="en-US"> newline 
	<head> newline
		<title> page/title </title> newline 
		<meta charset="utf-8"> newline
		page/meta newline
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
