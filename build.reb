REBOL[
	Tile: "Lest builder"
]

preprocess-script: func [
	script-name 	[file!]
	/local cmd file files header
] [
	print ["Processing file:" script-name]
	script: load/header/type script-name 'unbound
	header: take script
;	files: make block! 10
	; preprocess files from header
	needs: header/needs
	if needs [
		foreach file reverse needs [
			file: to file! join file %.reb
			print [header/name " == needs == " file]	
			module-file: load/header/type file 'unbound
			mod-header: take module-file
			insert head script compose/deep [
				comment (rejoin ["Import file " file " for " script-name]) 
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

ps: :preprocess-script

script: ps %lest.reb

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
save/header %dist/lest.reb script [
	Title: "Lest (preprocessed)"
]