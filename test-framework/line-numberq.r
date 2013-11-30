Rebol [
	Title: "Line number"
	File: %line-numberq.r
	Author: "Ladislav Mecir"
	Purpose: "Compute the line number"
]

line-number?: func [
	s [string! binary!]
	/local t line-number
] [
	line-number: 1
	t: head s
	parse/all t [
		any [
			(if greater-or-equal? index? t index? s [return line-number])
			[[crlf | cr | lf] (line-number: line-number + 1) | skip] t:
		]
	]
]
