REBOL[
	Title: "Smooth scrolling plugin for LEST"
	Type: 'lest-plugin
	Name: 'smooth-scrolling
	Todo: [
		"This plugin requires bootstrap, it should be handled in header"
		"It needs to add some things to BODY tag, now it's hardcoded"
	]
]

startup: [
	debug "==ENABLE SMOOTH SCROLLING"
	; TODO: this expect all controls to be part of UL with ID #page-nav
	; make more generic, but do not break another anchors!!!
	append body [data-spy scroll data-target .navbar]
	append script {
	  $(function() {
	    $('ul#page-nav > li > a[href*=#]:not([href=#])').click(function() {
	      if (location.pathname.replace(/^^\//,'') == this.pathname.replace(/^^\//,'') && location.hostname == this.hostname) {

	        var target = $(this.hash);
	        var navHeight = $("#page-nav").height();

	        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
	        if (target.length) {
	          $('html,body').animate({
	            scrollTop: target.offset().top - navHeight
	          }, 1000);
	          return false;
	        }
	      }
	    });
	  });
	}
]