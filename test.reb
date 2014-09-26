REBOL[]

do %test-framework/test-framework.r

test-file: func [
	file
	script
	/local flags result log-file summary script-checksum
] [
	; TODO: invent own flags (low priority)
	set 'flags []

	; calculate script checksum
	script-checksum: checksum/method read script 'sha1

	print "Testing ..."
	result: do-recover file flags script-checksum
	set [log-file summary] result

	print ["Done, see the log file:" log-file]
	print summary
]

home: pwd

print "===Test Lest==="
do %dist/lest.reb
test-file %tests/main-test.reb %dist/lest.reb
change-dir home

halt