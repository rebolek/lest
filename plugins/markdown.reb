REBOL[
	Title: "Markdown plugin for LEST"
	Type: 'lest-plugin
	Name: 'markdown
	Todo: [
		"Won't work, requires external file, that's not in plugins"
	]
]


startup: [
	debug-print "==ENABLE MARKDOWN"
	do %md.reb
]

main-rule: [ 
	'markdown 
	set value string! ( emit markdown value ) 
]