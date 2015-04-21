REBOL [
Title: "Lest (processed)"
Date: 21-Apr-2015/10:19:05+2:00
Build: 908
]
debug-print: none
comment "plugin cache"
plugin-cache: [font-awesome [
startup: [
stylesheet css-path/font-awesome.min.css
]
main: use [tag name fixed? size value size-att] [
[
'fa-icon
init-tag
(
name: none
fixed?: ""
size: none
)
[
'stack set name block!
| set name word!
]
(debug-print ["==FA-ICON:" name])
any [
set size integer!
| 'fixed (fixed?: " fa-fw")
| 'rotate set value integer!
| 'flip set value ['horizontal | 'vertical]
| style
]
take-tag
(
tag: rules/tag
size-att: case [
size = 1 (" fa-lg")
size (rejoin [" fa-" size "x"])
true ("")
]
either word? name [
emit rejoin [{<i class="fa fa-} name size-att fixed? " " tag/class {"></i>}]
] [
emit rejoin [
""
<span class="fa-stack fa-lg">
{<i class="fa fa-} first name " fa-stack-2x" fixed? {">} </i>
{<i class="fa fa-} second name " fa-stack-1x fa-inverse " fixed? catenate tag/class " " {">} </i>
</span>
]
]
)
]
]
] lightbox [
startup: [
stylesheet css-path/bootstrap-lightbox.min.css
insert script js-path/bootstrap-lightbox.min.js
]
] smooth-scrolling [
startup: [
append body [data-spy scroll data-target .navbar]
append script {
^-  $(function() {
^-    $('ul#page-nav > li > a[href*=#]:not([href=#])').click(function() {
^-      if (location.pathname.replace(/^^\//,'') == this.pathname.replace(/^^\//,'') && location.hostname == this.hostname) {

^-        var target = $(this.hash);
^-        var navHeight = $("#page-nav").height();

^-        target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
^-        if (target.length) {
^-          $('html,body').animate({
^-            scrollTop: target.offset().top - navHeight
^-          }, 1000);
^-          return false;
^-        }
^-      }
^-    });
^-  });
^-}
]
] markdown [
startup: [
debug-print "==ENABLE MARKDOWN"
do %md.reb
]
main: [
'markdown
set value string! (emit markdown value)
]
] cgi-actions [] google-maps [
main: [
'map
set location pair!
(
emit ajoin [
{<iframe width="425" height="350" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps?f=q&amp;source=s_q&amp;hl=cs&amp;geocode=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;z=14&amp;ll=} location/x #"," location/y {&amp;output=embed">}
</iframe> <br /> <small>
{<a href="https://maps.google.com/maps?f=q&amp;source=embed&amp;hl=cs&amp;geocode=&amp;aq=&amp;sll=} location/x #"," location/y {&amp;sspn=0.035292,0.066175&amp;t=h&amp;ie=UTF8&amp;hq=&amp;hnear=Mez%C3%ADrka,+Brno,+%C4%8Cesk%C3%A1+republika&amp;z=14&amp;ll=} location/x #"," location/y {" style="color:#0000FF;text-align:left">Zvětšit mapu}
</a> </small>
]
)
]
] wysiwyg [
startup: [
stylesheet css-path/bootstrap-wysihtml5.css
append plugin js-path/wysihtml5-0.3.0.min.js
append plugin js-path/bootstrap3-wysihtml5.js
append plugin "$('.wysiwyg').wysihtml5();"
]
main: [
'wysiwyg (debug-print ["==WYSIWYG matched"])
init-tag
opt style
(
debug-print ["==WYSIWYG"]
tag-name: 'textarea
append tag/class 'wysiwyg
)
emit-tag
end-tag
]
] skeleton [
startup: [
stylesheet css-path/skeleton.css
]
main: [
container
| row
| col
]
grid-elems: rule [type] [
set type ['container | 'row]
init-div
opt style
(insert tag/class type)
emit-tag
eval
match-content
end-tag
]
abs-col: rule [width] [
set width ['one | 'two | 'three | 'four | 'five | 'six | 'seven | 'eight | 'nine | 'ten | 'eleven | 'twelve]
['column | 'columns]
init-div
opt style
(insert tag/class reduce [width 'column])
emit-tag
eval
match-content
end-tag
]
rel-col: rule [width] [
set width ['one-third | 'two-thirds | 'one-half]
init-div
opt style
(insert tag/class reduce [width 'column])
emit-tag
eval
match-content
end-tag
]
col: use [grid-size width offset] [
[
'col
(
grid-size: 'md
width: 2
offset: none
)
init-div
some [
'offset set offset integer!
| set grid-size ['xs | 'sm | 'md | 'lg]
| set width integer!
]
opt style
(
append tag/class rejoin ["col-" grid-size "-" width]
if offset [
append tag/class rejoin ["col-" grid-size "-offset-" offset]
]
)
emit-tag
eval match-content
end-tag
]
]
] test [
startup: [
stylesheet css-path/bootstrap.min.css
append script js-path/jquery-2.1.0.min.js
append script js-path/bootstrap.min.js
]
main: [
set type 'crow
c
opt style
emit-tag
eval
end-tag
]
c: [init-div]
] password-strength [
startup: [
append script js-path/pwstrength.js
]
main: rule [verdicts too-short same-as-user username] [
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
| 'verdicts
set verdicts block!
| 'too-short
set too-short string!
| 'same-as-user
set same-as-user string!
]
(
append includes/body-end trim/lines reword
{<script type="text/javascript">
jQuery(document).ready(function () {
^-"use strict";
^-var options = {
^-^-minChar: 8,
^-^-bootstrap3: true,
^-^-errorMessages: {
^-^-    password_too_short: "$too-short",
^-^-    same_as_username: "$same-as-user"
^-^-},
^-^-scores: [17, 26, 40, 50],
^-^-verdicts: [$verdicts],
^-^-showVerdicts: true,
^-^-showVerdictsInitially: false,
^-^-raisePower: 1.4,
^-^-usernameField: "#$username",
^-};
^-$(':password').pwstrength(options);
});
</script>}
compose [
verdicts (catenate/as-is verdicts ", ")
too-short (too-short)
same-as-user (same-as-user)
username (username)
]
)
]
] bootstrap [
startup: [
stylesheet css-path/bootstrap.min.css
insert script js-path/jquery-2.1.3.min.js
insert script js-path/bootstrap.min.js
insert script js-path/validator.min.js
meta viewport "width=device-width, initial-scale=1"
meta http-equiv: X-UA-Compatible "IE=edge"
]
main: [
grid-elems
| col
| bar
| make-row
| panel
| glyphicon
| address
| dropdown
| carousel
| modal
| navbar
| link-list-group
| end
]
grid-elems: [
set type ['row | 'container]
opt ['fluid (type: 'container-fluid)]
init-div
opt style
(insert tag/class type)
emit-tag
eval
match-content
end-tag
]
col: use [grid-size width offset] [
[
'col
(
grid-size: 'md
width: 2
offset: none
)
init-div
some [
'offset set offset integer!
| set grid-size ['xs | 'sm | 'md | 'lg]
| set width integer!
]
opt style
(
append tag/class rejoin ["col-" grid-size "-" width]
if offset [
append tag/class rejoin ["col-" grid-size "-offset-" offset]
]
)
emit-tag
eval match-content
end-tag
]
]
bar: ['bar]
panel: [
'panel
(
tag-name: 'div
panel-type: 'default
)
init-tag
opt [
[not ['heading | 'footer]]
and
[set panel-type word!]
skip
]
(
repend tag/class [
'panel
to word! join 'panel- panel-type
]
)
emit-tag
any [
[
'heading
init-div
(append tag/class 'panel-heading)
emit-tag
[
set value string!
(value-to-emit: ajoin [<h3 class="panel-title"> value </h3>])
emit-value
| into [some elements]
]
end-tag
]
| [
'footer
init-div
(append tag/class 'panel-footer)
emit-tag
into [some elements]
end-tag
]
]
init-div
(append tag/class 'panel-body)
emit-tag
match-content
end-tag
end-tag
]
glyphicon: [
'glyphicon
set name word!
(tag-name: 'span)
init-tag
(
debug-print ["==GLYPHICON: " name]
repend tag/class ['glyphicon join 'glyphicon- name]
)
emit-tag
end-tag
]
address: [
'address
(
value-to-emit: <address>
first-line?: true
)
emit-value
into [
some [
set value string! (
value-to-emit: rejoin either first-line? [
first-line?: false
["" <strong> value </strong> <br>]
] [
[value <br>]
]
)
emit-value
| 'email set value string! (
value-to-emit: rejoin [{<a href="mailto:} value {">} value </a> <br>]
)
emit-value
| 'phone set value string! (
value-to-emit: rejoin ["" <abbr title="Telefon"> "Tel: " </abbr> value <br>]
)
emit-value
]
]
(value-to-emit: </address>)
emit-value
]
navbar: [
'navbar
init-div
(
append tag/class [navbar navbar-default navbar-fixed-top]
append tag [role: navigation]
)
any [
'inverse (append tag/class 'navbar-inverse)
| style
]
emit-tag
(value-to-emit: [<div class="container-fluid">])
emit-value
opt navbar-brand
(
value-to-emit: [
<div class="navbar-collapse collapse" id="page-nav">
<ul class="nav navbar-nav">
]
)
emit-value
[some navbar-content | into some navbar-content]
(value-to-emit: [</ul>])
emit-value
opt [
'right
(value-to-emit: [<ul class="nav navbar-nav navbar-right">])
emit-value
[some navbar-content | into some navbar-content]
(value-to-emit: [</ul>])
emit-value
]
(value-to-emit: [</div> </div>])
emit-value
end-tag
]
navbar-brand: [
'brand
set value string!
(
value-to-emit: ajoin [
<div class="navbar-header">
<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#page-nav">
<span class="sr-only"> "Toggle navigation" </span>
<span class="icon-bar"> </span>
<span class="icon-bar"> </span>
<span class="icon-bar"> </span>
</button>
<a class="navbar-brand" href="#"> value </a>
</div>
]
)
emit-value
]
navbar-link: [
'link
(active?: false)
(tag-name: 'li)
init-tag
opt ['active (active?: true)]
some [
set target [file! | url! | issue!]
| set value [string! | block!]
| style
]
(if active? [append tag/class 'active])
emit-tag
pos:
(
pos: back pos
pos/1: reduce ['link target value]
)
:pos
into [elements]
end-tag
]
navbar-content: [
opt commands
opt [navbar-link | form-rule]
]
carousel: [
'carousel
init-tag
(
debug-print "==CAROUSEL"
tag-name: 'div
append tag compose [
inner-html: (copy "")
items: 0
active: 0
data-ride: carousel
class: [carousel slide]
]
carousel-menu: none
)
set name word!
(tag/id: name)
any [
style
| 'no 'indicators (carousel-menu: false)
| 'indicators set carousel-menu block!
]
into [some carousel-item]
take-tag
(
if none? carousel-menu [
carousel-menu: copy [ol #carousel-indicators]
repeat i tag/items [
append carousel-menu reduce [
'li 'with compose [
data-target: (to issue! tag/id)
data-slide-to: (i - 1)
(either i = tag/active [[class: active]] [])
]
""
]
]
]
data: tag/inner-html
tag/items:
tag/active:
tag/inner-html: none
value-to-emit: [
build-tag tag-name tag
either carousel-menu [
lest carousel-menu
] [
""
]
<div class="carousel-inner">
data
</div>
lest compose [
a (to file! to issue! tag/id) #left #carousel-control with [data-slide: prev] [glyphicon chevron-left]
a (to file! to issue! tag/id) #right #carousel-control with [data-slide: next] [glyphicon chevron-right]
]
close-tag 'div
]
)
emit-value
]
carousel-item: [
'item
(active?: false)
opt [
'active
(active?: true)
]
set data block!
(
append tag/inner-html rejoin [
{<div class="item}
either active? [" active"] [""]
{">}
lest data
</div>
]
tag/items: tag/items + 1
if active? [tag/active: tag/items]
)
]
dropdown: [
'dropdown
init-div
copy label string!
(
tag/class: [btn-group]
value-to-emit: [
build-tag tag-name tag
<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
label
<span class="caret"> </span>
</button>
<ul class="dropdown-menu" role="menu">
]
)
emit-value
some [
menu-item
| menu-divider
]
(value-to-emit: close-tag 'ul)
emit-value
end-tag
]
menu-item: [
set label string!
set target [file! | url!]
(value-to-emit: [{<li><a href="} target {">} label "</a></li>"])
emit-value
]
menu-divider: [
'divider
(value-to-emit: ["" <li class="divider"> </li>])
emit-value
]
modal: [
'modal
init-tag
(label: 'modal-label)
set name word!
opt ['label set label word!]
(
debug-print "==MODAL"
tag-name: 'div
tag/id: name
append tag/class [modal fade]
append tag [
tabindex: -1
role: dialog
aria-labelledby: label
aria-hidden: true
]
)
emit-tag
init-div
(append tag/class 'modal-dialog)
emit-tag
init-div
(append tag/class 'modal-content)
emit-tag
opt modal-header
modal-body
opt modal-footer
end-tag
end-tag
end-tag
]
modal-header: [
'header
init-div
(
append tag/class 'modal-header
value-to-emit: [
build-tag tag-name tag
<button type="button" class="close" data-dismiss="modal" aria-hidden="true">
"&times;"
</button>
]
)
emit-value
into [some elements]
end-tag
]
modal-body: [
opt 'body
init-div
(append tag/class 'modal-body)
emit-tag
into [some elements]
end-tag
]
modal-footer: [
'header
init-div
(append tag/class 'modal-footer)
emit-tag
into [some elements]
end-tag
]
list-badge: [
'badge
(tag-name: 'span)
init-tag
(append tag/class 'badge)
emit-tag
content-rule
end-tag
]
link-list-content: [
any [
'link
(print "==LINK-LIST LINK")
(tag-name: 'a)
init-tag
(append tag/class 'list-group-item)
opt ['active (append tag/class 'active)]
eval
set value [file! | url! | issue!]
(append tag compose [href: (value)])
emit-tag
eval
match-content
opt list-badge
end-tag
]
]
link-list-group: [
'link-list
(print "==LINK-LIST")
init-div
(append tag/class 'list-group)
emit-tag
pos: (print [">>" mold pos])
(print "BE LAZY" local lazy? true)
eval
pos: (print [">>" mold pos])
[into link-list-content | link-list-content]
(print "DONT BE LAZY" local lazy? false)
end-tag
]
old-link-list-group: [
'link-list
init-div
(append tag/class 'list-group)
emit-tag
any [
'link
opt [
'active
pos:
(
remove back pos
insert pos '.active
pos: back pos
)
:pos
]
pos:
(
insert next pos '.list-group-item
pos: back pos
)
:pos
link
opt list-badge
]
end-tag
]
make-row: [
'row
'with
(
index: 1
offset: none
)
some [
set cols integer!
['col | 'cols]
| 'offset
set offset integer!
]
set element block!
'replace
set value get-word!
[
'from
set data pos: [block! | word! | file! | url!]
(
out: make block! length? data
switch type?/word data [
word! [data: get data]
url! [data: read data]
file! [data: load data]
]
foreach item data [
current: copy/deep element
replace-deep current value item
if offset [
insert skip find current 'col 2 reduce ['offset offset]
offset: none
]
append out current
]
change/only pos compose/deep [row [(out)]]
)
:pos into main-rule
| 'with
pos: set data block!
(
out: make block! length? data
repeat index cols [
current: copy/deep element
replace-deep current value do bind data 'index
if offset [
insert skip find current 'col 2 reduce ['offset offset]
offset: none
]
append out current
]
change/only pos compose/deep [row [(out)]]
)
:pos into main-rule
]
]
] google-analytics [
main: rule [value web] [
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
] paypal [
main: rule [id] [
'paypal
set id issue!
(
emit reword {<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="$ID">
<input type="image" src="https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
<img alt="" border="0" src="https://www.paypalobjects.com/en_US/i/scr/pixel.gif" width="1" height="1">
</form>} ['ID next form id]
)
]
] redis [
startup: [
run redis-path
]
main: [
'redis [
open-conn
| use-conn
| send-command
]
]
redis-conn: none
open-conn: [
'open eval set server url!
(redis-conn: open server)
]
use-conn: [
'use eval set server word!
(
redis-conn: get server
)
]
send-command: [
(quiet?: false)
opt ['quiet (quiet?: true)]
pos: set cmd block!
(
pos/1: send-redis redis-conn bind cmd user-words
if quiet? [pos/1: ""]
)
:pos
]
] google-font [
startup: [
stylesheet css-path/bootstrap.min.css
]
main: [
'google-font
set name string!
(
debug-print ["==GFONT:" name]
repend includes/header [
{<link href='http://fonts.googleapis.com/css?family=}
replace/all name #" " #"+"
{:400,300&amp;subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
]
repend includes/style ['google 'fonts name #400]
)
]
] spinner [
startup: [
stylesheet css-path/spinner.css
]
main: [
pos: 'spinner
(
debug-print "&&SPINNER"
out: [
spinner-circles: [
div .spin-circle1 ""
div .spin-circle2 ""
div .spin-circle3 ""
div .spin-circle4 ""
]
spinner-div: style word! [div .spinner-container style spinner-circles]
div .spinner [
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
] captcha [
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
} reduce ['public-key value]
)
]
] pretty-photo [
startup: [
append script js-path/jquery.prettyPhoto.js
append script {
^-  $(document).ready(function(){
^-    $("a[rel='prettyPhoto']").prettyPhoto();
^-  });
^-}
]
] bootstrap-datetime-picker [
startup: [
stylesheet css-path/bootstrap-datetimepicker.min.css
insert script js-path/moment.min.js
insert script js-path/bootstrap-datetimepicker.min.js
]
main: [
(dtp-label: none)
'bootstrap 'datetime
pos: set value word!
opt [set dtp-label string!]
(
id: to issue! join "datetimepicker" random 1000
pos/1: compose/deep [
div .input-group .date (id) [
simple text (value) with [data-date-format: "DD.MM.YYYY"]
(either dtp-label [dtp-label] [])
span .input-group-addon [glyphicon calendar]
]
script (reword/escape {
$(function () {
^-$('@id').datetimepicker({
^-^-language: 'cs',
^-^-pickTime: false
^-});
});
} ['id id] #"@")
]
)
:pos into main-rule
]
]]
comment "/plugin cache"
comment {Import file colorspaces.reb for prestyle.reb (partial checksum: n58R8m3k)}
import module [
title: "Colorspaces"
name: none
type: module
version: 0.0.1
date: 3-Apr-2014
file: %colorspaces.reb
author: "Boleslav Březovský"
needs: none
options: none
checksum: none
Exports: [
load-web-color load-hsl load-hsv
to-hsl to-hsv
new-color set-color apply-color
]
] [
load-web-color: func [
"Convert hex RGB issue! value to tuple!"
color [issue!]
/local pos
] [
to tuple! debase/base next form color 16
]
to-hsl: func [
color [tuple!]
/local min max delta alpha total
] [
if color/4 [alpha: color/4 / 255]
color: reduce [color/1 color/2 color/3]
bind/new [r g b] local: object []
set words-of local map-each c color [c / 255]
color: local
min: first minimum-of values-of color
max: first maximum-of values-of color
delta: max - min
total: max + min
local: object [h: s: l: to percent! total / 2]
do in local bind [
either zero? delta [h: s: 0] [
s: to percent! either l > 0.5 [2 - max - min] [delta / total]
h: 60 * switch max reduce [
r [g - b / delta + either g < b 6 0]
g [b - r / delta + 2]
b [r - g / delta + 4]
]
]
] color
local: values-of local
if alpha [append local alpha]
local
]
to-hsv: func [
color [tuple!]
/local min max delta alpha
] [
if color/4 [alpha: color/4 / 255]
color: reduce [color/1 color/2 color/3]
bind/new [r g b] local: object []
set words-of local map-each c color [c / 255]
color: local
min: first minimum-of values-of color
max: first maximum-of values-of color
delta: max - min
local: object [h: s: v: to percent! max]
do in local bind [
either zero? delta [h: s: 0] [
s: to percent! either delta = 0 [0] [delta / max]
h: 60 * switch max reduce [
r [g - b / delta + either g < b 6 0]
g [b - r / delta + 2]
b [r - g / delta + 4]
]
]
] color
local: values-of local
if alpha [append local alpha]
local
]
load-hsl: func [
color [block!]
/local alpha c x m i
] [
if color/4 [alpha: color/4]
bind/new [h s l] local: object []
set words-of local color
bind/new [r g b] color: object []
do in local [
i: h / 60
c: 1 - (abs 2 * l - 1) * s
x: 1 - (abs -1 + mod i 2) * c
m: l - (c / 2)
]
do in color [
set [r g b] reduce switch to integer! i [
0 [[c x 0]]
1 [[x c 0]]
2 [[0 c x]]
3 [[0 x c]]
4 [[x 0 c]]
5 [[c 0 x]]
]
]
color: to tuple! map-each value values-of color [to integer! round m + value * 255]
if alpha [color/4: alpha * 255]
color
]
load-hsv: func [
color [block!]
/local alpha c x m i
] [
if color/4 [alpha: color/4]
bind/new [h s v] local: object []
set words-of local color
bind/new [r g b] color: object []
do in local [
i: h / 60
c: v * s
x: 1 - (abs -1 + mod i 2) * c
m: v - c
]
do in color [
set [r g b] reduce switch to integer! i [
0 [[c x 0]]
1 [[x c 0]]
2 [[0 c x]]
3 [[0 x c]]
4 [[x 0 c]]
5 [[c 0 x]]
]
]
color: to tuple! map-each value values-of color [to integer! round m + value * 255]
if alpha [color/4: alpha * 255]
color
]
color!: object [
rgb: 0.0.0.0
web: #000000
hsl: make block! 4
hsv: make block! 4
]
new-color: does [make color! []]
set-color: func [
color [object!] "Color object"
value [block! tuple! issue!]
type [word!]
] [
switch type [
rgb [
do in color [
rgb: value
web: to-hex value
hsl: to-hsl value
hsv: to-hsv value
]
]
web [
do in color [
rgb: load-web-color value
web: value
hsl: to-hsl rgb
hsv: to-hsv rgb
]
]
hsl [
do in color [
rgb: load-hsl value
web: to-hex rgb
hsl: value
hsv: to-hsv load-hsv value
]
]
hsv [
do in color [
rgb: load-hsv value
web: to-hex rgb
hsl: to-hsl load-hsv value
hsv: value
]
]
]
color
]
apply-color: func [
"Apply color effect on color"
color [object!] "Color! object"
effect [word!] "Effect to apply"
amount [number!] "Effect amount"
] [
effect: do bind select effects effect 'amount
set-color color color/:effect effect
]
effects: [
darken [
color/hsl/3: max 000% color/hsl/3 - amount
'hsl
]
lighten [
color/hsl/3: min 100% color/hsl/3 + amount
'hsl
]
saturate [
color/hsl/2: min 100% max 000% color/hsl/2 + amount
'hsl
]
desaturate [
color/hsl/2: min 100% max 000% color/hsl/2 - amount
'hsl
]
hue [
color/hsl/1: color/hsl/1 + amount // 360
'hsl
]
]
]
comment {Import file styletalk.reb for prestyle.reb (partial checksum: nDdNpnBa)}
import module [
title: "StyleTalk"
name: styletalk
type: module
version: 0.2.1
date: 17-Jun-2013
file: none
author: "Christopher Ross-Gill"
needs: none
options: none
checksum: none
Purpose: "Compact Style Sheets in Rebol"
Exports: [to-css]
] [
to-css: use [ruleset parser ??] [
ruleset: context [
values: copy []
unset: func [key [word!]] [remove-each [k value] values [k = key]]
set: func [key [word!] value [any-type!]] [
unset key repend values [key value]
]
colors: copy []
lengths: copy []
transitions: copy []
transformations: copy []
enspace: func [value] [join " " value]
form-color: func [value [tuple! word!]] [
enspace either value/4 [
["rgba(" value/1 "," value/2 "," value/3 "," either integer? value: value/4 / 255 [value] [round/to value 0.01] ")"]
] [
["rgb(" value/1 "," value/2 "," value/3 ")"]
]
]
form-number: func [value [number!] unit [word! string! none!]] [
enspace case [
value = 0 ["0"]
unit [join value unit]
value [form value]
]
]
form-value: func [values /local value choices] [
any [
switch value: take values [
em pt px deg vw vh [form-number take values value]
pct [form-number take values "%"]
* [form-number take values none]
| [","]
radial [enspace ["radial-gradient(" remove form-values values ")"]]
linear [enspace ["linear-gradient(" remove form-values values ")"]]
]
switch type?/word value [
integer! decimal! [form-number value 'px]
pair! [rejoin [form-number value/x 'px form-number value/y 'px]]
time! [form-number value/second 's]
tuple! [form-color value]
string! [enspace mold value]
url! file! [enspace ["url('" value "')"]]
path! [enspace [{url("data:} form value ";base64," enbase/base take values 64 {")}]]
]
enspace value
]
]
form-transform: func [transform [block!] /local name direction] [
switch/default take transform [
translate [
enspace [
"translate" uppercase form take transform
"(" next form-value transform ")"
]
]
rotate [
enspace ["rotate(" next form-value transform ")"]
]
scale [
enspace [
"scale" either word? transform/1 [uppercase form take transform] [""]
"(" next form-number take transform none either tail? transform [""] [
"," form-number take transform none
] ")"
]
]
] [keep mold head insert transform name]
]
form-values: func [values [block!]] [
rejoin collect [
while [not tail? values] [keep form-value values]
]
]
form-property: func [property [word!] values [string! block!] /vendors /inline prefix] [
if block? values [values: form-values values]
rejoin collect [
if any [vendors found? find [transition box-sizing transform-style transition-delay] property] [
foreach prefix [-webkit- -moz- -ms- -o-] [
keep form-property to word! join prefix form property values
]
]
if prefix [insert next values prefix]
keep ["^/^-" property ":" values ";"]
]
]
render: has [value] [
while [value: take lengths] [
value: compose [(value)]
case [
not find values 'width [set 'width value]
not find values 'height [set 'height value]
]
]
while [value: take colors] [
value: compose [(value)]
case [
not find values 'color [set 'color value]
not find values 'background-color [set 'background-color value]
]
]
rejoin collect [
keep "{"
foreach [property values] values [
case [
find [opacity] property [
if tail? next values [insert values '*]
]
all [
property = 'background-image
find [radial linear] values/1
] [
foreach prefix [-webkit- -moz- -ms- -o-] [
keep form-property/inline property copy values prefix
]
]
]
switch/default property [] [
keep form-property property values
]
]
foreach transform transformations [
transform: form-transform transform
keep form-property/vendors 'transform transform
]
unless empty? transitions [
keep form-property/vendors 'transition rejoin next collect [
foreach transition transitions [
keep ","
keep form-values transition
]
]
]
keep "^/}"
]
]
new: does [
make self [
values: copy []
colors: copy []
lengths: copy []
transitions: copy []
transformations: copy []
spacing: copy []
]
]
]
parser: context [
google-fonts-base-url: http://fonts.googleapis.com/css?family=
reset?: false
rules: []
google-fonts: []
zero: use [zero] [
[set zero integer! (zero: either zero? zero [[]] [[end skip]]) zero]
]
em: ['em number! | zero]
pt: ['pt number!]
px: [opt 'px number!]
deg: ['deg number! | zero]
scalar: ['* number! | zero]
percent: ['pct number! | zero]
vh: ['vh number! | zero]
vw: ['vw number! | zero]
color: [tuple! | named-color | 'transparent]
time: [time!]
pair: [pair!]
binary: [end skip]
image: [binary | file! | url!]
named-color: [
'aqua | 'black | 'blue | 'fuchsia | 'gray | 'green |
'lime | 'maroon | 'navy | 'olive | 'orange | 'purple |
'red | 'silver | 'teal | 'white | 'yellow
]
text-style: ['bold | 'italic | 'underline]
overflow-style: [
'visible | 'hidden | 'scroll | 'auto | 'initial | 'inherit
]
border-style: [
'none | 'hidden | 'dotted | 'dashed | 'solid | 'double |
'groove | 'ridge | 'inset | 'outset | 'initial
]
transition-attribute: [
'width | 'height | 'top | 'bottom | 'right | 'left | 'z-index
| 'background | 'color | 'border | 'opacity | 'margin
| 'transform | 'font | 'indent | 'spacing
]
list-styles: [
'disc | 'circle | 'square | 'decimal | 'decimal-leading-zero
| 'lower-roman | 'upper-roman | 'lower-greek | 'lower-latin
| 'upper-latin | 'armenian | 'georgian | 'lower-alpha | 'upper-alpha
]
direction: ['x | 'y | 'z]
position-x: ['right | 'left | 'center]
position-y: ['top | 'bottom | 'middle | 'center]
position: [position-y | position-x]
positions: [position-x position-y | position-y position-x | position-y | position-x]
repeats: ['repeat-x | 'repeat-y | 'repeat ['x | 'y] | 'no-repeat | 'no 'repeat]
font-name: [string! | 'sans-serif | 'serif | 'monospace]
length: [em | pt | px | percent | vh | vw]
angle: [deg]
number: [scalar | number!]
box-model: ['block | 'inline 'block | 'inline-block]
mark: capture: captured: none
use [start extent] [
mark: [start:]
capture: [extent: (new-line/all captured: copy/part start extent false)]
]
emit: func [name [word!] value [any-type!]] [
value: compose [(value)]
foreach [from to] [
[no repeat] 'no-repeat
[no bold] 'normal
[no italic] 'normal
[no underline] 'none
[inline block] 'inline-block
[line height] 'line-height
] [
replace value from to
]
current/set name value
]
emits: func [name [word!]] [
emit name captured
]
selector: use [
dot-word primary qualifier
form-element form-selectors
out selectors selector
] [
dot-word: use [word continue] [
[
set word word!
(continue: either #"." = take form word [[]] [[end skip]])
continue
]
]
primary: [tag! | issue! | dot-word]
qualifier: [primary | get-word!]
form-element: func [element [tag! issue! word! get-word!]] [
either tag? element [to string! element] [mold element]
]
form-selectors: func [selectors [block!]] [
selectors: collect [
parse selectors [
some [mark some qualifier capture (keep/only captured)
| word! capture (keep captured)
]
]
]
selectors: collect [
while [find selectors 'and] [
keep/only copy/part selectors selectors: find selectors 'and
selectors: next selectors
] keep/only copy selectors
]
selectors: map-each selector selectors [
collect [
foreach selector reverse collect [
while [find selector 'in] [
keep/only copy/part selector selector: find selector 'in
keep 'has
selector: next selector
] keep/only copy selector
] [keep selector]
]
]
selectors: collect [
foreach selector selectors [
parse selector [
set selector block! (selector: map-each element selector [form-element element])
any [
'with mark block! capture (
selector: collect [
foreach selector selector [
foreach element captured/1 [
keep join selector form-element element
]
]
]
) |
'has mark block! capture (
selector: collect [
foreach selector selector [
foreach element captured/1 [
keep rejoin [selector " " form-element element]
]
]
]
)
]
]
keep/only selector
]
]
rejoin remove collect [
foreach selector selectors [
foreach rule selector [
keep "," keep "^/"
keep rule
]
]
]
]
selector: [
some primary any [
'with some qualifier
| 'in some primary
| 'and selector
]
]
[
mark
some primary any [
'with some qualifier
| 'in some primary
| 'and selector
] capture
(repend rules [form-selectors captured current: ruleset/new])
]
]
property: [
mark box-model capture (emits 'display)
| 'z-index mark number capture (emits 'z-index)
| 'content mark string! capture (emits 'content)
| mark 'border-box capture (emits 'box-sizing)
| 'min some [
'width mark length capture (emits 'min-width)
| 'height mark length capture (emits 'min-height)
]
| 'max some [
'width mark length capture (emits 'max-width)
| 'height mark length capture (emits 'max-height)
]
| mark ['min-width | 'min-height | 'max-width | 'max-height] length capture (emits take captured)
| 'height mark [length | 'auto] capture (emits 'height)
| 'width mark [length | 'auto] capture (emits 'width)
| 'margin [
mark [
1 2 [length opt [length | 'auto]]
| pair opt [length | pair]
] capture (emits 'margin)
|
] any [
'top mark length capture (emits 'margin-top)
| 'bottom mark length capture (emits 'margin-bottom)
| 'right mark [length | 'auto] capture (emits 'margin-right)
| 'left mark [length | 'auto] capture (emits 'margin-left)
]
| 'padding [
mark [
1 4 length
| pair opt [length | pair]
] capture (emits 'padding)
|
] any [
'top mark length capture (emits 'padding-top)
| 'bottom mark length capture (emits 'padding-bottom)
| 'right mark [length | 'auto] capture (emits 'padding-right)
| 'left mark [length | 'auto] capture (emits 'padding-left)
]
| 'border any [
mark 1 4 border-style capture (emits 'border-style)
| mark 1 4 color capture (emits 'border-color)
| 'top any [
mark length capture (emits 'border-top-width)
| mark border-style capture (emits 'border-top-style)
| mark color capture (emits 'border-top-color)
]
| 'bottom any [
mark length capture (emits 'border-bottom-width)
| mark border-style capture (emits 'border-bottom-style)
| mark color capture (emits 'border-bottom-color)
]
| 'right any [
mark length capture (emits 'border-right-width)
| mark border-style capture (emits 'border-right-style)
| mark color capture (emits 'border-right-color)
]
| 'left any [
mark length capture (emits 'border-left-width)
| mark border-style capture (emits 'border-left-style)
| mark color capture (emits 'border-left-color)
]
| 'radius [
some [
'top mark 1 2 length capture (
emits 'border-top-left-radius
emits 'border-top-right-radius
)
| 'bottom mark 1 2 length capture (
emits 'border-bottom-left-radius
emits 'border-bottom-right-radius
)
| 'right mark 1 2 length capture (
emits 'border-top-right-radius
emits 'border-bottom-right-radius
)
| 'left mark 1 2 length capture (
emits 'border-top-left-radius
emits 'border-bottom-left-radius
)
| 'top 'right mark 1 2 length capture (emits 'border-top-right-radius)
| 'top 'left mark 1 2 length capture (emits 'border-top-left-radius)
| 'bottom 'right mark 1 2 length capture (emits 'border-bottom-right-radius)
| 'bottom 'left mark 1 2 length capture (emits 'border-bottom-left-radius)
]
| mark 1 2 length capture (emits 'border-radius)
]
| mark 1 4 length capture (emits 'border-width)
]
| ['radius | 'rounded] mark length capture (emits 'border-radius)
| 'rounded (emit 'border-radius [em 0.6])
| 'outline any [
mark 1 4 border-style capture (emits 'outline-style)
| mark 1 4 color capture (emits 'outline-color)
| mark 1 4 length capture (emits 'outline-width)
]
| 'overflow mark overflow-style capture (emits 'overflow)
| 'font any [
mark length capture (emits 'font-size)
| mark some font-name capture (
captured
remove head forskip captured 2 [insert captured '|]
emits 'font-family
)
| mark color capture (emits 'color)
| 'line 'height mark number capture (emits 'line-height)
| 'spacing mark number capture (emits 'letter-spacing)
| 'shadow mark pair length color capture (emits 'text-shadow)
| mark ['lighter | 'bolder] capture (emits 'font-weight)
| mark opt 'no 'bold capture (emits 'font-weight)
| mark opt 'no 'italic capture (emits 'font-style)
| mark opt 'no 'underline capture (emits 'text-decoration)
| ['line-through | 'strike 'through] (emit 'text-decoration 'line-through)
]
| 'text 'indent mark length capture (emits 'text-indent)
| 'line 'height mark [length | scalar] capture (emits 'line-height)
| 'spacing mark number capture (emits 'letter-spacing)
| mark opt 'no 'bold capture (emits 'font-weight)
| 'weight mark number capture (emits 'font-weight)
| mark opt 'no 'italic capture (emits 'font-style)
| mark opt 'no 'underline capture (emits 'text-decoration)
| ['line-through | 'strike 'through] (emit 'text-decoration 'line-through)
| 'shadow mark pair length color capture (emits 'box-shadow)
| 'color mark [color | 'inherit] capture (emits 'color)
| mark ['relative | 'absolute | 'fixed] capture (emits 'position) any [
'top mark length capture (emits 'top)
| 'bottom mark length capture (emits 'bottom)
| 'right mark length capture (emits 'right)
| 'left mark length capture (emits 'left)
]
| 'opacity mark number capture (emits 'opacity)
| mark 'nowrap capture (emits 'white-space)
| mark 'center capture (emits 'text-align)
| 'transition any [
mark transition-attribute time opt time capture (
append/only current/transitions captured
)
]
| [
'delay mark time capture (emits 'transition-delay)
| mark time opt time transition-attribute capture (
append/only current/transitions head reverse next reverse captured
)
| mark time capture (emits 'transition)
]
| some [
mark [
'translate direction length
| 'rotate angle opt ['origin percent percent]
| 'scale [['x | 'y] number | 1 2 number]
] capture (append/only current/transformations captured)
]
| mark 'preserve-3d capture (emits 'transform-style)
| 'hide (emit 'display none)
| 'float mark ['none | position-x] capture (emits 'float)
| 'opaque (emit 'opacity 1)
| mark 'pointer capture (emits 'cursor)
| ['canvas | 'background] any [
mark color capture (emits 'background-color)
| mark [file! | url!] (emits 'background-image)
| mark positions capture (emits 'background-position)
| mark repeats capture (emits 'background-repeat)
| mark ['contain | 'cover | 1 2 [length | 'auto]] capture (emits 'background-size)
| mark ['scroll | 'fixed | 'local] capture (emits 'background-attachment)
| mark pair capture (
captured: first captured
emit 'background-position reduce [
'pct to integer! captured/x
'pct to integer! captured/y
]
)
]
| mark [
'radial color color capture (
insert at captured 3 '|
)
| 'linear angle color color capture (
insert at tail captured -2 '|
insert at tail captured -1 '|
)
| 'linear opt 'to positions color color capture (
unless 'to = captured/2 [insert next captured 'to]
insert at tail captured -2 '|
insert at tail captured -1 '|
)
] (emits 'background-image)
| mark image capture (emits 'background-image) any [
mark positions capture (emits 'background-position)
| mark pair capture (
captured: first captured
emit 'background-position reduce [
'pct to integer! captured/x
'pct to integer! captured/y
]
)
| mark repeats capture (emits 'background-repeat)
| mark ['contain | 'cover] capture (emits 'background-size)
]
| 'no ['list opt 'style | 'bullet] (emit 'list-style-type 'none)
| opt ['list opt 'style | 'bullet] mark list-styles capture (emits 'list-style-type)
| mark ['inside | 'outside] capture (emits 'list-style-position)
| mark [
length capture (append/only current/lengths captured)
| some color capture (append current/colors captured)
| time capture (emits 'transition)
| pair capture (
emit 'width captured/1/x
emit 'height captured/1/y
)
]
]
current: value: none
errors: copy []
dialect: [()
opt ['css/reset (reset?: true)]
opt [
'google 'fonts [
some [
copy value [string! any issue!]
(append/only google-fonts value)
|
set value url! (
all [
value: find/match value google-fonts-base-url
append google-fonts value
]
)
]
]
]
[selector | (repend rules [["body"] current: ruleset/new])]
any [
selector | property
| set value skip (append errors rejoin ["MISPLACED TOKEN: " mold value])
]
]
reset: to string! decompress #{
789C8D53B16EDB30109DC3AF200C14690D2992DD26838C76EE906EDD8A0CA478
925853A44C520E9C34FFDE47C936DCA2450288E2917CBC7BF7EE582C7917E350
15454F07F28F246F6AD717E4755D44E74C28EA100A4F8162C119E77CBFBE29F9
2FBE2E57AB72B5BE4B5BF7BA261BA8E2D659E2EF87511A5D73E57AA1ED07B62C
18EB626F322E9D3A645CE97DC6C3206CC6C530188A1977F227D59875E3454F19
EB5619EFD6181F313E61DC62DC657C800FE3EAED6E7491B0F4C00AB891D2E35F
7B670F3D0CA5C03700ABDB8CD73A416BA780550416AA4164024EF738D616C0AD
5419DF81153ED10F190BBD308086E8F596A6D95980C328D30F3422D8EE85CF18
3646784104B291B0A152089C2AB874B0470CA333D6388F9846C8C4418E313AD0
28968D26A34212C1504B5665902B0A69126731449D5071162E36CE01173B12F0
1D7D32311434F051D7E98A085A4D37ED5E20194551681352BA92708735BA1D21
1AC77CF69EBC82384F6EA7B9F52EA5C87AB248CD0A94CB8D711811DB8F124402
8A355D0D63DF0B7FC858D4281B87BD058751690775C0C4F1677685DD56DB8A97
1B7635A036DAB6F3423A8F80B3DD381BF3A09FD044ABB27C77DCA9509E0EAD18
B1DE534A52985C18DDC29D14818CB6B4612FAC58F2AFDFBFDDDFA2B7C260C421
F7CE109F9A16E979D40181B8F4EE31900F1C12FFADD859A93F9439AAC5FE27D1
8542474D52C24712D5DCAB895FAA5F3A497CF38E74DB21B5553A993B643E0B50
201ECCF11D4DF72E9A7D9740931DFE05A8242153BA7C209568A68EDC9DCF76F3
56F254435E4A0A5F5F6F2E5627C7530B26DC5CA4BC76C68821BDF193752E608E
B75C9F8AFAC2D8DCDB5595F7EE296F5C3D865C5B9B88688B26FA110F037D5E4C
C5593CBC069B9DBD8EC3CBECF51BFC35DAD0E2817FE16F0BC29F8F4D5A6E4EAD
5B6E8E0D5D6E90EC6F2B11BC2A3F050000
}
render: does [
rejoin collect [
keep "/* StyleTalk Output */^/"
if all [
block? google-fonts
not empty? google-fonts
] [
keep "^/@import url ('"
keep mold join google-fonts-base-url collect [
repeat font length? google-fonts [
unless font = 1 [keep "|"]
case [
url? google-fonts/:font [
keep google-fonts/:font
]
block? google-fonts/:font [
keep replace/all mold to url! take google-fonts/:font "%20" "+"
repeat variant length? google-fonts/:font [
keep back change to url! mold google-fonts/:font/:variant either variant = 1 [":"] [","]
]
]
]
]
]
keep "');^/"
]
if reset? [
keep {
/** CSS Reset Begin */

}
keep reset
keep "/* CSS Reset End **/^/"
]
keep {
/** StyleTalk Output Begin */

}
foreach [selector rule] rules [
keep selector
keep " "
keep rule/render
keep "^/"
]
keep {

/* StyleTalk Output End **/
}
]
]
new: does [
make parser [
reset?: false
google-fonts: copy []
rules: copy []
errors: copy []
current: ruleset/new
value: none
]
]
]
??: use [mark] [[mark: (probe new-line/all copy/part mark 8 false)]]
to-css: func [dialect [file! url! string! block!] /local out] [
case/all [
file? dialect [dialect: load dialect]
url? dialect [dialect: load dialect]
string? dialect [dialect: load dialect]
not block? dialect [make error! "No Dialect!"]
]
out: parser/new
if parse dialect out/dialect [
out/render
]
]
]
]
comment {Import file prestyle.reb for lest.reb (partial checksum: 7dUrKZfd)}
import module [
title: "Styletalk preprocessor"
name: prestyle
type: module
version: 0.0.2
date: 31-Mar-2014
file: %prestyle.reb
author: "Boleslav Březovský"
needs: [colorspaces styletalk]
options: [isolate]
checksum: none
Created: 31-Mar-2014
Exports: [prestyle load-web-color]
Codename: "KSČ"
Email: rebolek@gmail.com
Purpose: {StyleTalk preprocessor. Use variables, block replacements, functions... in CSS. See LESS or SASS.}
To-do: [
#5 {color arithmetics: LESS [@light-blue: @nice-blue + #111;]}
#7 "fadein, fadeout, fade - operations on opacity"
]
Done: [
#0 "Basic passing of arguments"
#1 {Assignment - my-color: 10.20.30 ; usable everywhere, where color is accepted}
#2 {Assignment - bw: [black white] <b> bw == b black white}
#3 "Hash colors - #000000 - 0.0.0"
#4 "Functions - for example: saturate color 50%"
#6 "HSL - is in %colorspaces.reb"
]
] [
rule: func [
"Make PARSE rule with local variables"
local [word! block!] "Local variable(s)"
rule [block!] "PARSE rule"
] [
use local reduce [rule]
]
recat: func [
{Something like COMBINE but with much cooler name, just to piss off @HostileFork.}
block [block!]
/with "Add delimiter between values"
delimiter
/trim "Remove NONE values"
/only "Do not reduce, but that makes no sense"
] [
block: either only [block] [reduce block]
if empty? block [return block]
if trim [block: lib/trim block]
if with [
with: make block! 2 * length? block
foreach value block [repend with [value delimiter]]
block: head remove back tail with
]
append either string? first block [
make string! length? block
] [
make block! length? block
] block
]
buffer: make string! 0
emit: func [data] [
append buffer data
]
color-funcs: [
darken [100% - amount * color]
lighten [white - color * amount + color]
saturate [
color: rgb-hsv color
color/2: min 1.0 max 0.0 color/2 + amount
hsv-rgb color
]
desaturate [
color: rgb-hsv color
color/2: min 1.0 max 0.0 color/2 - amount
hsv-rgb color
]
spin [
color: rgb-hsv color
color/1: color/1 + amount
hsv-rgb color
]
]
get-color: func [color] [
case/all [
word? color [color: user-ctx/:color]
issue? color [color: load-web-color color]
true [color]
]
]
user-ctx: object []
ruleset: object [
user: [fail]
assign: rule [name value] [
set name set-word!
opt functions
set value any-type! (
if word? value [value: get in user-ctx value]
if issue? value [value: load-web-color value]
repend user-ctx [name value]
append user compose [
|
pos: (to lit-word! name)
(
to paren! compose [
change/part pos (to path! reduce ['user-ctx to word! name]) 1
]
)
:pos some rules
]
)
]
functions: rule [f f-stack color amount pos] [
(f-stack: [])
set f ['darken | 'lighten | 'saturate | 'desaturate | 'hue]
(append f-stack f)
opt functions
set color match-color
pos:
set amount number! (
f: take/last f-stack
case/all [
word? color [color: user-ctx/:color]
issue? color [color: load-web-color color]
tuple? color [color: set-color new-color color 'rgb]
true [color: apply-color color f amount]
]
change pos color/rgb
)
:pos
]
em: rule [value] [
'em set value number!
(emit compose [em (value)])
]
canvas: rule [value] [
'canvas
set value match-color
(emit compose [canvas (get-color value)])
]
google-fonts: rule [value values] [
'google 'fonts
(values: make block! 10)
some [
set value [string! | issue!]
(append values value)
]
(emit compose [google fonts (values)])
]
pass: rule [value] [
set value skip
(emit value)
]
match-color: rule [user-words] [
(
user-words: make block! 2 * length? user-ctx
foreach word words-of user-ctx [
repend user-words [to lit-word! word '|]
]
take/last user-words
)
[issue! | tuple! | user-words]
]
]
rules: none
init: does [
buffer: make block! 1000
append clear ruleset/user 'fail
rules: recat/with words-of ruleset '|
]
prestyle: func [
"Process enhanced StyleTalk stylesheets"
data
/only {only translate enhanced stylesheed to standard StyleTalk}
] [
if file? data [data: load data]
init
parse data [some rules]
either only [buffer] [to-css buffer]
]
]
comment {Import file md.reb for lest.reb (partial checksum: k39rOM4n)}
import module [
title: "Rebol Markdown Parser"
name: none
type: module
version: none
date: 7-Mar-2014
file: %md.reb
author: "Boleslav Březovský"
needs: none
options: [isolate]
checksum: none
Exports: [markdown]
To-do: [
{function to produce rule wheter to continue on start-para or not}
]
Known-bugs: []
Notes: [{For mardown specification, see http://johnmacfarlane.net/babelmark2/faq.html}]
] [
xml?: true
start-para?: true
end-para?: true
md-buffer: make string! 1000
debug?: false
debug-print: [value] [print "DBprint" if debug? [print value]]
para?: false
set [open-para close-para] either para? [[<p> </p>]] [["" ""]]
value: copy ""
emit: func [data] [
append md-buffer data
]
close-tag: func [tag] [head insert copy tag #"/"]
start-para: does [
if start-para? [
start-para?: false
end-para?: true
emit open-para
]
]
entities: [
#"<" (emit "&lt;")
| #">" (emit "&gt;")
| #"&" (emit "&amp;")
]
escape-set: charset "\`*_{}[]()#+-.!"
escapes: use [escape] [
[
#"\"
(start-para)
set escape escape-set
(emit escape)
]
]
numbers: charset [#"0" - #"9"]
plus: #"+"
minus: #"-"
asterisk: #"*"
underscore: #"_"
hash: #"#"
dot: #"."
eq: #"="
lt: #"<"
gt: #">"
header-underscore: use [text tag] [
[
copy text to newline
newline
some [eq (tag: <h1>) | minus (tag: <h2>)]
[newline | end]
(
end-para?: false
start-para?: true
emit ajoin [tag text close-tag tag]
)
]
]
header-hash: use [value continue trailing mark tag] [
[
(
continue: either/only start-para? [not space] [fail]
mark: clear ""
)
continue
copy mark some hash
space
(emit tag: to tag! compose [h (length? mark)])
some [
[
(trailing: "")
[[any space mark] | [opt [2 space (trailing: join newline newline)]]]
[newline | end]
(end-para?: false)
(start-para?: true)
(emit ajoin [close-tag tag trailing])
]
break
| set value skip (emit value)
]
]
]
header-rule: [
header-underscore
| header-hash
]
autolink-rule: use [address] [
[
lt
copy address
to gt skip
(
start-para
emit ajoin [{<a href="} address {">} address </a>]
)
]
]
link-rule: use [text address value title] [
[
#"["
copy text
to #"]" skip
#"("
(
address: clear ""
title: none
)
any [
not [space | tab | #")"]
set value skip
(append address value)
]
opt [
some [space | tab]
#"^""
copy title to #"^""
skip
]
skip
(
start-para
title: either title [ajoin [space {title="} title {"}]] [""]
emit ajoin [{<a href="} address {"} title ">" text </a>]
)
]
]
em-rule: use [mark text] [
[
copy mark ["**" | "__" | "*" | "_"]
(debug-print ["== EM rule matched with" mark])
not space
copy text
to mark mark
(
start-para
mark: either equal? length? mark 1 <em> <strong>
emit ajoin [mark text close-tag mark]
)
]
]
img-rule: use [text address] [
[
#"!"
#"["
copy text
to #"]" skip
#"("
copy address
to #")" skip
(
start-para
emit ajoin [{<img src="} address {" alt="} text {"} either xml? " /" "" ">"]
)
]
]
horizontal-mark: [minus | asterisk | underscore]
horizontal-rule: [
horizontal-mark
any space
horizontal-mark
any space
horizontal-mark
any [
horizontal-mark
| space
]
(
end-para?: false
emit either xml? <hr /> <hr>
)
]
unordered: [any space [asterisk | plus | minus] space]
ordered: [any space some numbers dot space]
list-rule: use [continue tag item] [
[
some [
(
continue: either start-para? [
[
ordered (item: ordered tag: <ol>)
| unordered (item: unordered tag: <ul>)
]
] [
[fail]
]
)
continue
(start-para?: end-para?: false)
(emit ajoin [tag newline <li>])
line-rules
newline
(emit ajoin [</li> newline])
some [
item
(emit <li>)
line-rules
[newline | end]
(emit ajoin [</li> newline])
]
(emit close-tag tag)
]
]
]
blockquote-rule: use [continue] [
[
(
continue: either/only start-para? [gt any space] [fail]
)
continue
(emit ajoin [<blockquote> newline])
line-rules
[[newline (emit newline)] | end]
any [
[newline] (remove back tail md-buffer emit ajoin [close-para newline newline open-para])
| [
continue
opt line-rules
[newline (emit newline) | end]
]
]
(end-para?: false)
(emit ajoin [close-para newline </blockquote>])
]
]
inline-code-rule: use [code value] [
[
[
"``"
(start-para)
(emit <code>)
some [
"``" (emit </code>) break
| entities
| set value skip (emit value)
]
]
| [
"`"
(start-para)
(emit <code>)
some [
"`" (emit </code>) break
| entities
| set value skip (emit value)
]
]
]
]
code-line: use [value] [
[
some [
entities
| [newline | end] (emit newline) break
| set value skip (emit value)
]
]
]
code-rule: use [text] [
[
[4 space | tab]
(emit ajoin [<pre> <code>])
code-line
any [
[4 space | tab]
code-line
]
(emit ajoin [</code> </pre>])
(end-para?: false)
]
]
asterisk-rule: ["\*" (emit "*")]
newline-rule: [
newline
any [space | tab]
some newline
any [space | tab]
(
emit ajoin [close-para newline newline]
start-para?: true
)
| newline (emit newline)
]
line-break-rule: [
space
some space
newline
(emit ajoin [either xml? <br /> <br> newline])
]
leading-spaces: use [continue] [
[
(continue: either/only start-para? [some space] [fail])
continue
(start-para)
]
]
line-rules: [
some [
em-rule
| link-rule
| header-rule
| not newline set value skip (
start-para
emit value
)
]
]
sub-rules: [
code-rule
]
rules: [
some [
header-rule
| link-rule
| autolink-rule
| img-rule
| list-rule
| blockquote-rule
| inline-code-rule
| code-rule
| asterisk-rule
| em-rule
| horizontal-rule
| entities
| escapes
| line-break-rule
| newline-rule
| end (if end-para? [end-para?: false emit close-para])
| leading-spaces
| set value skip (
start-para
emit value
)
]
]
markdown: func [
"Parse markdown source to HTML or XHTML"
data
/only "Return result without newlines"
/xml {Switch from HTML tags to XML tags (e.g.: <hr /> instead of <hr>)}
/debug "Turn on debugging"
] [
start-para?: true
end-para?: true
para?: false
debug?: debug
clear head md-buffer
debug-print "** Markdown started"
parse data [some rules]
md-buffer
]
]
comment {Import file compile-rules.reb for lest.reb (partial checksum: d4+4UKb3)}
import module [
title: "COMPILE-RULES with integrated dialect framework"
name: compile-rules
type: module
version: 1.5.0
date: 20-May-2014
file: %compile-rules.reb
author: "Gabriele Santilli"
needs: none
options: [isolate]
checksum: none
EMail: giesse@rebol.it
History: [
13-Jan-2003 1.1.0 "History start"
14-Jan-2003 1.2.0 "First version"
6-Mar-2003 1.3.0 {Integrating PARSE-DIALECT's functionality in COMPILE-RULES}
6-Mar-2003 1.4.0 {First working version of COMPILE-RULES with new INTERPRET rule}
20-May-2014 1.5.0 "Changed for REBOL3 (rebolek)"
]
Purpose: {
        This script defines the COMPILE-RULES function. This function compiles
        an extended PARSE dialect into the normal PARSE dialect. The extended PARSE
        dialect has some new rules; some of them are documented in

             http://www.rebol.it/REPs/PARSE.html

        The INTERPRET rule is not yet documented and handles control and iteration
        functions in your dialect.
    }
Exports: [compile-rules control-functions]
] [
control-functions: none
context [
element: [
set val1 paren! (emit/only :val1)
| into grammar (emit/only last-block)
| 'skip (emit 'skip)
| 'end (emit 'end)
| 'to set val1 skip (emit 'to emit/only :val1)
| 'thru set val1 skip (emit 'thru emit/only :val1)
| 'break (emit 'break)
| 'into (emit 'into) [
into grammar (emit/only last-block)
| set val1 word! (if block? get/any val1 [emit handle-subrule-word val1])
]
| 'interpret 'with [
into grammar (emit mk-interpret last-block)
| set val1 word! (if block? get/any val1 [emit mk-interpret handle-subrule-word val1])
]
| set val1 word!
(either block? get/any val1 [emit handle-subrule-word val1] [emit val1])
| set val1 set-word! (emit :val1)
| set val1 get-word! (emit :val1)
| set val1 lit-word! (emit :val1)
| set val1 skip (emit :val1)
]
rule: [
'none (emit 'none)
| 'opt (emit 'opt) element
| 'some (emit 'some) element
| 'any (emit 'any) element
| 'if set val1 paren!
(start-block push :val1)
element
(end-block emit mk-if pop last-block)
| 'either set val1 paren!
(push :val1 start-block)
element
(end-block push last-block start-block)
element
(end-block emit mk-either pop pop last-block)
| copy val1 1 2 integer! (emit val1) element
| element
]
val1: val2: pos: none
valstack: []
push: func [value] [insert/only tail valstack value]
pop: has [value] [value: last valstack remove back tail valstack value]
complete-rule: [
'set set val1 word! (emit 'set emit val1) rule
| 'copy set val1 word! (emit 'copy emit val1) rule
| 'do set val1 word!
(start-block push val1)
rule
(end-block emit/only mk-evaluate pop last-block)
| 'throw set val1 string!
(start-block push val1)
rule
(end-block emit/only mk-throw pop last-block)
| rule
]
stack: []
last-block: none
ctx: []
start-block: does [
insert/only tail stack make block! 32
]
end-block: does [
last-block: last stack
remove back tail stack
]
emit: func [value /only] [
either only [
insert/only tail last stack :value
] [
insert tail last stack :value
]
]
handle-subrule-word: func [subrule [word!] /local sw] [
sw: to set-word! subrule
if not find ctx :sw [
insert insert tail ctx :sw none
parse get subrule grammar
insert/only insert tail ctx :sw last-block
]
subrule
]
mk-evaluate: func [word [word!] rule [block!] /local action] [
if not find ctx [__mark:] [
insert tail ctx [
__mark: none
__evaluate: func ['word [word!] rule [block!] /local result] [
either error? result: try [do/next __mark] [
if [do/next __mark] = get in disarm :result 'near [
__fix-error :result __mark
]
result
] [
if word <> 'none [set/any word pick result 1]
parse reduce [pick result 1] [
rule end
| (__fix-error make error! reduce ['script 'expect-set mold rule pick result 1] __mark)
]
__mark: pick result 2
]
]
__fix-error: :fix-error
]
]
action: make paren! compose/only [__evaluate (word) (rule)]
compose [
__mark: (action) :__mark
]
]
mk-throw: func [error [string!] rule [block!] /local action] [
if not find ctx [__err:] [
insert tail ctx [__err: none]
]
action: make paren! compose [do fix-error make error! (error) __err]
compose [
(rule) | __err: (action)
]
]
mk-if: func [condition [paren!] rule [block!] /local action] [
if not find ctx [__ifrule:] [
insert tail ctx [__ifrule: none]
]
action: make paren! compose/deep/only [__ifrule: if (condition) [(rule)]]
compose [(action) __ifrule]
]
mk-either: func [true-rule [block!] condition [paren!] false-rule [block!] /local action] [
if not find ctx [__ifrule:] [
insert tail ctx [__ifrule: none]
]
action: make paren! compose/deep/only [__ifrule: either (condition) [(true-rule)] [(false-rule)]]
compose [(action) __ifrule]
]
mk-interpret: func [rule [block! word!] /local push pop] [
if not find ctx [__stack:] [
insert tail ctx [
__stack: []
__push: func [value] [insert/only tail __stack value]
__pop: has [value] [value: last __stack remove back tail __stack value]
]
]
push: make paren! compose/only [__push handler handler: (rule)]
pop: copy first [(handler: __pop)]
compose/only [(push) [control-functions (pop) | (pop) end skip]]
]
grammar: [
(start-block)
any complete-rule any ['| any complete-rule]
end
(end-block)
]
fix-error: func [
"Changes the NEAR field to show the PARSE cursor"
error [error!]
cursor "PARSE cursor"
/local disarmed
] [
insert head error/arg1 "LEST dialect error: "
error/near: cursor
error
]
set 'compile-rules func [
{Compile an extended PARSE rule to a normal PARSE rule}
rule [block!]
/all "Return an object with the whole compiled rule"
] [
clear ctx
clear stack
parse rule grammar
insert/only insert tail ctx [__rule:] last-block
rule: context ctx
either all [
rule
] [
last-block
]
]
functions: context [
do: lib/func [
{Evaluates a block, file, URL, function, word, or any other value in the dialect's context.}
[throw]
value "Normally a file name, URL, or block"
] [
lib/if any [file? :value url? :value string? :value] [
value: bind load value 'self
]
lib/either block? :value [
handle-dialect-block value
] [
lib/do value
]
]
either: lib/func [
{If condition is TRUE, evaluates the first block, else evaluates the second.}
[throw]
condition
true-block [block!]
false-block [block!]
] [
handle-dialect-block lib/either condition [true-block] [false-block]
]
foreach: lib/func [
{Evaluates a block in the dialect's context for each value(s) in a series.}
[throw]
'word [get-word! word! block!] {Word or block of words to set each time (will be local)}
data [series!] "The series to traverse"
body [block!] "Block to evaluate each time"
] [
lib/if get-word? :word [word: get :word]
lib/foreach :word data compose/only [handle-dialect-block (body)]
]
if: lib/func [
{If condition is TRUE, evaluates the block in the dialect's context.}
[throw]
condition
then-block [block!]
] [
lib/if condition [
handle-dialect-block then-block
]
]
loop: lib/func [
{Evaluates a block in the dialect's context a specified number of times.}
[throw]
count [integer!] "Number of repetitions"
block [block!] "Block to evaluate"
] [
lib/loop count [handle-dialect-block block]
]
repeat: lib/func [
{Evaluates a block in the dialect's context a number of times or over a series.}
[throw]
'word [word!] "Word to set each time"
value [integer! series!] "Maximum number or series to traverse"
body [block!] "Block to evaluate each time"
] [
lib/repeat :word value compose/only [handle-dialect-block (body)]
]
if-error: lib/func [
{Tries to DO a block in the dialect's context; if there's an error, DOes the
             second block in the dialect's context.}
[throw]
block [block!]
on-error [block!]
] [
lib/if error? lib/try [handle-dialect-block block] [
handle-dialect-block on-error
]
]
until: lib/func [
{Evaluates a block in the dialect's context until it is TRUE.}
[throw]
block [block!]
] [
lib/until [handle-dialect-block block get/any 'val]
]
use: lib/func [
"Defines words local to a block."
[throw]
words [block! word!] "Local word(s) to the block"
body [block!] "Block to evaluate in the dialect's context"
] [
lib/use words compose/only [handle-dialect-block (body)]
]
while: lib/func [
{While a condition block is TRUE, evaluates another block in the dialect's context.}
[throw]
cond-block [block!]
body-block [block!]
] [
lib/while cond-block [handle-dialect-block body-block]
]
define-func: lib/func [
{Defines a user function in the dialect's context with given spec and body.}
[catch]
name [word!] "The name of the function"
spec [block!] {Help string (opt) followed by arg words (and opt type and string)}
body [block!] "The body block of the function"
] [
lib/throw-on-error [
set name make function! spec compose/only [handle-dialect-block (body)]
]
]
throw-on-error: lib/func [
{Evaluates a block in the dialect's context, which if it results in an error, throws that error.}
blk [block!]
] [
lib/if error? set/any 'blk try [handle-dialect-block blk] [throw blk]
]
forall: lib/func [
{Evaluates a block in the dialect's context for every value in a series.}
[throw]
'word [word!] {Word set to each position in series and changed as a result}
body [block!] "Block to evaluate each time"
] [
lib/while [not tail? get word] [
handle-context-block body
set word next get word
]
]
forskip: lib/func [
{Evaluates a block in the dialect's context for periodic values in a series.}
[throw]
'word [word!] {Word set to each position in series and changed as a result}
skip-num [integer!] "Number of values to skip each time"
body [block!] "Block to evaluate each time"
] [
lib/while [not tail? get word] [
handle-dialect-block body
set word skip get word skip-num
]
]
for: lib/func [
{Repeats a block in the dialect's context over a range of values.}
[throw]
'word [word!] "Variable to hold current value"
start [number! series! money! time! date! char!] "Starting value"
end [number! series! money! time! date! char!] "Ending value"
bump [number! money! time! char!] "Amount to skip each time"
body [block!] "Block to evaluate"
] [
lib/for :word start end bump compose/only [handle-dialect-block (body)]
]
forever: lib/func [
{Evaluates a block in the dialect's context endlessly.}
[throw]
body [block!] "Block to evaluate each time"
] [
while [on] body
]
switch: lib/func [
"Selects a choice and evaluates what follows it."
[throw]
value "Value to search for."
cases [block!] "Block of cases to search."
/default case "Default case if no others are found."
] [
either value: select cases value [handle-dialect-block value] [
if default [handle-dialect-block case]
]
]
]
handler: none
handle-dialect-block: func [[throw] block] [
parse block handler
]
here: word: continue?: none
evaluate-control-function: has [there] [
continue?: [end skip]
there: here
if path? word [
there: word
word: first word
]
if any [
all [function? get/any word 'handle-dialect-block = first second get word]
all [word: in functions word change there word]
] [
here: second do/next here
continue?: none
]
]
set 'control-functions [
here: set word [word! | path!] (
evaluate-control-function
) continue? :here
]
]
]
css-path: %css/
js-path: %js/
plugin-path: %plugins/
text-style: 'html
dot: #"."
attach: function [
{Append value to block only when not present. Return FALSE when value is present.}
block
value
] [
either found: find block value [
found
] [
append block value
true
]
]
escape-entities: funct [
"Escape HTML entities. Only partial support now."
data
] [
output: make string! 1.1 * length? data
entities: [
#"<" "lt"
#">" "gt"
#"&" "amp"
]
rule: make block! length? entities
forskip entities 2 [
repend rule [
entities/1
to paren! reduce ['append 'output rejoin [#"&" entities/2 #";"]]
'|
]
]
append rule [set value skip (append output value)]
parse data [some rule]
output
]
catenate: funct [
"Joins values with delimiter."
src [block!]
delimiter [char! string!]
/as-is "Mold values"
] [
out: make string! 200
forall src [repend out [either as-is [mold src/1] [src/1] delimiter]]
len: either char? delimiter [1] [length? delimiter]
head remove/part skip tail out negate len len
]
replace-deep: funct [
target
'search
'replace
] [
rule: compose [
change (:search) (:replace)
| any-string!
| into [some rule]
| skip
]
parse target [some rule]
target
]
change-code: func [
{Replace code at cuurent position (to have unified function for better testing and debugging)}
pos
data
/only { Only change a block as a single value (not the contents of the block)}
] [
pos/1: data
]
rule: func [
"Make PARSE rule with local variables"
local [word! block!] "Local variable(s)"
rule [block!] "PARSE rule"
] [
if word? local [local: reduce [local]]
compile-rules use local reduce [rule]
]
add-rule: func [
"Add new rule to PARSE rules block!"
rules [block!]
rule [block!]
] [
unless empty? rules [
append rules '|
]
append/only rules rule
]
to-www-form: func [
{Convert object body (block!) to application/x-www-form-urlencoded}
data
/local out
] [
out: copy ""
foreach [key value] data [
if issue? value [value: next value]
repend out [
to word! key
#"="
value
#"&"
]
]
head remove back tail out
]
build-tag: funct [
name [word!]
values [block! object! map!]
] [
tag: make string! 256
repend tag [#"<" name space]
unless block? values [values: body-of values]
foreach [name value] values [
skip?: false
value: switch/default type?/word value [
block! [
if empty? value [skip?: true]
catenate value #" "
]
string! [if empty? value [skip?: true] value]
none! [skip?: true]
] [
form value
]
unless skip? [
repend tag [to word! name {="} value {" }]
]
]
head change back tail tag #">"
]
entag: func [
"Enclose value in tag"
data
tag
/with
values
] [
unless with [values: clear []]
ajoin [
build-tag tag values
reduce data
close-tag tag
]
]
close-tag: func [
type
] [
ajoin ["</" type ">"]
]
get-integer: func [
{Get integer! value from string! or pass integer! (return NONE otherwise)}
value
/local number int-rule
] [
if integer? value [return value]
unless string? value [return none]
number: charset "0123456789"
int-rule: [opt #"-" some number]
either parse value int-rule [to integer! value] [none]
]
lest-integer?: func [
value
/local number int-rule
] [
number: charset "0123456789"
int-rule: [opt #"-" some number]
any [
integer? value
parse value int-rule
]
]
lest: use [
debug-print
buffer
page
tag
tag-name
tag-stack
includes
rules
header?
safe?
pos
locals
local
current-text-style
used-styles
last-id
name
value
emit
emit-label
emit-stylesheet
add-js
user-rules
user-words
user-words-meta
user-values
plugins
load-plugin
] [
add-js: func [
"Add code do javascript code buffer"
target
data
/only "Do not end command with semicolon"
] [
head append target rejoin [data either only "" #";"]
]
set-user-word: func [
name
value
/type
'word-type
/custom
custom-data
] [
name: to lit-word! name
debug-print ["SET-USER-WORD"]
debug-print ["uw:" mold user-words]
debug-print ["SET:" name mold value "(rebol:" type? value ")"]
debug-print ["word-type" mold word-type get-integer value]
word-type: case [
word-type (to lit-word! word-type)
get-integer value (value: form value 'integer)
string? value ('string)
equal? #"." first form value ('class)
word? value ('word)
block? value ('block)
issue? value ('id)
map? value ('map)
]
debug-print ["SET:" name mold value "(lest:" word-type ")"]
obj: object reduce/no-set [
type: quote word-type
]
if custom [append object custom-data]
append user-words compose/only [
(to set-word! name) (:value)
]
append user-words-meta compose [
(to set-word! name) (obj)
]
]
get-user-word: func [
'name
] [
get in user-words name
]
get-user-type: func [
name
] [
if name: get in user-words-meta name [
name/type
]
]
emit: func [
data [string! block! tag!]
] [
if block? data [data: ajoin data]
if tag? data [data: mold data]
append buffer data
]
emit-label: func [
label
elem
/class
styles
] [
unless empty? label [emit entag/with label 'label reduce/no-set [for: elem class: styles]]
]
emit-script: func [
script
/insert
/append
] [
case [
insert [lib/append includes/header script]
append [lib/append includes/body-end script]
true [emit script]
]
]
emit-stylesheet: func [
stylesheet
/local suffix
] [
local: stylesheet
if all [
file? stylesheet
not equal? %.css suffix: suffix? stylesheet
] [
write
local: replace copy stylesheet suffix %.css
prestyle load stylesheet
]
unless find includes/stylesheets stylesheet [
repend includes/stylesheets [{<link href="} local {" rel="stylesheet">} newline]
]
]
rules: object [
tag: tag
tag-name: tag-name
value-to-emit: none
emit-value: [
(emit value-to-emit)
]
load-rule: rule [pos value] [
'load pos: set value [file! | url!]
(
debug-print ["##LOAD" value]
change-code/only pos load value
)
:pos
]
import-rule: rule [pos value] [
'import pos: set value [file! | url!]
(
debug-print ["##IMPORT" value]
change-code/only pos load value
)
:pos main-rule
]
text-settings: rule [type] [
set type ['plain | 'html | 'markdown]
'text
(text-style: type)
]
eval: [
(debug-print "!!EVAL!!")
any [
commands (debug-print "!!EVAL!!command")
| user-values (debug-print "!!EVAL!!user-val")
| process-code (debug-print "!!EVAL!!code")
| plugins (debug-print "!!EVAL!!plugin")
| comparators (debug-print "!!EVAL!!comparator")
]
(debug-print "!!EVAL!!END!!")
]
eval-strict: [any [user-values | process-code | commands]]
process-code: rule [p value] [
(debug-print "--process code")
p: set value paren!
(
debug-print ["==CODE:" mold value]
p/1: either safe? [
""
] [
do bind to block! value user-words
]
)
:p
]
set-at-rule: rule [word index value block] [
'set
set word word!
'at
eval set index integer!
eval set value any-type!
(
debug-print ["==SET@:" word "@" index "=" value]
block: get-user-word :word
block/:index: value
set-user-word word block
)
]
set-rule: rule [labels values] [
[
'set set labels [word! | block!]
| set labels set-word! (labels: to word! labels)
]
eval set values any-type!
(
unless block? labels [
labels: reduce [labels]
values: reduce [values]
]
debug-print ["==SET:" length? labels "values"]
repeat i length? labels [
label: labels/:i
value: values/:i
value: switch/default value [
true yes on [lib/true]
false no off [lib/false]
] [value]
unless in user-words label [
debug-print ["==SET/create:" label]
append second user-values compose [
|
(to lit-word! label)
(to paren! compose [change/only pos get-user-word (label)])
]
]
debug-print ["==SET:" label ":" mold value]
set-user-word label value
]
)
]
get-user-value: rule [value] [
pos:
set value any-type!
(
all [
word? value
in user-words value
change-code/only pos user-words/:value
]
)
:pos
]
new-get-user-value: rule [name] [
pos:
set name word!
(
change-code/only pos get-user-word name
)
:pos
]
user-rule: rule [name label type value urule args pos this-rule] [
set name set-word!
(
args: copy []
idx: none
if block? pos: attach user-rule-names name [
idx: (index? pos) * 2 + 1
]
this-rule: reduce [
to set-word! 'pos
to lit-word! name
to paren! compose [debug-print (rejoin ["UU:user-rule: " name " <start> matched."])]
]
)
any [
set label word!
set type word!
(
add-rule args rule [px] reduce [
to set-word! 'px to lit-word! label
to paren! reduce/no-set [to set-path! 'px/1 label]
]
repend this-rule ['eval to set-word! 'pos 'set label type]
)
]
set value block!
(
append this-rule reduce [
to paren! compose/only [
urule: (compose [
any-string!
| into [some urule]
| (args)
| skip
])
debug-print ["parse in user-rule"]
parse temp: copy/deep (value) [some urule]
change-code/only pos temp
]
to get-word! 'pos 'into main-rule
]
either idx [
change/only at user-rules idx this-rule
] [
add-rule user-rules this-rule
]
)
]
template-rule: rule [name label type value urule args pos this-rule] [
set name set-word!
'template
(
debug-print ["==TEMPLATE:" name]
args: copy []
idx: none
if block? pos: attach user-rule-names name [
idx: (index? pos) * 2 + 1
]
this-rule: reduce [
to set-word! 'pos
to lit-word! name
to paren! compose [debug-print (rejoin ["UU:user-rule: " name " <start> matched."])]
]
)
opt into [
some [
set label word!
(
debug-print ["==TEMPLATE arg:" label]
add-rule args rule [px] reduce [
to set-word! 'px to lit-word! label
to paren! reduce/no-set [to set-path! 'px/1 label]
]
repend this-rule ['eval to set-word! 'pos 'set label 'any-type!]
)
]
]
set value block!
(
append this-rule reduce [
to paren! compose/only [
urule: (compose [
any-string!
| into [some urule]
| (args)
| skip
])
debug-print ["parse in user-rule"]
parse temp: copy/deep (value) [some urule]
change-code/only pos temp
]
to get-word! 'pos 'into main-rule
]
set-user-word/type name value template
either idx [
change/only at user-rules idx this-rule
] [
add-rule user-rules this-rule
]
)
]
enable-plugin: rule [name t] [
'enable pos: set name word! (
either t: load-plugin name [
change-code pos t
] [pos: next pos]
)
:pos [main-rule | into main-rule]
]
init-tag: [
(
insert tag-stack reduce [tag-name tag: context [id: none class: copy []]]
debug-print ["INIT TAG:" tag-name]
debug-stack tag-stack
)
]
take-tag: [(set [tag-name tag] take/part tag-stack 2)]
emit-tag: [(
emit build-tag tag-name tag
debug-print ["EMIT TAG:" tag-name ", stack: " length? tag-stack]
)]
end-tag: [
take-tag
(
emit close-tag tag-name
debug-print ["END TAG:" tag-name ", stack: " length? tag-stack]
)
]
init-div: [
(tag-name: 'div)
init-tag
]
comparators: [
comparison-rule
]
comparison-rule: rule [val1 val2 comparator pos res] [
set val1 any-type!
set comparator ['= | '> | '< | '>= | '<= | '<>]
set val2 any-type!
pos:
(
debug-print ["<>COMPARE:" mold val1 type? val1 comparator mold val2 type? val2]
if word? val1 [
type: get-user-type val1
val1: get-user-word :val1
debug-print ["GOT" mold val1]
]
if lest-integer? val1 [val1: get-integer val1]
if word? val2 [
type: get-user-type val2
val2: get-user-word :val2
debug-print ["GOT" mold val2]
]
if lest-integer? val2 [val2: get-integer val2]
debug-print ["<>COMPARE:" mold val1 comparator mold val2]
res: do reduce [val1 comparator val2]
debug-print ["<>COMPARE:" mold res]
change-code/only pos: back pos res
)
:pos
]
math-commands: [
incr-rule
| math-rule
]
incr-rule: rule [action word value] [
set action ['++ | '--]
set word word!
(
debug-print ["++MATH  incr:" word action]
action: select [++ + -- -] action
all [
value: get-user-word :word
value: get-integer value
integer? value
value: do reduce ['value action 1]
set-user-word word form value
]
)
]
math-rule: rule [pos action val1 val2] [
set val1 [string! | integer! | word!]
set action ['+ | '- | '*]
pos: set val2 [string! | integer! | word!]
(
debug-print ["++MATH  input:" val1 action val2]
if word? val1 [val1: get-user-word :val1]
if word? val2 [val2: get-user-word :val2]
val1: get-integer val1
val2: get-integer val2
debug-print ["++MATH output:" val1 action val2]
change-code pos form do reduce ['val1 action 'val2]
)
:pos
]
commands: [
pos: (debug-print ["match commands@" pos/1])
[
if-rule
| either-rule
| switch-rule
| for-rule
| repeat-rule
| pipe-loop-rule
| as-map-rule
| as-rule
| join-rule
| default-rule
| length-rule
| insert-append-rule
| math-commands
| load-rule
| import-rule
| pass
| stop
| run
| comment
| debug-rule
| template-rule
| user-rule
| set-at-rule
| set-rule
| enable-plugin
| plugins
]
]
if-rule: rule [cond true-val pos res] [
'if
opt comparators
set cond [logic! | word! | paren!]
pos:
set true-val any-type!
(
if all [safe? paren? cond] [cond: false]
debug-print ["??COMPARE/if: " cond " +" mold true-val]
res: if/only do bind to block! cond user-words true-val
debug-print ["??COMPARE/if: " res]
either res [
change/part pos res 1
] [
pos: next pos
]
)
:pos
]
either-rule: rule [cond true-val false-val pos ret] [
'either
opt comparators
set cond [logic! | word! | paren!]
set true-val any-type!
pos:
set false-val any-type!
(
if all [safe? paren? cond] [cond: false]
debug-print ["??COMPARE/either: " cond " +" mold true-val " -" mold false-val]
change-code/only pos either/only do bind to block! cond user-words true-val false-val
debug-print ["??COMPARE/either[out]: " pos/1]
)
:pos
]
switch-rule: rule [value cases defval pos] [
'switch
(defval: none)
set value word!
set cases block!
opt [
'default
set defval any-type!
]
pos:
(
pos: back pos
forskip cases 2 [
if integer? cases/1 [cases/1: form cases/1]
cases/2: append/only copy/deep [] cases/2
]
value: get bind value user-words
defval: append/only copy [] defval
debug-print ["??COMPARE/switch: " mold value " ?" mold cases "-" mold defval]
change-code/only pos switch/default value cases defval
)
:pos
]
for-rule: rule [pos out var src content] [
'for
(debug-print "FOR command")
set var [word! | block!]
[
'in eval set src [word! | block! | file! | url!]
| eval set src [integer! | string!] 'times (src: get-integer src)
]
pos: set content block! (
debug-print "FOR matched"
src: case [
any [url? src file? src] [load src]
word? src [get-user-word :src]
integer? src [use 'i [reverse array/initial i: src func [] [-- i]]]
true [src]
]
out: make block! length? src
forall src [
append out compose [set index (index? src)]
either block? var [
repeat i length? var [
append out compose/only copy/deep [set (var/:i) (src/:i)]
]
src: skip src -1 + length? var
append/only out copy/deep content
] [
append out compose/only copy/deep [set (var) (src/1) (copy/deep content)]
]
]
change-code/only pos out
)
:pos
if (not locals/lazy?)
main-rule
(local lazy? true)
]
repeat-rule: rule [offset element count value values data pos current out] [
'repeat
(
offset: none
values: make block! 4
)
get-user-value
set element block!
'replace
some [set value get-word! (append values value)]
opt [
set count [integer! | if (not safe?) paren!]
'times
]
opt [
'offset
set offset integer!
]
[
[
'from
pos: set data [block! | word!]
(
if word? data [data: get data]
out: make block! length? data
foreach item data [
current: copy/deep element
foreach value values [
replace-deep current value item
]
if offset [
insert skip find current 'col 2 reduce ['offset offset]
offset: none
]
append out current
]
change-code pos out
)
:pos
]
| [
'with
if (not safe?)
pos: set data paren!
(
if paren? count [count: do bind to block! count user-words]
data: to block! data
out: make block! length? data
repeat index count [
current: copy/deep element
result: do bind bind data 'index user-words
either 1 = length? values [
replace-deep current values/1 result
] [
foreach value values [
replace-deep current value (take result)
]
]
append out current
]
change-code pos out
)
:pos
]
]
]
pipe-loop-rule: rule [pos content data out length] [
set data [word! | block!]
'<<
(content: append copy [] data)
(debug-print ["pipe-loop-rule matched:" mold content])
eval
pos:
set data [block! | string! | integer!]
(
debug-print ["pipe-loop-rule data:" mold data]
unless block? data [data: reverse array/initial length: get-integer data does [-- length]]
out: make block! 100
foreach value data [
append out append copy content value
]
debug-print ["pipe-loop-rule out:" mold out]
change-code pos out
)
:pos
]
default-rule: rule [value word defval] [
'default
set word word!
set defval any-type!
(
value: get-user-word :word
unless value [set-user-word :word defval]
)
]
as-map-rule: rule [pos value] [
'as 'map
eval pos: set value any-type!
(
debug-print ["++AS MAP -" mold value ":" mold pos]
value: to map! value
change-code pos value
)
:pos
]
as-rule: rule [pos value type] [
'as
eval set type ['string | 'date | 'integer | 'class | 'file]
eval pos: set value any-type!
(
debug-print ["++AS" type "-" mold value ":" mold pos]
unless block? value [value: reduce [value]]
value: map-each val value [
switch type [
string [form val]
date [attempt [to date! val]]
integer [attempt [to integer! val]]
file [to file! val]
class [to word! join #"." form val]
]
]
debug-print ["++AS" type "=" mold value]
either 1 = length? value [
change-code pos value/1
] [
change-code pos value
]
)
:pos
]
join-rule: rule [values type delimiter result] [
'join
(delimiter: type: none)
opt ['as set type word!]
eval set values block!
opt ['with set delimiter [char! | string!]]
pos:
(
debug-print ["++JOIN AS" type]
pos: back pos
result: make string! 100
forall values [
append result switch/default type?/word values/1 [
word! [get-user-word :values/1]
lit-word! [form to word! values/1]
issue! [form to word! values/1]
] [form values/1]
all [
delimiter
not tail? next values
append result delimiter
]
]
if type [
result: switch type [
class [to word! head insert result #"."]
id [to issue! result]
file [to file! result]
]
]
change-code pos result
)
:pos
]
length-rule: rule [series] [
'length?
eval
pos: set series block!
(change-code pos form length? series)
:pos
]
insert-append-rule: rule [command series value] [
set command ['append | 'insert]
eval
set series block!
eval
set value any-type!
(do reduce [command series 'value])
]
comment: [
'comment [block! | string!]
]
debug-rule: rule [value] [
'debug [
set value string!
(debug-print ["debug:" value])
| pos: 'words
(
value: rejoin ["user-words:" mold user-words]
pos/1: value
debug-print value
)
:pos
]
]
window-events: [
'onafterprint | 'onbeforeprint | 'onbeforeunload | 'onerror | 'onhashchange | 'onload | 'onmessage
| 'onoffline | 'ononline | 'onpagehide | 'onpageshow | 'onpopstate | 'onresize | 'onstorage | 'onunload
]
form-events: [
'onblur | 'onchange | 'oncontextmenu | 'onfocus | 'oninput | 'oninvalid | 'onreset | 'onsearch | 'onselect | 'onsubmit
]
keyboard-events: [
'onkeydown | 'onkeypress | 'onkeyup
]
mouse-events: [
'onclick | 'ondblclick | 'ondrag | 'ondragend | 'ondragenter | 'ondragleave | 'ondragover | 'ondragstart | 'ondrop
| 'onmousedown | 'onmousemove | 'onmouseout | 'onmouseover | 'onmouseup | 'onmousewheel | 'onscroll | 'onwheel
]
clipboard-events: [
'oncopy | 'oncut | 'onpaste
]
media-events: [
'onabort | 'oncanplay | 'oncanplaythrough | 'oncuechange | 'ondurationchange | 'onemptied | 'onended | 'onerror | 'onloadeddata
| 'onloadedmetadata | 'onloadstart | 'onpause | 'onplay | 'onplaying | 'onprogress | 'onratechange | 'onseeked | 'onseeking
| 'onstalled | 'onsuspend | 'ontimeupdate | 'onvolumechange | 'onwaiting
]
misc-events: [
'onerror | 'onshow | 'ontoggle
]
events: [
window-events | form-events | keyboard-events | mouse-events | clipboard-events | media-events | misc-events
]
js-raw: rule [value] [
set value string!
(
debug-print ["!!action fc: RAW"]
add-js locals/code value
)
]
js-debug: rule [value] [
'debug
set value any-type!
(debug-print ["!!action fc: DEBUG"])
(
unless word? value [value: rejoin ["'" form value "'"]]
add-js locals/code rejoin ["console.debug(" value ")"]
)
]
js-assign-value: rule [name] [
set name set-word!
(debug-print ["!!action fc: ASSIGN"])
(add-js/only locals/code rejoin ["var " to word! name " = "])
]
js-set: rule [name target data] [
'set
(debug-print ["!!action fc: SET"])
eval set name issue! eval set target word! eval set data any-string! (
add-js rejoin ["document.getElementById('" next form name "')." target " = '" data "'"]
)
]
js-action: rule [name data target] [
'action
(data: "")
(debug-print ["!!action fc: ACTION"])
set name word!
set data [word! | block! | none!]
(
if any ['none = data] [data: "''"]
add-js locals/code rejoin ["sendAction('" name "', " data ")"]
)
]
js-send: rule [type] [
(type: 'post)
'send
opt set type ['get | 'post]
set data any-type!
(
debug-print ["!!action fc: SEND" type]
)
]
get-dom: rule [path] [
set path get-path!
(
debug-print ["!!action fc: GET DOM"]
add-js locals/code rejoin [{getAttr("} path/1 {","} path/2 {")}]
)
]
set-dom: rule [path value] [
set path set-path!
set value any-type!
(
debug-print ["!!action fc: SET DOM"]
unless word? value [value: rejoin ["'" form value "'"]]
add-js locals/code rejoin ["setAttr('" path/1 "','" path/2 "'," value ")"]
)
]
call-dom: rule [] []
js-object: rule [key value object] [
'object
(object: make string! 200)
(append object #"{")
into [
some [
set key set-word!
[
set value word!
| set value any-type! (value: mold value)
]
(append object rejoin [#"^"" to word! key {": } value #","])
]
]
(
change back tail object #"}"
add-js locals/code object
)
]
js-code: rule [] [
(debug-print "^/JS: Match JS code^/---------------")
some [
js-raw
| js-debug
| js-set
| js-action
| js-assign-value
| js-object
| get-dom
| set-dom
]
(debug-print "^/JS: End JS code^/---------------")
(replace/all locals/code #"^"" #"'")
(debug-print mold locals/code)
]
actions: rule [action data] [
set action events
(
local code make string! 1000
local action action
debug-print ["!!action:" action]
)
[
set data string!
(append tag reduce [to set-word! locals/action data])
| into js-code
(append tag reduce [to set-word! locals/action locals/code])
]
]
style-rule: rule [data] [
'style
(debug-print "==STYLE")
set data [block! | string!]
(
either string? data [
append includes/stylesheet entag data 'style
] [
append includes/style data
]
)
]
get-style: rule [pos data type] [
set type ['id | 'class]
pos:
set data [word! | block!] (
data: either word? data [get bind data user-words] [rejoin bind data user-words]
data: either type = 'id [to issue! data] [to word! head insert to string! data dot]
change-code pos data
)
:pos
]
style: rule [pos word continue] [
any [
get-style
| set word issue! (tag/id: next form word debug-print ["** " tag-name "/id: " tag/id])
| [
pos: set word word!
(
continue: either #"." = take form word [
append used-styles word
append tag/class next form word
debug-print ["** " tag-name "/class: " tag/class]
[]
] [
debug-print ["** " tag-name " not a style: " word]
[end skip]
]
)
continue
]
| 'with set word block! (append tag word)
]
]
body-atts: rule [value] [
'append
'body
set value block!
(
append includes/body-tag value
)
]
run: rule [file] [
'run
if (not safe?)
(debug-print "== RUN")
eval
set file [file! | url!]
(do file)
]
script: rule [type value] [
(type: none)
opt [set type ['insert | 'append]]
'script
(debug-print ["$$ SCRIPT:" type])
set value [string! | file! | url! | path!]
(
if path? value [
value: get first bind reduce [value] user-words
]
value: ajoin either string? value [
[<script type="text/javascript"> value]
] [
[{<script src="} value {">}]
]
append value close-tag 'script
(debug-print ["$$SCRIPT emit: " value])
switch/default type [
insert [emit-script/insert value]
append [emit-script/append value]
] [emit-script value]
)
]
stylesheet: rule [value] [
pos:
'stylesheet some [
set value [file! | url! | path!] (
if path? value [
value: get first bind reduce [value] user-words
]
emit-stylesheet value
debug-print ["==STYLESHEET:" value]
)
]
]
page-header: [
'head (debug-print "==HEAD")
(header?: true)
header-rule
pos:
'body (
debug-print "==BODY"
repend includes/header [{<script src="} js-path {lest.js">} </script> newline]
)
]
header-title: rule [value] [
'title eval set value string! (page/title: value debug-print "==TITLE")
]
header-language: rule [value] [
['lang | 'language] set value word! (page/lang: value debug-print "==LANG")
]
meta-rule: rule [type name value] [
'meta [
set name word! set value string! (
repend page/meta [{<meta name="} name {" content="} value {">}]
)
| set type set-word! set name word! set value string! (
repend page/meta ["<meta " to word! type {="} name {" content="} value {">}]
)
]
]
favicon-rule: rule [value] [
'favicon set value [file! | url!] (
repend includes/header [
{<link rel="icon" type="image/png" href="} value {">}
]
)
]
header-rule: [
any [
eval
pos:
[header-content | into header-content]
]
:pos
]
header-content: [
header-title
| header-language
| stylesheet
| style-rule
| script
| meta-rule
| favicon-rule
| import-rule
| debug-rule
| plugins
]
main-rule: rule [] [
throw "Unknown tag, command or user template"
[some content-rule]
]
content-rule: [
commands
| process-code main-rule
| [
basic-string-match
basic-string-processing
(emit value)
]
| elements
| plugins
| into main-rule
]
match-content: rule [] [
throw "Expected string, tag or block of tags"
content-rule
]
elements: rule [] [
pos: (debug-print ["parse at: " index? pos "::" trim/lines copy/part mold pos 64 "..."])
[
text-settings
| page-header
| basic-elems
| list-content
| form-content
| user-rules
| heading
| label-rule
| form-rule
| script
| meta-rule
| stylesheet
]
(
value: none
)
]
br: ['br (emit <br>)]
hr: ['hr (emit <hr>)]
paired-tags: ['i | 'b | 'p | 'pre | 'code | 'div | 'span | 'small | 'em | 'strong | 'header | 'footer | 'nav | 'section | 'button]
paired-tag: rule [] [
set tag-name paired-tags
init-tag
eval
opt style
opt actions
emit-tag
eval
match-content
end-tag
]
image: rule [value] [
['img | 'image]
(
debug-print "==IMAGE"
tag-name: 'img
)
init-tag
some [
set value [file! | url!] (
append tag compose [src: (value) alt: "Image"]
)
| set value pair! (
append tag compose [
width: (to integer! value/x)
height: (to integer! value/y)
]
)
| style
]
take-tag
emit-tag
]
link: rule [value] [
['a | 'link] (tag-name: 'a)
init-tag
eval
set value [file! | url! | issue!]
(append tag compose [href: (value)])
eval
opt style
emit-tag
match-content
end-tag
]
li: [
set tag-name 'li
init-tag
opt style
emit-tag
match-content
end-tag
]
ul: [
set tag-name 'ul
(debug-print "--UL--")
init-tag
opt style
emit-tag
eval
match-content
end-tag
]
ol: rule [value] [
set tag-name 'ol
init-tag
any [
set value integer! (append tag compose [start: (value)])
| style
]
emit-tag
some li
end-tag
]
dl: [
set tag-name 'dl
init-tag
opt [
'horizontal (append tag/class 'dl-horizontal)
| style
]
emit-tag
some [
basic-string-match
(tag-name: 'dt)
init-tag
basic-string-processing
style
emit-tag
(emit value)
end-tag
basic-string-match
(tag-name: 'dd)
init-tag
basic-string-processing
style
emit-tag
(emit value)
end-tag
]
end-tag
]
list-elems: [
ul
| ol
| dl
]
list-content: [
some li
]
basic-elems: [
[
basic-string-match
basic-string-processing
(emit value)
]
| body-atts
| br
| hr
| table
| paired-tag
| image
| link
| list-elems
]
basic-string: [
(current-text-style: none)
opt [set current-text-style ['plain | 'html | 'markdown]]
opt [user-values]
set value [string! | date! | time! | number!]
(
unless current-text-style [current-text-style: text-style]
value: form value
value: switch current-text-style [
plain [value]
html [escape-entities value]
markdown [markdown value]
]
)
(emit value)
]
basic-string-match: [
(current-text-style: none)
opt [set current-text-style ['plain | 'html | 'markdown]]
opt [user-values]
set value [string! | date! | time! | number!]
]
basic-string-processing: [
(
unless current-text-style [current-text-style: text-style]
value: form value
value: switch current-text-style [
plain [value]
html [escape-entities value]
markdown [markdown value]
]
)
]
pass: [
'pass
]
stop: [
'stop
to end
]
heading: [
set tag-name ['h1 | 'h2 | 'h3 | 'h4 | 'h5 | 'h6]
init-tag
opt style
emit-tag
eval
match-content
end-tag
]
table: rule [value] [
set tag-name 'table
init-tag
(append tag/class 'table)
style
emit-tag
opt [
'header
(tag-name: 'tr)
init-tag
emit-tag
into [
some [
set value string!
(tag-name: 'th)
init-tag
emit-tag
(emit value)
end-tag
]
]
end-tag
]
any [
into [
(tag-name: 'tr)
init-tag
emit-tag
some [
pos: block! :pos
(tag-name: 'td)
init-tag
emit-tag
into main-rule
end-tag
]
end-tag
]
]
end-tag
]
label-rule: rule [value elem] [
set tag-name 'label
(elem: none)
opt [set elem issue!]
set value string!
init-tag
(
all [
elem
append tag compose [for: (next form elem)]
]
value-to-emit: value
)
emit-tag
emit-value
end-tag
]
init-input: rule [value] [
(
tag-name: 'input
default: none
)
init-tag
]
emit-input: [
(append tag compose [name: (name) placeholder: (defval) value: (value)])
emit-tag
close-tag
]
old-emit-input: [
(
switch/default form-type [
horizontal [
unless empty? label [
emit-label/class label name [col-sm-2 control-label]
]
emit <div class="col-sm-10">
set [tag-name tag] take/part tag-stack 2
append tag compose [name: (name) placeholder: (defval) value: (value)]
emit build-tag tag-name tag
emit </div>
]
] [
unless empty? label [
emit-label label name
]
set [tag-name tag] take/part tag-stack 2
append tag compose [name: (name) placeholder: (defval) value: (value)]
emit build-tag tag-name tag
]
)
]
input-parameters: rule [list data] [
set name word!
(
debug-print ["INPUT:name=" name]
local datalist none
)
any [
eval
any [
'default eval set defval string! (debug-print ["INPUT:" name " default:" defval])
| 'value eval set value string! (debug-print ["INPUT:" name " value:" value])
| 'checked (debug-print ["INPUT:" name " checked"] append tag [checked: true])
| 'required (debug-print ["INPUT:" name " required"] append tag [required: true])
| 'error (debug-print ["INPUT:" name " error"]) eval set data string! (append tag compose [data-error: (data)])
| 'match (debug-print ["INPUT:" name " match"]) eval set data [word! | issue!] (append tag compose [data-match: (to issue! data)])
| 'min-length (debug-print ["INPUT:" name " minlength"]) eval set data [string! | integer!] eval set def-error string! (append tag compose [data-minlegth: (data)])
| 'datalist (list: none debug-print ["INPUT:" name " minlength"]) eval opt [set list word!] eval set data block! (local datalist data local datalist-id list)
| actions (debug-print ["INPUT:" name " after actions"])
| style (debug-print ["INPUT:" name " after style"])
]
]
set label string! (debug-print ["INPUT:" name " label:" label])
]
input: rule [type simple] [
(simple: defval: value: label: def-error: none)
opt ['simple (simple: true)]
set type [
'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
| 'number | 'email | 'url | 'search | 'tel | 'color | 'file
]
if (not simple) [
(debug-print "==INPUT FORM-GROUP")
init-div
(append tag/class 'form-group)
emit-tag
]
(tag-name: 'input)
init-tag
(debug-print ["==INPUT:" type])
(append tag/class 'form-control)
(append tag reduce/no-set [type: type])
(debug-print "<input-parameters>")
input-parameters
(
if locals/datalist [
append tag compose [
list: (
either locals/datalist-id [
locals/datalist-id
] [
rejoin [type '- get-id]
]
)
]
local datalist-id tag/list
]
debug-print "</input-parameters>"
append tag compose [name: (name) placeholder: (defval) value: (value)]
emit-label label name
)
emit-tag
take-tag
if (locals/validator?) [
init-div
(append tag/class [help-block with-errors])
emit-tag
(if def-error [emit def-error])
end-tag
]
if (not simple) [end-tag]
if (locals/datalist) [
(tag-name: 'datalist)
init-tag
(tag/id: locals/datalist-id)
emit-tag
(
foreach value locals/datalist [
emit build-tag 'option compose [value: (value)]
]
)
end-tag
]
]
checkbox: rule [] [
'checkbox
(debug-print ["==CHECKBOX:"])
init-div
(append tag/class 'checkbox)
emit-tag
(tag-name: 'label)
init-tag
emit-tag
init-input
input-parameters
(append tag compose [type: 'checkbox name: (name)])
emit-tag
take-tag
(emit label)
end-tag
end-tag
]
radio: rule [] [
'radio
(debug-print ["==RADIO:"])
init-div
(append tag/class 'radio)
emit-tag
init-input
set name word!
set value [word! | string! | number!]
some [
eval [
set label string!
| 'checked (append tag [checked: true])
| 'disabled (append tag [disabled: true])
| style
]
]
(
unless tag/id [tag/id: ajoin ["radio_" name #"_" value]]
append tag compose [type: 'radio name: (name) value: (value)]
)
emit-tag
take-tag
(emit-label label tag/id)
end-tag
]
textarea: [
set tag-name 'textarea
(debug-print ["==TEXTAREA:"])
(
size: none
label: ""
)
init-tag
set name word!
(
value: ""
defval: ""
)
some [
set size pair!
| basic-string-match (label: value value: "")
| 'default get-user-value set defval string!
| 'value get-user-value set value string!
| style
]
take-tag
(
unless empty? label [emit-label label name]
append tag compose [
name: (name)
]
if size [
append tag compose [
cols: (to integer! size/x)
rows: (to integer! size/y)
]
]
emit entag/with value tag-name tag
)
]
hidden: rule [name value] [
'hidden
init-input
set name word!
some [
get-user-value set value string!
| style
]
take-tag
(
append tag compose [type: 'hidden name: (name) value: (value)]
)
emit-tag
]
submit: rule [label name value] [
'submit
(tag-name: 'button name: value: none)
init-tag
opt ['with set name word! set value string!]
(
append tag [type: submit]
append tag/class [btn btn-default]
if all [name value] [
append tag compose [
name: (name)
value: (value)
]
]
)
opt style
emit-tag
[main-rule | into main-rule]
end-tag
]
select-input: rule [label name value] [
set tag-name 'select
init-tag
set name word! (append tag compose [name: (name)])
emit-tag
some [
set value word!
set label string!
(tag-name: 'option)
init-tag
(append tag compose [value: (value)])
opt [
'selected
(append tag [selected: "selected"])
]
emit-tag
(emit label)
end-tag
]
end-tag
]
form-content: [
[
input
| textarea
| checkbox
| radio
| submit
| hidden
| select-input
]
]
form-type: none
form-rule: rule [value form-type enctype] [
set tag-name 'form
(
form-type: enctype: none
local validator? none
)
init-tag
any [
'multipart (enctype: "multipart/form-data")
| 'horizontal (form-type: 'horizontal)
| 'validator (append tag [data-toggle: 'validator] local validator? true)
]
(
append tag compose [
action: (value)
method: 'post
role: 'form
enctype: (enctype)
]
if form-type [append tag/class join "form-" form-type]
)
some [
set value [file! | url!] (
append tag compose [action: (value)]
)
| style
]
emit-tag
match-content
end-tag
]
plugins: [pos: [fail] :pos]
]
load-plugin: func [
name
/local plugin header
] [
debug-print ["load plugin" name]
either value? 'plugin-cache [
plugin: select plugin-cache name
header: object [type: 'lest-plugin]
] [
plugin: load/header rejoin [plugin-path name %.reb]
header: take plugin
]
if equal? 'lest-plugin header/type [
plugin: bind plugin object compose [user-words: (user-words)]
plugin: bind plugin 'debug-print
plugin: bind plugin 'user-words
plugin: object bind plugin rules
if in plugin 'main [add-rule rules/plugins bind plugin/main 'emit]
if in plugin 'startup [return plugin/startup]
]
none
]
out-file: none
func [
"Parse simple HTML dialect"
data [block! file! url!]
/save
{If data is file!, save output as HTML file with same name}
/debug
"Turn on debug-print mode"
/into
"Generate input into given series"
out
/safe
"Ignore some constructs"
] [
start-time: now/time/precise
if any [file? data url? data] [
out-file: replace copy data suffix? data %.html
data: load data
]
safe?: safe
debug-print: func [value] [
if debug [print rejoin reduce [value]]
]
debug-stack: func [stack] [
out: make block! 20
forskip stack 2 [append out stack/1]
debug-print ["##stack: " mold reverse out]
]
debug-lest: func [
type "Debug type: words, rules, stack ...."
] [
switch type [
local [print mold locals]
words [print mold user-words print mold user-words-meta]
rules [print mold user-rule-names print mold user-rules]
values [print mold user-values]
plugins [print mold rules/plugins]
stack [
out: make block! 20
forskip stack 2 [append out stack/1]
print mold reverse out
]
]
]
if debug [
debug-print "Debug output ON"
]
buffer: either into [out] [make string! 10000]
header?: false
last-id: 0
get-id: does [++ last-id]
tag-stack: copy []
user-rules: copy [fail]
user-rule-names: make block! 100
user-words: object []
user-words-meta: object []
user-values: copy/deep [pos: [fail] :pos]
rules/plugins: copy/deep [pos: [fail] :pos]
includes: object [
style: make block! 1000
stylesheets: copy ""
header: copy ""
body-tag: make block! 10
body-start: make string! 1000
body-end: make string! 1000
]
used-styles: make block! 20
locals: context []
local: func [
{Set word in LOCALS context for sharing values between PARSE rules}
'word value
] [
append locals reduce [to set-word! :word value]
]
local validator? none
local lazy? false
page: reduce/no-set [
title: "Page generated with Lest"
meta: copy ""
lang: "en-US"
]
debug-print "run main parse"
unless parse data bind rules/main-rule rules [
error: make error! "LEST: there was error in LEST dialect"
error/near: pos
do error
]
body: head buffer
unless empty? includes/style [
includes/style: ajoin [<style> prestyle includes/style </style>]
]
body: either header? [
ajoin [
<!DOCTYPE html> newline
{<html lang="} page/lang {">} newline
<head> newline
<title> page/title </title> newline
<meta charset="utf-8"> newline
page/meta newline
includes/stylesheets
includes/style
includes/header
</head> newline
build-tag 'body includes/body-tag
includes/body-start
body
includes/body-end
</body>
</html>
]
] [
body
]
if out-file [
write out-file body
]
debug-print ["== generated in " now/time/precise - start-time]
body
]
]