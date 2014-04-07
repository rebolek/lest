REBOL[
	Tile: "Lest builder"
]

preprocess-script: func [
	script 	[file!]
	/local cmd file files
] [
	script: load/type script 'unbound
	files: make block! 10
	parse script [
		some [
			set cmd ['do | 'import]
			set file file!
			pos:
			(
				print ["========" file "========"]
				append files file
				replace script probe reduce [cmd file] preprocess-script file
				print ["pos:" copy/part trim/lines mold pos 40]
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
insert script reduce [
	to set-word! 'plugin-cache
	plugin-cache
]
save/header %dist/lest.reb script [
	Title: "Lest (preprocessed)"
]