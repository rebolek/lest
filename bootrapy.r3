REBOL[
	Title:		"BOOTRAPY - HTML/Bootstrap dialect"
	Author:		"Boleslav Brezovsky"
	Version:	0.0.1
	Date:		7-12-2013 
	To-do: [
		"HTML entities"
		"Cleanup variables in emit-html"
		"Change header rules to emit to main data"
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


; SETTINGS


js-path: %../../js/			; we are in cgi-bin/lib/ so we need to go two levels up
css-path: %../../css/

;
;   _____   _    _   _____    _____     ____    _____    _______     ______   _    _   _   _    _____    _____ 
;  / ____| | |  | | |  __ \  |  __ \   / __ \  |  __ \  |__   __|   |  ____| | |  | | | \ | |  / ____|  / ____|
; | (___   | |  | | | |__) | | |__) | | |  | | | |__) |    | |      | |__    | |  | | |  \| | | |      | (___  
;  \___ \  | |  | | |  ___/  |  ___/  | |  | | |  _  /     | |      |  __|   | |  | | | . ` | | |       \___ \ 
;  ____) | | |__| | | |      | |      | |__| | | | \ \     | |      | |      | |__| | | |\  | | |____   ____) |
; |_____/   \____/  |_|      |_|       \____/  |_|  \_\    |_|      |_|       \____/  |_| \_|  \_____| |_____/ 
;                                                                                                              

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
    /as-is "Mold values"
][
    out: make string! 200
    forall src [ repend out [ either as-is [mold src/1] [src/1] delimiter ] ]
    len: either char? delimiter [ 1 ][ length? delimiter ]
    head remove/part skip tail out negate len len
]

replace-deep: funct [
	target
	'search
	'replace 
][
	rule: compose [
		change (:search) (:replace)
	|	any-string!
	|	into [ some rule ]
	|	skip	
	]
	parse target [ some rule ]
	target
]

replace-all: funct [
	target
	values
][
	foreach [search repl] values [
		replace target search switch/default type?/word repl [
			paren!	[do repl]
			word! 	[get repl]
		] [ repl ]
	]
	target
]

add-rule: func [
	"Add new rule to PARSE rules block!"
	rules 	[block!]
	rule 	[block!]
] [
	unless empty? rules [
		append rules '|
	]
	append rules rule
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

emit-html: funct [
	"Parse simple HTML dialect"
	data
	/with
		custom-rule
][
;	print "emit-html"
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
	add-plugins: copy {}
	grid-size: 'md

	tag-stack: copy []
	user-rules: copy [ fail ]	; fail is "empty rule", because empty block isn't (why?)

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

;  _____    _    _   _        ______    _____ 
; |  __ \  | |  | | | |      |  ____|  / ____|
; | |__) | | |  | | | |      | |__    | (___  
; |  _  /  | |  | | | |      |  __|    \___ \ 
; | | \ \  | |__| | | |____  | |____   ____) |
; |_|  \_\  \____/  |______| |______| |_____/ 
;                                             
                                             
	; --- subrules

	import: [
		; LOAD AND EMIT FILE
		'import set value [ file! | url! ]
		( emit emit-html load value )
	]

	do-code: [
		; DO PAREN! AND EMIT LAST VALUE
		set value paren! 
		( emit emit-html do value )
	]

	user-rule: [
		set name set-word!
		( 
			parameters: copy [ ] 
			add-rule user-rules reduce [ 
				to set-word! 'pos 
				to lit-word! name 
			]
		)
		any [ 
			set label word! 
			set type word! 
			(
				add-rule parameters reduce [ 'change to lit-word! label label ]
				repend user-rules [ 'set label type ] 
			)
		]
		set value block!
		(
			repend user-rules [ 
				to paren! compose/only [ 
					; TODO: move rule outside
					rule: [
						any-string!
					|	into [ some rule ]
					|	parameters
					|	skip	
					]
					temp: copy/deep ( value )
					parse temp [ some rule ]
					emit emit-html temp
				]
			]
			user-rules
		)
	]

	make-row: [
		'row
		'with
		( 
			index: 1
			offset: none 
		)
		some [
			set cols integer! 
			[ 'col | 'cols ]
		|	'offset
			set offset integer!	
		;	
		; --
		; -- TODO: COL x COL y COL ...
		; --
		; -- set DATA and use it later
		; --
		;
		]
		set element block!
		'replace
		set value tag!
		[
			'from
			set data [ block! | word! | file! | url! ]
			(
				out: make block! length? data
				switch type?/word data [
					word!	[ data: get data ]
					url!	[ data: read data ] 	; CHECK
					file!	[ data: load data ]
				]
				foreach item data [
					current: copy/deep element
					replace-deep current value item
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				]
				emit emit-html compose/deep [ row [ (out) ] ]
			)
		|	'with
			set data block!
			(
				out: make block! length? data
				; replace <filename> with [ rejoin [ %img/image- index %.jpg ] ]
				repeat index cols [
					current: copy/deep element
					replace-deep current value do bind data 'index
					if offset [
						insert skip find current 'col 2 reduce [ 'offset offset ]
						offset: none
					]
					append out current
				] 
				emit emit-html compose/deep [ row [ (out) ] ]
			)	
		]

	]

	repeat: [
		'repeat
		(
			offset: none
		)
		opt [
			'offset
			set offset integer!
		]
		set element block!
		'replace
		set value tag!
		[
			[
				'from
				set data [ block! | word! ]
				(
					if word? data [ data: get data ]
					out: make block! length? data
					foreach item data [
						current: copy/deep element
						replace-deep current value item
						if offset [
							insert skip find current 'col 2 reduce [ 'offset offset ]
							offset: none
						]
						append out current
					]
					emit emit-html compose/deep [ row [ (out) ] ]
				)
			]
		|	[
				'with
				set data block!
				(

				)
			]
		]
	]

	init-tag: [
		(
			value:		none
			default:	copy ""
			temp: 		none
			target:		none
			push tag-stack tag: context [ id: none class: copy [] element: name ]
		)
	]

	pop-tag: [ ( tag: pop tag-stack ) ]

	style: [
		some [
			'id set temp word! ( tag/id: temp )
		|	set temp issue! ( append tag/class to word! temp )
		|	'with set temp block! ( append tag temp )
		]
	]

	comment: [
		'comment [ block! | string! ]
	]

	script: [
		'script
		init-tag
		set value [ string! | file! | url! | path! ]
		(
			if path? value [ value: get value ]
			emit [
				either string? value [
					rejoin ["" <script type="text/javascript"> value]
				][
					rejoin [{<script src="} value {">} ]
				]
				close-tag 'script
			]
		)
	]

	; --- header
	; TODO: remove custom rules from header (script, style...)
	; TODO: better META
	; TODO: use EMIT

	page-header: [
		'head 
		(header?: true)
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
		|	google-font

		]
		'body

	]
	
;  ____                _____   _____    _____     ______   _        ______   __  __    _____ 
; |  _ \      /\      / ____| |_   _|  / ____|   |  ____| | |      |  ____| |  \/  |  / ____|
; | |_) |    /  \    | (___     | |   | |        | |__    | |      | |__    | \  / | | (___  
; |  _ <    / /\ \    \___ \    | |   | |        |  __|   | |      |  __|   | |\/| |  \___ \ 
; | |_) |  / ____ \   ____) |  _| |_  | |____    | |____  | |____  | |____  | |  | |  ____) |
; |____/  /_/    \_\ |_____/  |_____|  \_____|   |______| |______| |______| |_|  |_| |_____/ 
;                                                                                            

	br: [ 'br ( emit <br> ) ]
	hr: [ 'hr ( emit <hr> ) ]	

	match-content: [
		set value string!
	|	into [ some elements ]
	]

	paired-tags: [ 'i | 'b | 'p | 'div | 'span | 'small | 'em | 'strong | 'footer | 'nav | 'section | 'button ]
	paired-tag: [
		set name paired-tags 
		init-tag
		opt style
		( emit-tag tag )
		match-content
		pop-tag
		(
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
		pop-tag
		( emit-tag tag )
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
		pop-tag
		(
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
		pop-tag
		(
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
		pop-tag
		( emit close-tag 'ul )
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
		pop-tag
		( emit close-tag 'ol )

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
		pop-tag
		( 
			emit-tag tag
			emit [	
				value
				close-tag tag/element
			]
		)
	]

;  ______    ____    _____    __  __    _____ 
; |  ____|  / __ \  |  __ \  |  \/  |  / ____|
; | |__    | |  | | | |__) | | \  / | | (___  
; |  __|   | |  | | |  _  /  | |\/| |  \___ \ 
; | |      | |__| | | | \ \  | |  | |  ____) |
; |_|       \____/  |_|  \_\ |_|  |_| |_____/ 
;                                             

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
		pop-tag
		(
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
		init-input
		set name word!
		some [
			set value string!
		|	style
		]
		pop-tag
		(
			append tag compose [ type: 'hidden name: (name) value: (value) ] 
			emit-tag tag 
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
		pop-tag
		(
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
		|	password-strength
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
		pop-tag
		( emit-tag tag )
		into [ some form-content ] 
		( emit close-tag 'form )
	]

;  _____    _        _    _    _____   _____   _   _    _____ 
; |  __ \  | |      | |  | |  / ____| |_   _| | \ | |  / ____|
; | |__) | | |      | |  | | | |  __    | |   |  \| | | (___  
; |  ___/  | |      | |  | | | | |_ |   | |   | . ` |  \___ \ 
; | |      | |____  | |__| | | |__| |  _| |_  | |\  |  ____) |
; |_|      |______|  \____/   \_____| |_____| |_| \_| |_____/ 
;                                                             
                                                             
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
		'map 
		set location pair!
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

	google-font: [
		'google-font
		set name string!
		(
			; TODO: character sets
			repend stylesheets [
				{<link href='http://fonts.googleapis.com/css?family=} 
				replace/all name #" " #"+"
				{&subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
			]

		)
	]

	fa-icon: [
		; TODO: add link for font awesome CSS to header
		'fa-icon 
		set name word!
		( emit rejoin [{<i class="fa fa-} name {"></i>}] )
	]

	password-strength: [
		;
		; https://github.com/ablanco/jquery.pwstrength.bootstrap
		;
		; USAGE: 
		;
		; password-strength
		; password-strength username user
		; password-strength username user verdicts ["Slabé" "Normální" "Středně silné" "Silné" "Velmi silné"]
		;
		'password-strength
		( 
			verdicts: ["Weak" "Normal" "Medium" "Strong" "Very Strong"] 
			too-short: "<font color='red'>The Password is too short</font>"
			same-as-user: "Your password cannot be the same as your username"
			username: "username"
		)
		any [
			'username
			set username word!
		|	'verdicts 
			set verdicts block!
		|	'too-short
			set too-short string!
		|	'same-as-user
			set same-as-user string!
		]
		( 
			append add-plugins trim/lines replace-all
{<script type="text/javascript">
	jQuery(document).ready(function () {
		"use strict";
		var options = {
			minChar: 8,
			bootstrap3: true,
			errorMessages: {
			    password_too_short: "<too-short>",
			    same_as_username: "<same-as-user>"
			},
			scores: [17, 26, 40, 50],
			verdicts: [<verdicts>],
			showVerdicts: true,
			showVerdictsInitially: false,
			raisePower: 1.4,
			usernameField: "#<username>",
		};
		$(':password').pwstrength(options);
	});
</script>} 
			[ 
				<verdicts>		(catenate/as-is verdicts ", ")
				<too-short>		too-short
				<same-as-user>	same-as-user
				<username>		username
			]
		)
		
	]

	enable: [
		'enable [
			'bootstrap (
				append add-plugins emit-html [
					script js-path/jquery-1.10.2.min.js
					script js-path/bootstrap.min.js
				]
			)
		|	'smooth-scrolling (
				append add-plugins emit-html [
					script {
					  $(function() {
					    $('a[href*=#]:not([href=#])').click(function() {
					      if (location.pathname.replace(/^^\//,'') == this.pathname.replace(/^^\//,'') && location.hostname == this.hostname) {
	
					        var target = $(this.hash);
					        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
					        if (target.length) {
					          $('html,body').animate({
					            scrollTop: target.offset().top - 40   /* TODO: hardcoded offset, should get real navbar size */
					          }, 1000);
					          return false;
					        }
					      }
					    });
					  });
					}
				]
			)
		|	'pretty-photo (
				append add-plugins emit-html [
					script js-path/jquery.prettyPhoto.js
					script {
					  $(document).ready(function(){
					    $("a[rel^='prettyPhoto']").prettyPhoto();
					  });
					}
				]
			)
		|	'password-strength (
				append add-plugins emit-html [
					script js-path/pwstrength.js
				]
			)
		]
	]

	plugins: [
		ga 					; GOOGLE ANALYTICS
	|	map 				; GOOGLE MAP (TODO: more engines?)
	|	google-font			; GOOGLE FONT
	|	fa-icon				; FONT AWESOME ICON - http://fontawesome.io/icons/
	|	password-strength	; PASSWORD STRENGTH - bootstrap/jquery plugin
	|	enable
	]


	; --- put it all together

	elements: [
		[
			set value string! ( emit value )
		|	page-header	
		|	basic-elems
		|	import
		|	do-code
		|	repeat
		|	user-rules
		|	user-rule
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

;
;  ____     ____     ____    _______    _____   _______   _____               _____  
; |  _ \   / __ \   / __ \  |__   __|  / ____| |__   __| |  __ \      /\     |  __ \ 
; | |_) | | |  | | | |  | |    | |    | (___      | |    | |__) |    /  \    | |__) |
; |  _ <  | |  | | | |  | |    | |     \___ \     | |    |  _  /    / /\ \   |  ___/ 
; | |_) | | |__| | | |__| |    | |     ____) |    | |    | | \ \   / ____ \  | |     
; |____/   \____/   \____/     |_|    |_____/     |_|    |_|  \_\ /_/    \_\ |_|     
;


	bootstrap-elems: [
		grid-elems
	|	col	
	|	glyphicon
	|	dropdown
	|	carousel
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
		opt style
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
			offset: none
		)
		init-tag
		some [
			'offset set offset integer! 
		|	set grid-size [ 'xs | 'sm | 'md | 'lg ] 
		|	set width integer!
		]
		(
			append tag/class rejoin [ "col-" grid-size "-" width ]
			if offset [
				append tag/class rejoin [ "col-" grid-size "-offset-" offset ]
			]
			emit-tag tag
		)
		into [ some elements ]
		close-div
	]

	glyphicon: [
		'glyphicon 
		( size: none )
		some [
			set name word!
		|	set size integer!
		]
		(
			size-att: case [
				size = 1 	( { fa-lg} )
				size 		( rejoin [ { fa-} size {x}] )
				true 		( {} )
			]
			emit rejoin [ {<span class="glyphicon glyphicon-} name size-att {"></span>} ]
		)
	]

	carousel: [
		'carousel
		init-tag
		(
			append tag compose [ 
				element: div
				inner-html: ( copy {} )
				items: 0 
				active: 0
				data-ride: carousel 
				class: [ carousel slide ]
			] 
		)
		set name word! 
		( tag/id: name )
		opt style
		into [ some carousel-item ]
		pop-tag
		(
  			carousel-menu: copy [ ol #carousel-indicators ]
  			repeat i tag/items [
  				repend carousel-menu [
  					'li 'with compose [ 
	  					data-target: ( tag/id )
	  					data-slide-to: ( i - 1 ) 
	  					( either i = tag/active [ [ class: active ] ] [] )
  					]
  					""
  				]
  			]
			data: tag/inner-html
			tag/items:
			tag/active:
			tag/inner-html: none
			emit [
				make-tag tag
				emit-html carousel-menu
				<div class="carousel-inner">
				data
				</div>
				emit-html compose [
					a ( to file! to issue! tag/id ) #left #carousel-control with [ data-slide: prev ] [ glyphicon chevron-left ]
					a ( to file! to issue! tag/id ) #right #carousel-control with [ data-slide: next ] [ glyphicon chevron-right ]
				]
				close-tag 'div
			]
		)
	]

	carousel-item: [
		'item
		( active?: false )
		opt [
			'active
			( active?: true )
		]
		set data block! 
		(
			append tag/inner-html rejoin [
				{<div class="item}
				either active? [ " active" ] [ "" ]
				{">}
				emit-html data
				</div>
			]
			tag/items: tag/items + 1
			if active? [ tag/active: tag/items ]
		)
	]

	dropdown: [
		'dropdown
		init-tag
		copy label string!
		( 
			tag/element: 'div 
			tag/class: [ btn-group ]
			emit [
				make-tag tag
				<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
				label
				<span class="caret"></span>
				</button>
				<ul class="dropdown-menu" role="menu">
			]
		)
		some [
			menu-item
		|	menu-divider	
		]
		( emit close-tag 'ul )
		close-div
	]
	menu-item: [
		set label string!
		set target [ file! | url! ]
		( emit [ {<li><a href="} target {">} label {</a></li>} ] )
	]
	menu-divider: [
		'divider
		( emit [ "" <li class="divider"></li> ] )
	]
	

;  __  __              _____   _   _ 
; |  \/  |     /\     |_   _| | \ | |
; | \  / |    /  \      | |   |  \| |
; | |\/| |   / /\ \     | |   | . ` |
; | |  | |  / ____ \   _| |_  | |\  |
; |_|  |_| /_/    \_\ |_____| |_| \_|
;                                    

	
	main-rule: either with [
		bind custom-rule 'value
	] [
		[
;			opt page-header
			some elements
		]
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
	<body data-spy="scroll" data-target=".navbar">	; WHAT AN UGLY HACK!!!
		body
		add-plugins
	</body>
</html>
		]
	][
		body
	]
]
