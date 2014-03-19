REBOL[
	Title: "Pretty photo plugin for LEST"
	Type: 'lest-plugin
	Name: 'pretty-photo
	Todo: [
		"External files handling"
	]
]

startup: [
	debug "==ENABLE PRETTY PHOTO"
	append includes/body-end lest [
		script js-path/jquery.prettyPhoto.js
		script {
		  $(document).ready(function(){
		    $("a[rel^='prettyPhoto']").prettyPhoto();
		  });
		}
	]
]