; CONFIGURATION: simple test function
[
	function? tf: func [data][parse-page data]
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

