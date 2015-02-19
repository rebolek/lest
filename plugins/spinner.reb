REBOL[
	Title: "CSS spinner plugin for LEST"
	Type: 'lest-plugin
	Name: 'spinner
	Todo: [
		""
	]
	Note-html: {
<div class="spinner">
  <div class="spinner-container container1">
    <div class="circle1"></div>
    <div class="circle2"></div>
    <div class="circle3"></div>
    <div class="circle4"></div>
  </div>
  <div class="spinner-container container2">
    <div class="circle1"></div>
    <div class="circle2"></div>
    <div class="circle3"></div>
    <div class="circle4"></div>
  </div>
  <div class="spinner-container container3">
    <div class="circle1"></div>
    <div class="circle2"></div>
    <div class="circle3"></div>
    <div class="circle4"></div>
  </div>
</div>		
	}
]

startup: [
	stylesheet css-path/spinner.css
]

main: [
	pos: 'spinner
	(
		debug-print "&&SPINNER"
		out: [
;			spinner-circles: [for i 4 times [div join as class ["spin-circle" i] ""]]
;			spinner-div: style word! [div .spinner-container style spinner-circles]
;			spinner-div .somestyle
;			div .spinner [
;				for i 3 times [spinner-div join as class ["spinner-container" i] ]
;			]

			spinner-circles: [
;				for i 4 times [div join as class ["spin-circle" i] ""]
				div .spin-circle1 ""
				div .spin-circle2 ""
				div .spin-circle3 ""
				div .spin-circle4 ""
			]
			spinner-div: style word! [div .spinner-container style spinner-circles]
			div .spinner [
;				for i 3 times [spinner-div join as class ["spinner-container" i] ]
				spinner-div .spinner-container1
				spinner-div .spinner-container2
				spinner-div .spinner-container3
			]
		]
		change-code pos out
	)
	:pos
	into [match-content]
]