REBOL[
	Title: "Captcha plugin for LEST"
	Type: 'lest-plugin
	Name: 'captcha
	Todo: []
]

main: [
	'captcha set value string! (
		emit reword {
<script type="text/javascript" src="http://www.google.com/recaptcha/api/challenge?k=$public-key"></script>
<noscript>
<iframe src="http://www.google.com/recaptcha/api/noscript?k=$public-key" height="300" width="500" frameborder="0"></iframe>
<br>
<textarea name="recaptcha_challenge_field" rows="3" cols="40"></textarea>
<input type="hidden" name="recaptcha_response_field" value="manual_challenge">
</noscript>
} reduce [ 'public-key value ]
	)
]
