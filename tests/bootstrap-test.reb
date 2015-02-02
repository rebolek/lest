; BOOTSTRAP

[
	equal?
	{<div class="container"><div class="row"><div class="col-md-6">md 6</div></div></div>}
	tf [
		container [
			row [
				col 6 ["md 6"]
			]
		]
	]
]
[
	equal?
	{<div class="container"><div class="row"><div class="col-md-6">md 6</div><div class="col-md-6">md 6</div></div></div>}
	tf [
		container [
			row [
				col 6 ["md 6"]
				col 6 ["md 6"]
			]
		]
	]
]

[ {<span class="glyphicon glyphicon-eye-open"></span>} = tf [ glyphicon eye-open ] ]

[
	equal?
	{<div class="btn-group"><button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">Action<span class="caret"></span></button><ul class="dropdown-menu" role="menu"><li><a href="#">Action</a></li><li><a href="#">Another action</a></li><li><a href="#">Something else here</a></li><li class="divider"></li><li><a href="#">Separated link</a></li></ul></div>}
	tf [
		dropdown "Action"
		"Action" %#
		"Another action" %#
		"Something else here" %#
		divider
		"Separated link" %#
	]
]

[
	equal?
	{<!DOCTYPE html>
<html lang="en-US">
<head>
<title>Page generated with Lest</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="X-UA-Compatible" content="IE=edge">
<link href="css/bootstrap.min.css" rel="stylesheet">
</head>
<body><div class="list-group"><a class="list-group-item active" href="#ahoj">ahoj</a><a class="list-group-item" href="#nazdar">nazdar</a><span class="badge">24</a></div><script src="js/jquery-2.1.0.min.js"></script><script src="js/bootstrap.min.js"></script></body></html>}
	tf [
		link-list 
		link active %#ahoj "ahoj"
		link %#nazdar "nazdar" badge "24"
	]
]