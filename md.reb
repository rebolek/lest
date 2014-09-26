REBOL[
	Title: "Rebol Markdown Parser"
	File: %md.reb
	Author: "Boleslav Březovský"
	Date: 7-3-2014
	Type: 'module
	Exports: [markdown]
	Options: [isolate]
	To-do: [
		"function to produce rule wheter to continue on start-para or not"
	]
	Known-bugs: [
	]
	Notes: ["For mardown specification, see http://johnmacfarlane.net/babelmark2/faq.html"]
]

xml?: true
start-para?: true
end-para?: true
md-buffer: make string! 1000

; FIXME: hacky switch to determine wheter to emit <p> or not (for snippets)

para?: false

set [open-para close-para] either para? [[<p></p>]][["" ""]]

; -----

value: copy "" ; FIXME: leak?

emit: func [data] [
;	print "***wrong emit***" 
	append md-buffer data
]
close-tag: func [tag] [head insert copy tag #"/"]

start-para: does [
	if start-para? [
		start-para?: false 
		end-para?: true
		emit open-para
	]
]

entities: [
	#"<" (emit "&lt;")
|	#">" (emit "&gt;")
|	#"&" (emit "&amp;")
]
escape-set: charset "\`*_{}[]()#+-.!"
escapes: use [escape] [
	[
		#"\"
		(start-para)
		set escape escape-set
		(emit escape)
	]
]
numbers: charset [#"0" - #"9"]
; some "longer, but readable" stuff
plus: #"+"
minus: #"-"
asterisk: #"*"
underscore: #"_"
hash: #"#"
dot: #"."
eq: #"="
lt: #"<"
gt: #">"

header-underscore: use [text tag] [
	[
		copy text to newline 
		newline
		some [eq (tag: <h1>) | minus (tag: <h2>)]
		[newline | end]
		(
			end-para?: false
			start-para?: true
			emit ajoin [tag text close-tag tag]
		)
	]
]

header-hash: use [value continue trailing mark tag] [
	[
		(
			continue: either/only start-para? [not space] [fail]
			mark: clear ""
		)
		continue
		copy mark some hash
		space 
		(emit tag: to tag! compose [h (length? mark)])
		some [
			[
				(trailing: "")
				[[any space mark] | [opt [2 space (trailing: join newline newline)]]]
				[newline | end] 
				(end-para?: false)
				(start-para?: true)
				(emit ajoin [close-tag tag trailing])
			]
			break
		|	set value skip (emit value)	
		]
	]
]

header-rule: [
	header-underscore
|	header-hash	
]

autolink-rule: use [address] [
	[
		lt
		copy address ; TODO: Parse address to match email
		to gt skip
		(
			start-para
			emit ajoin [{<a href="} address {">} address </a>]
		)
	]
]

link-rule: use [text address value title] [
	[
		#"["
		copy text
		to #"]" skip
		#"("
		(
			address: clear ""
			title: none
		)
		any [
			not [space | tab | #")"]
			set value skip
			(append address value)
		]
		opt [
			some [space | tab]
			#"^""
			copy title to #"^""
			skip
		]
		skip
		(
			start-para
			title: either title [ajoin [space {title="} title {"}]][""]
			emit ajoin [{<a href="} address {"} title {>} text </a>]
		)
	]
]

em-rule: use [mark text] [
	[
		copy mark ["**" | "__" | "*" | "_"]
		not space
		copy text
		to mark mark
		(
			start-para
			mark: either equal? length? mark 1 <em> <strong>
			emit ajoin [mark text close-tag mark]
		)
	]
]

img-rule: use [text address] [
	[
		#"!"
		#"["
		copy text
		to #"]" skip
		#"("
		copy address
		to #")" skip
		(
			start-para
			emit ajoin [{<img src="} address {" alt="} text {"} either xml? { /} {} {>}]
		)
	]
]

; TODO: make it bitset!
horizontal-mark: [minus | asterisk | underscore]

horizontal-rule: [
	horizontal-mark
	any space
	horizontal-mark
	any space
	horizontal-mark
	any [
		horizontal-mark
	|	space
	]
	(
		end-para?: false
		emit either xml? <hr /><hr>
	)
]

unordered: [any space [asterisk | plus | minus] space]
ordered: [any space some numbers dot space]

; TODO: recursion for lists

list-rule: use [continue tag item] [
	[
		some [
			(
				continue: either start-para? [
					[
						ordered (item: ordered tag: <ol>)
					|	unordered (item: unordered tag: <ul>)
					]
				] [
					[fail]
				]
			)
			continue
			(start-para?: end-para?: false)
			(emit ajoin [tag newline <li>])
			line-rules
			newline
			(emit ajoin [</li> newline])
			some [
				item
				(emit <li>)
				line-rules
				[newline | end]
				(emit ajoin [</li> newline])
			]
			(emit close-tag tag)
		]
	]
]

blockquote-rule: use [continue] [
	[
		(
			continue: either/only start-para? [gt any space] [fail]
		)
		continue
		(emit ajoin [<blockquote> newline])
		line-rules
		[[newline (emit newline)] | end]
		any [
			; FIXME: what an ugly hack
			[newline ] (remove back tail md-buffer emit ajoin [close-para newline newline open-para])
		|	[
				continue
				opt line-rules
				[newline (emit newline) | end]
			]
		]
		(end-para?: false)
		(emit ajoin [close-para newline </blockquote>])
	]
]

inline-code-rule: use [code value] [
	[
		[
			"``" 
			(start-para)
			(emit <code>)
			some [
				"``" (emit </code>) break ; end rule
			|	entities
			|	set value skip (emit value)
			]
		]
	|	[
			"`"
			(start-para)
			(emit <code>)
			some [
				"`" (emit </code>) break ; end rule
			|	entities
			|	set value skip (emit value)
			]
		]	
	]
]

code-line: use [value][
	[
		some [
			entities
		|	[newline | end] (emit newline) break
		|	set value skip (emit value)	
		]
	]
]

code-rule: use [text] [
	[
		[4 space | tab]
		(emit ajoin [<pre><code>])
		code-line
		any [
			[4 space | tab]
			code-line
		]
		(emit ajoin [</code></pre>])
		(end-para?: false)
	]
]

asterisk-rule: ["\*" (emit "*")]

newline-rule: [
	newline 
	any [space | tab] 
	some newline 
	any [space | tab]
	(
		emit ajoin [close-para newline newline]
		start-para?: true
	)
|	newline (emit newline)	
]

line-break-rule: [
	space
	some space
	newline
	(emit ajoin [either xml? <br /> <br> newline])
]

leading-spaces: use [continue] [
	[
		(continue: either/only start-para? [some space] [fail])
		continue
		(start-para)
	]
]

; simplified rules used as sub-rule in some rules

line-rules: [
	some [
		em-rule
	|	link-rule
	|	header-rule
	|	not newline set value skip (
		start-para
		emit value
	)
	]
]

; main rules

rules: [
;	any space
	some [
		header-rule
	|	link-rule
	|	autolink-rule
	|	img-rule
	|	list-rule
	|	blockquote-rule
	|	inline-code-rule
	|	code-rule
	|	asterisk-rule
	|	em-rule
	|	horizontal-rule
	|	entities
	|	escapes
	|	line-break-rule
	|	newline-rule
	|	end (if end-para? [end-para?: false emit close-para])
	|	leading-spaces
	|	set value skip (
			start-para
			emit value
		)	
	]
]

markdown: func [
	"Parse markdown source to HTML or XHTML"
	data
	; TODO:
	/only "Return result without newlines"
	; TODO:
	/xml "Switch from HTML tags to XML tags (e.g.: <hr /> instead of <hr>)"
] [
	start-para?: true
	end-para?: true
	para?: false
	clear head md-buffer
	probe rules
	parse probe data [some rules]
	md-buffer
]
