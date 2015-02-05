REBOL[
	Title: "Google Analytics plugin for LEST"
	Type: 'lest-plugin
]

rule: use [value web] [
	[
		; google analytics
		'ga
		set value word!
		set web word!
		(
			debug-print ["==GOOGLE ANALYTICS:" value web]
			append includes/body-end reword {
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', '$value', '$web');
	  ga('send', 'pageview');

	</script>
	} [
		'value value
		'web web
	]
		)
	]
]