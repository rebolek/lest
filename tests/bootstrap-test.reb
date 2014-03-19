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
