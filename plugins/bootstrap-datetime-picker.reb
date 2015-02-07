REBOL[
	Title: "Bootstrap datetime picker plugin for LEST"
	Type: 'lest-plugin
	Name: 'bootstrap-datetime-picker
	Todo: [
	]
]

startup: [
	stylesheet css-path/bootstrap-datetimepicker.min.css 
	insert script js-path/moment.min.js 
	insert script js-path/bootstrap-datetimepicker.min.js 
]

main: [
	(dtp-label: none)
	'bootstrap 'datetime 
	pos:  set value word!
	opt [set dtp-label string!]
	; TODO some options
	(
		id: to issue! join "datetimepicker" random 1000 	; TODO: replace with something sane
		pos/1: compose/deep [
			div .input-group .date (id) [
				simple text (value) with [data-date-format: "DD.MM.YYYY"]
				(either dtp-label [dtp-label] [])
				span .input-group-addon [glyphicon calendar]
			]
			script ( reword/escape {
$(function () {
	$('@id').datetimepicker({
		language: 'cs',
		pickTime: false
	});
});
} ['id id] #"@")
		]
	)
	:pos into main-rule
]