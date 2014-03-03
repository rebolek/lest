; CONFIGURATION: simple test function
[
	function? tf: func [data][emit-html data]
]

;;-----------------------

; comment

[ {} = tf [ comment [ b "bold" ] ] ]

; paired tags

[ {<div>div</div>}				= tf [ div "div" ] ]
[ {<span>span</span>}			= tf [ span "span"] ]
[ {<b>bold</b>}					= tf [ b "bold" ] ]
[ {<i>italic</i>}				= tf [ i "italic" ] ]
[ {<p>para</p>}					= tf [ p "para" ] ]
[ {<p>para^/with newline</p>}	= tf [ p "para^/with newline" ] ]
[ {<p>para</p>}					= tf [ p [ "para" ] ] ]
[ {<p>paragraph</p>}			= tf [ p [ "para" "graph" ] ] ]
[ {<p><b>para</b>graph</p>}		= tf [ p [ b "para" "graph" ] ] ]
[ {<em>em</em>}					= tf [ em "em" ] ]
[ {<strong>strong</strong>}		= tf [ strong "strong" ] ]
[ {<small>Smallprint</small>}	= tf [ small "Smallprint" ] ]
[ {<footer>footer</footer>}		= tf [ footer "footer" ] ]

; unpaired tags

[ {<br>} = tf [ br ] ]
[ {<hr>} = tf [ hr ] ]

; styles (id & class)

