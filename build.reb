REBOL[
	Tile: "Lest builder"
]

docs: does [
	lest/save %index.lest
]

module-cache: make block! 10000

preprocess-script: func [
	script-name 	[file!]
	/local cmd file files header script module-file mod-header
] [
	print ["Processing file:" script-name]
;	script: load/header/type script-name 'unbound
	script: load/header script-name
	header: take script
;	files: make block! 10
	; preprocess files from header
	needs: header/needs
	if needs [
		foreach file needs [
			file: to file! join file %.reb
			print [header/name " == needs == " file]	
			module-file: load/header/type file 'unbound
			mod-header: take module-file
			append module-cache compose/deep [
				comment (rejoin ["Import file " file " for " script-name ":" checksum/method to binary! mold module-file 'SHA1]) 
				import module [(body-of mod-header)] [(preprocess-script file module-file)]
			]
		]
	]
	; preprocess files loaded with DO
	parse script [
		some [
			set cmd 'do
			set file file!
			pos:
			(
				print [header/name " == loads == " file]
;				append files file
				replace script reduce [cmd file] preprocess-script file
			)
			:pos
		|	skip
		]
	]
	script
]

script: preprocess-script %lest.reb
print "=============="
forskip module-cache 6 [print ["Inserting..." module-cache/2]]
insert head script module-cache
; process plugins

plugins: read %plugins/
plugin-cache: make block! 2 * length? plugins
foreach plugin plugins [
	repend plugin-cache [
		to word! first parse plugin #"."
		load join %plugins/ plugin
	]
]
insert script compose/deep [
	comment "plugin cache"

	plugin-cache: [(plugin-cache)]
	
	comment "/plugin cache"
]

;save/header %dist/lest.reb script [
;	Title: "Lest (preprocessed)"
;]

build-number: load %build-number
++ build-number
save %build-number build-number

write %dist/lest.reb mold/only head insert script compose/deep [
	REBOL [
		Title: "Lest (processed)"
		Date: (now)
		Build: (build-number)
	]

	debug-print: none ; FIXME: makes problem on server (debug-print no-value), not sure why
]
