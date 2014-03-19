REBOL[
	Title: "Pretty photo plugin for LEST"
	Type: 'lest-plugin
	Name: 'pretty-photo
	Todo: [
		"External files handling"
	]
]

startup: [
	append script js-path/jquery.prettyPhoto.js
	append script {
	  $(document).ready(function(){
	    $("a[rel^='prettyPhoto']").prettyPhoto();
	  });
	}
]