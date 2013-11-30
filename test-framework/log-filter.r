Rebol [
	Title: "Log filter"
	File: %log-filter.r
	Author: "Ladislav Mecir"
	Purpose: "Test framework"
]

do %test-parsing.r

log-filter: func [
	source-log [file!]
	/local source-log-contents target-log
] [
	; if the source log is r_2_7_8_3_1_1DEF65_002052.log
	; the target log will be f_2_7_8_3_1_1DEF65_002052.log
	; , i.e., using the "f" prefix
	target-log: copy source-log
	change target-log %f

	if exists? target-log [delete target-log]

	collect-logs source-log-contents: copy [] source-log

	foreach [source-test source-result] source-log-contents [
		if find [crashed failed] source-result [
			; test failure
			write/append target-log rejoin [
				source-test " " mold source-result newline
			]
		]
	]
]

log-filter to-file system/script/args