[ {<b id="bold-style">bold</b>} = tf [ b id bold-style "bold" ] ]
[ {<b class="bold-style">bold</b>} = tf [ b #bold-style "bold" ] ]
[ {<b class="bold style">bold</b>} = tf [ b #bold #style "bold" ] ]
[ {<b id="bold-text" class="bold style">bold</b>} = tf [ b id bold-text #bold #style "bold" ] ]

; tag nesting

[ {<b><i>bold italic</i></b>} = tf [ b [ i "bold italic" ] ] ]
[ {<b id="bold"><i id="italic">bold italic</i></b>} = tf [ b id bold [ i id italic "bold italic" ] ] ]
[ {<b class="bold"><i id="italic">bold italic</i></b>} = tf [ b #bold [ i id italic "bold italic" ] ] ]
[ {<b id="bold"><i class="italic">bold italic</i></b>} = tf [ b id bold [ i #italic "bold italic" ] ] ]
[ {<b class="bold"><i class="italic">bold italic</i></b>} = tf [ b #bold [ i #italic "bold italic" ] ] ]
[ {<b class="bold style"><i class="italic">bold italic</i></b>} = tf [ b #bold #style [ i #italic "bold italic" ] ] ]
[ {<b class="bold style"><i class="italic style">bold italic</i></b>} = tf [ b #bold #style [ i #italic #style "bold italic" ] ] ]


; SCRIPT tag

[ {<script src="script.js"></script>} = tf [ script %script.js ] ]
[ {<script src="http://iluminat.cz/script.js"></script>} = tf [ script http://iluminat.cz/script.js ] ]
[ {<script src="script.js"></script>} = tf [ script %script.js ] ]
[ {<script>alert("hello world");</script>} = tf [ script {alert("hello world");} ] ]

; LINK tag

[ {<a href="#">home</a>} = tf [ a %# "home" ] ]
[ {<a href="#">home</a>} = tf [ link %# "home" ] ]
[ {<a href="#about">about</a>} = tf [ link %#about "about" ] ]
[ {<a href="about">about file</a>} = tf [ link %about "about file" ] ]
[ {<a href="http://www.about.at">about web</a>} = tf [ link http://www.about.at "about web" ] ]
[ {<a class="blue" href="#">home</a>} = tf [ link %# #blue "home"] ]
[ {<a id="blue" href="#">home</a>} = tf [ link %# id blue "home"] ]
[ {<a id="blue" class="main" href="#">home</a>} = tf [ link %# id blue #main "home"] ]
[ equal? {<a id="blue" class="main" href="#"><div id="link" class="link-class">home</div></a>}
	tf [
		link %# id blue #main [
			div #link-class id link "home"
		]
	]
]
[ equal? {<div id="outer" class="border"><a id="blue" class="main" href="#"><div id="link" class="link-class">home</div></a></div>}
	tf [
		div id outer #border [
			link %# id blue #main [
				div #link-class id link "home"
			]
		]
	]
]

; IMG tag

[ {<img src="brno.jpg">} = tf [ img %brno.jpg ] ]
[ {<img src="brno.jpg">} = tf [ image %brno.jpg ] ]
[ {<img class="adamov" src="brno.jpg">} = tf [ image %brno.jpg #adamov] ]
[ {<img id="adamov" src="brno.jpg">} = tf [ image id adamov %brno.jpg] ]
[ {<img id="obr" class="adamov" src="brno.jpg">} = tf [ image id obr %brno.jpg #adamov] ]
[ {<img id="obr" class="adamov ivancice" src="brno.jpg">} = tf [ image id obr %brno.jpg #adamov #ivancice ] ]
[ equal?
		{<div id="okraj" class="border small"><img id="obr" class="adamov ivancice" src="brno.jpg"></div>}
		tf [ div #border id okraj #small [image id obr %brno.jpg #adamov #ivancice] ]
]

; LISTS

[ "<ul><li>jedna</li></ul>" = tf [ ul li "jedna" ] ]
[ "<ul><li>jedna</li><li>dva</li></ul>" = tf [ ul li "jedna" li "dva"] ]
[ equal?
	{<ul id="list"><li id="first" class="item">jedna</li><li id="second" class="item">dva</li></ul>}
	tf [ ul id list li #item id first "jedna" li id second #item "dva" ]
]

; HEADINGS

[ {<h1>Brno</h1>} = tf [ h1 "Brno" ] ]
[ {<h2>Brno</h2>} = tf [ h2 "Brno" ] ]
[ {<h3>Brno</h3>} = tf [ h3 "Brno" ] ]
[ {<h4>Brno</h4>} = tf [ h4 "Brno" ] ]
[ {<h5>Brno</h5>} = tf [ h5 "Brno" ] ]
[ {<h6>Brno</h6>} = tf [ h6 "Brno" ] ]
[ {<h1 class="city">Brno</h1>} = tf [ h1 #city "Brno" ] ]
[ {<h2 class="city">Brno</h2>} = tf [ h2 #city "Brno" ] ]
[ {<h3 class="city">Brno</h3>} = tf [ h3 #city "Brno" ] ]
[ {<h4 class="city">Brno</h4>} = tf [ h4 #city "Brno" ] ]
[ {<h5 class="city">Brno</h5>} = tf [ h5 #city "Brno" ] ]
[ {<h6 class="city">Brno</h6>} = tf [ h6 #city "Brno" ] ]
[ {<h1 id="city">Brno</h1>} = tf [ h1 id city "Brno" ] ]
[ {<h2 id="city">Brno</h2>} = tf [ h2 id city "Brno" ] ]
[ {<h3 id="city">Brno</h3>} = tf [ h3 id city "Brno" ] ]
[ {<h4 id="city">Brno</h4>} = tf [ h4 id city "Brno" ] ]
[ {<h5 id="city">Brno</h5>} = tf [ h5 id city "Brno" ] ]
[ {<h6 id="city">Brno</h6>} = tf [ h6 id city "Brno" ] ]

; FORMS

[ equal?
	{<form action="script" method="post" role="form"><div class="form-group"><label for="name">Your name:</label><input class="form-control" type="text" name="name"></div></form>}
	tf [ form %script [ text name "Your name:" ] ]
]
[ equal?
	{<form action="script" method="post" role="form"><div class="form-group"><label for="pass">Password:</label><input class="form-control" type="password" name="pass"></div></form>}
	tf [ form %script [ password pass "Password:" ] ]
]
[ equal?
	{<form action="script" method="post" role="form"><div class="form-group"><label for="mail">Your email:</label><input class="form-control" type="email" name="mail"></div></form>}
	tf [ form %script [ email mail "Your email:" ] ]
]
[ equal?
	{<form action="script" method="post" role="form"><div class="form-group"><label for="name">Your name:</label><input class="form-control" type="text" name="name"></div><div class="form-group"><label for="pass">Password:</label><input class="form-control" type="password" name="pass"></div><div class="form-group"><label for="mail">Your email:</label><input class="form-control" type="email" name="mail"></div></form>}
	tf [
		form %script [
			text name "Your name:"
			password pass "Password:"
			email mail "Your email:"
		]
	]
]
[
	equal?
	{<form action="script" method="post" role="form"><div class="checkbox"><label><input type="checkbox" name="cb1">Check me</label></div></form>}
	tf [ form %script [ checkbox cb1 "Check me" ] ]
]
[
	equal?
	{<form action="script" method="post" role="form"><button type="submit" class="btn btn-default">Bye</button></form>}
	tf [ form %script [ submit "Bye" ] ]
]


; BOOTSTRAP

[
	equal?
	{<div class="container"><div class="row"><div class="col-md-6">md 6</div></div></div>}
	tf [
		container [
			row [
				col 6 ["md 6"]
			]
		]
	]
]
[
	equal?
	{<div class="container"><div class="row"><div class="col-md-6">md 6</div><div class="col-md-6">md 6</div></div></div>}
	tf [
		container [
			row [
				col 6 ["md 6"]
				col 6 ["md 6"]
			]
		]
	]
]

[ {<span class="glyphicon glyphicon-eye-open"></span>} = tf [ glyphicon eye-open ] ]

[
	equal?
	{<div class="btn-group"><button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">Action<span class="caret"></span></button><ul class="dropdown-menu" role="menu"><li><a href="#">Action</a></li><li><a href="#">Another action</a></li><li><a href="#">Something else here</a></li><li class="divider"></li><li><a href="#">Separated link</a></li></ul></div>}
	tf [
		dropdown "Action"
		"Action" %#
		"Another action" %#
		"Something else here" %#
		divider
		"Separated link" %#
	]
]