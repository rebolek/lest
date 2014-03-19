REBOL[
	Title: "Markdown plugin for LEST"
	Type: 'lest-plugin
	Name: 'markdown
	Todo: [
		"Won't work, requires external file, that's not in plugins"
	]
]


startup: [
	debug "==ENABLE MARKDOWN"
	do %md.reb
	add-rule user-rules [ 'markdown set value string! ( emit markdown value ) ]
]