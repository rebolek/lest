REBOL[
	Title: "Password strength plugin for LEST"
	Type: 'lest-plugin
	Name: 'password-strength
	Todo: []
	Url: https://github.com/ablanco/jquery.pwstrength.bootstrap
	Usage: [
		password-strength
		password-strength username user
		password-strength username user verdicts ["Slabé" "Normální" "Středně silné" "Silné" "Velmi silné"]
	]
]

startup: [
	append script js-path/pwstrength.js
]

rule: use [verdicts too-short same-as-user username] [
	'password-strength
	(
		verdicts: ["Weak" "Normal" "Medium" "Strong" "Very Strong"]
		too-short: "<font color='red'>The Password is too short</font>"
		same-as-user: "Your password cannot be the same as your username"
		username: "username"
	)
	any [
		'username
		set username word!
	|	'verdicts
		set verdicts block!
	|	'too-short
		set too-short string!
	|	'same-as-user
		set same-as-user string!
	]
	(
		append includes/body-end trim/lines reword
{<script type="text/javascript">
jQuery(document).ready(function () {
	"use strict";
	var options = {
		minChar: 8,
		bootstrap3: true,
		errorMessages: {
		    password_too_short: "$too-short",
		    same_as_username: "$same-as-user"
		},
		scores: [17, 26, 40, 50],
		verdicts: [$verdicts],
		showVerdicts: true,
		showVerdictsInitially: false,
		raisePower: 1.4,
		usernameField: "#$username",
	};
	$(':password').pwstrength(options);
});
</script>}
		compose [
			verdicts		(catenate/as-is verdicts ", ")
			too-short		(too-short)
			same-as-user	(same-as-user)
			username		(username)
		]
	)
]
