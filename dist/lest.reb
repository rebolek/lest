REBOL [
    Title: "Lest (processed)"
    Date: 6-Feb-2015/15:44:52+1:00
    Build: 69
]
comment "plugin cache"
plugin-cache: [font-awesome [
        startup: [
            stylesheet css-path/font-awesome.min.css
        ]
        rule: use [tag name fixed? size value size-att] [
            [
                'fa-icon
                init-tag
                (
                    name: none
                    fixed?: ""
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
        rule: [
            'markdown
            set value string! (emit markdown value)
        ]
    ] cgi-actions [] google-maps [
        rule: [
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
        rule: [
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
    ] test [
        startup: [
            stylesheet css-path/bootstrap.min.css
            append script js-path/jquery-2.1.0.min.js
            append script js-path/bootstrap.min.js
        ]
        rule: [
            set type 'crow
            c
            opt style
            emit-tag
            close-div
        ]
        c: [init-div]
    ] password-strength [
        startup: [
            append script js-path/pwstrength.js
        ]
        rule: rule [verdicts too-short same-as-user username] [
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
        rule: [
            grid-elems
            | col
            | bar
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
            into [some elements]
            close-div
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
                into [some elements]
                close-div
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
            into [some elements]
            end-tag
        ]
        glyphicon: [
            'glyphicon
            set name word!
            (tag-name: 'span)
            init-tag
            (
                repend tag/class ['glyphicon join 'glyphicon- name]
                debug-print ["==GLYPHICON: " name]
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
            close-div
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
        link-list-group: [
            'link-list
            init-div
            (append tag/class 'list-group)
            emit-tag
            any [
                'link
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
                    probe pos
                    insert next pos '.list-group-item
                    pos: probe back pos
                )
                :pos
                link
                opt list-badge
            ]
            end-tag
        ]
    ] google-analytics [
        rule: use [value web] [
            [
                'ga
                set value word!
                set web word!
                (
                    debug-print ["==GOOGLE ANALYTICS:" value web]
                    append includes/body-end reword {
^-<script>
^-  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
^-  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
^-  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
^-  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

^-  ga('create', '$value', '$web');
^-  ga('send', 'pageview');

^-</script>
^-} [
                        'value value
                        'web web
                    ]
                )
            ]
        ]
    ] redis [
        startup: [
            run redis-path
        ]
        rule: [
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
        rule: [
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
    ] captcha [
        rule: [
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
        rule: [
            (label: none)
            'bootstrap 'datetime
            pos: set value word!
            opt [set label string!]
            (
                id: to issue! join "datetimepicker" random 1000
                pos/1: compose/deep [
                    div .input-group .date (id) [
                        simple text (value) with [data-date-format: "DD.MM.YYYY"]
                        (either label [label] [])
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
comment "Import file prestyle.reb for lest.reb"
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
comment "Import file md.reb for lest.reb"
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
    ] [
        start-para?: true
        end-para?: true
        para?: false
        clear head md-buffer
        probe rules
        parse probe data [some rules]
        md-buffer
    ]
]
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
debug-print: none
js-path: %../../js/
css-path: %../../css/
js-path: %js/
css-path: %css/
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
    {Get integer! value from string! or pass integer! (returns NONE otherwise)}
    value
    /local number int-rule
] [
    if integer? value [return value]
    number: charset "0123456789"
    int-rule: [opt #"-" some number]
    if parse value int-rule [to integer! value]
]
lest: use [
    debug-print
    output
    buffer
    page
    tag
    tag-name
    tag-stack
    includes
    rules
    header?
    pos
    current-text-style
    used-styles
    name
    value
    emit
    emit-label
    emit-stylesheet
    user-rules
    user-words
    user-values
    plugins
    load-plugin
] [
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
        emit entag/with label 'label reduce/no-set [for: elem class: styles]
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
        import: rule [p value] [
            'import p: set value [file! | url!]
            (p/1: load value)
            :p main-rule
        ]
        text-settings: rule [type] [
            set type ['plain | 'html | 'markdown]
            'text
            (text-style: type)
        ]
        eval: [any [user-values | process-code | commands | plugins]]
        process-code: rule [p value] [
            p: set value paren!
            (
                p/1: do bind to block! value user-words
            )
            :p
        ]
        do-code: rule [p value] [
            p: set value paren!
            (
                p/1: append clear [] do bind to block! value user-words
            )
            :p main-rule
        ]
        set-rule: rule [labels values] [
            'set
            set labels [word! | block!]
            eval set values any-type!
            (
                unless block? labels [
                    labels: reduce [labels]
                    values: reduce [values]
                ]
                repeat i length? labels [
                    label: labels/:i
                    value: values/:i
                    value: switch/default value [
                        true yes on [lib/true]
                        false no off [lib/false]
                    ] [value]
                    unless in user-words label [
                        append second user-values compose [
                            |
                            (to lit-word! label)
                            (to paren! compose [change pos (to path! reduce ['user-words label])])
                        ]
                    ]
                    repend user-words [to set-word! label value]
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
                    pos/1: user-words/:value
                ]
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
                    repend this-rule [to set-word! 'pos 'set label type]
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
                        parse temp: copy/deep (value) [some urule]
                        change/only pos temp
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
        style-rule: rule [data] [
            'style
            set data block!
            (append includes/style data)
        ]
        actions: rule [action value data] [
            set action ['on-click]
            (action: replace/all to string! action #"-" "")
            [
                [
                    'set eval set value issue! eval set target word! eval set data any-string! (
                        append tag reduce [
                            to set-word! action
                            rejoin ["document.getElementById('" next form value "')." target " = '" data "';"]
                        ]
                    )
                ]
                |
                [
                    'action
                    set name word!
                    opt [set data block!]
                    eval set target issue!
                    (
                        append tag compose [
                            onClick: (rejoin ["action('" name "', '" data "', '" form to word! target "')"])
                        ]
                    )
                ]
            ]
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
        init-tag: [
            (
                insert tag-stack reduce [tag-name tag: context [id: none class: copy []]]
            )
        ]
        take-tag: [(set [tag-name tag] take/part tag-stack 2)]
        emit-tag: [(emit build-tag tag-name tag)]
        end-tag: [
            take-tag
            (emit close-tag tag-name)
        ]
        init-div: [
            (tag-name: 'div)
            init-tag
        ]
        close-div: [
            (
                tag: take/part tag-stack 2
                emit </div>
            )
        ]
        comparators: [
            comparison-rule
        ]
        comparison-rule: rule [val1 val2 comparator pos number] [
            set val1 any-type!
            set comparator ['= | '> | '< | '>= | '<= | '<>]
            set val2 any-type!
            pos:
            (
                val1: form switch/default type?/word val1 [
                    word! [get in user-words :val1]
                ] [val1]
                val2: form switch/default type?/word val2 [
                    word! [get in user-words :val2]
                ] [val2]
                val1: get-integer val1
                val2: get-integer val2
                pos: back pos
                pos/1: do reduce [val1 comparator val2]
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
                action: select [++ + -- -] action
                all [
                    value: get in user-words word
                    value: get-integer value
                    integer? value
                    user-words/:word: form do reduce ['value action 1]
                ]
            )
        ]
        math-rule: rule [pos action val1 val2] [
            set val1 [string! | integer! | word!]
            set action ['+ | '- | '*]
            pos: set val2 [string! | integer! | word!]
            (
                if word? val1 [val1: get in user-words val1]
                if word? val2 [val2: get in user-words val2]
                val1: get-integer val1
                val2: get-integer val2
                pos/1: form do reduce ['val1 action 'val2]
            )
            :pos
        ]
        commands: [
            if-rule
            | either-rule
            | switch-rule
            | for-rule
            | repeat-rule
            | join-rule
            | math-commands
        ]
        if-rule: rule [cond true-val pos res] [
            'if
            opt comparators
            set cond [logic! | word! | paren!]
            pos:
            set true-val any-type!
            (
                res: if/only do bind to block! cond user-words true-val
                either res [
                    change/part pos res 1
                ] [
                    pos: next pos
                ]
            )
            :pos
        ]
        either-rule: rule [cond true-val false-val pos] [
            'either
            opt comparators
            set cond [logic! | word! | paren!]
            set true-val any-type!
            pos:
            set false-val any-type!
            (
                change/part
                pos
                either/only do bind to block! cond user-words true-val false-val
                1
            )
            :pos
        ]
        switch-rule: rule [value cases defval pos] [
            'switch
            (defval: none)
            set value word!
            pos:
            set cases block!
            opt [
                'default
                pos:
                set defval any-type!
            ]
            (
                forskip cases 2 [cases/2: append/only copy [] cases/2]
                value: get bind value user-words
                change/part
                pos
                switch/default value cases append/only copy [] defval
                1
            )
            :pos
        ]
        for-rule: rule [pos out var src content] [
            'for
            set var [word! | block!]
            'in
            set src [word! | block!]
            pos: set content block! (
                out: make block! length? src
                if word? src [src: get in user-words src]
                forall src [
                    either block? var [
                        repeat i length? var [
                            append out compose/only [set (var/:i) (src/:i)]
                        ]
                        src: skip src -1 + length? var
                        append/only out copy/deep content
                    ] [
                        append out compose/only [set (var) (src/1) (copy/deep content)]
                    ]
                ]
                change/only/part pos out 1
            )
            :pos main-rule
        ]
        repeat-rule: rule [offset element count value values data pos current] [
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
                set count [integer! | paren!]
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
                        change/part pos out 1
                    )
                    :pos
                ]
                | [
                    'with
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
                        change/part pos out 1
                    )
                    :pos
                ]
            ]
        ]
        join-rule: rule [values delimiter result] [
            'join
            (delimiter: none)
            set values block!
            opt ['with set delimiter [char! | string!]]
            pos:
            (
                pos: back pos
                result: make string! 100
                forall values [
                    append result switch/default type?/word values/1 [
                        word! [get in user-words :values/1]
                    ] [form values/1]
                    if all [delimiter not tail? next values] [append result delimiter]
                ]
                pos/1: result
            )
            :pos
        ]
        get-style: rule [pos data type] [
            set type ['id | 'class]
            pos:
            set data [word! | block!] (
                data: either word? data [get bind data user-words] [rejoin bind data user-words]
                data: either type = 'id [to issue! data] [to word! head insert to string! data dot]
                change/part pos data 1
            )
            :pos
        ]
        style: rule [pos word continue] [
            any [
                commands
                | get-style
                | set word issue! (tag/id: next form word)
                | [
                    pos: set word word!
                    (
                        continue: either #"." = take form word [
                            append used-styles word
                            append tag/class next form word
                            []
                        ] [
                            [end skip]
                        ]
                    )
                    continue
                ]
                | 'with set word block! (append tag word)
            ]
        ]
        comment: [
            'comment [block! | string!]
        ]
        debug-rule: rule [value] [
            'debug set value string!
            (debug-print ["debug:" value])
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
            eval
            set file [file! | url!]
            (do file)
        ]
        script: rule [type value] [
            (type: none)
            opt [set type ['insert | 'append]]
            'script
            init-tag
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
            header-content
            'body (
                debug-print "==BODY"
                repend includes/header [{<script src="../js/lest.js">} </script> newline]
            )
        ]
        header-content: rule [type name value] [
            any [
                'title set value string! (page/title: value debug-print "==TITLE")
                | ['lang | 'language] set value word! (page/lang: value debug-print "==LANG")
                | set-rule
                | stylesheet
                | style-rule
                | 'style set value string! (
                    append includes/stylesheet entag value 'style
                )
                | 'script [
                    set value [file! | url!] (
                        repend includes/header [{<script src="} value {">} </script> newline]
                    )
                    | set value string! (
                        append includes/header entag value 'script
                    )
                ]
                | 'meta set name word! set value string! (
                    repend page/meta [{<meta name="} name {" content="} value {">}]
                )
                | 'meta set type set-word! set name word! set value string! (
                    repend page/meta ["<meta " to word! type {="} name {" content="} value {">}]
                )
                | 'favicon set value url! (
                    repend includes/header [
                        {<link rel="icon" type="image/png" href="} value {">}
                    ]
                )
                | import
                | debug-rule
                | plugins
            ]
        ]
        br: ['br (emit <br>)]
        hr: ['hr (emit <hr>)]
        main-rule: rule [] [
            throw "Unknown tag, command or user template"
            [some content-rule]
        ]
        content-rule: [
            commands
            | [
                basic-string-match
                basic-string-processing
                (emit value)
            ]
            | elements
            | into main-rule
        ]
        match-content: rule [] [
            throw "Expected string, tag or block of tags"
            content-rule
        ]
        paired-tags: ['i | 'b | 'p | 'pre | 'code | 'div | 'span | 'small | 'em | 'strong | 'header | 'footer | 'nav | 'section | 'button]
        paired-tag: rule [] [
            set tag-name paired-tags
            init-tag
            opt style
            opt actions
            emit-tag
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
            any [user-values | process-code]
            set value [file! | url! | issue!]
            (append tag compose [href: (value)])
            any [user-values | process-code]
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
            some li
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
        basic-elems: [
            [
                basic-string-match
                basic-string-processing
                (emit value)
            ]
            | comment
            | debug-rule
            | body-atts
            | pass
            | stop
            | br
            | hr
            | table
            | paired-tag
            | image
            | link
            | list-elems
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
        init-input: rule [value] [
            (
                tag-name: 'input
                default: none
            )
            init-tag
            (
                tag-name: first tag-stack
                tag: second tag-stack
            )
        ]
        emit-input: [
            (
                switch/default form-type [
                    horizontal [
                        unless empty? label [
                            emit-label/class label name [col-sm-2 control-label]
                        ]
                        emit <div class="col-sm-10">
                        set [tag-name tag] take/part tag-stack 2
                        append tag compose [name: (name) placeholder: (default) value: (value)]
                        emit build-tag tag-name tag
                        emit </div>
                    ]
                ] [
                    unless empty? label [
                        emit-label label name
                    ]
                    set [tag-name tag] take/part tag-stack 2
                    append tag compose [name: (name) placeholder: (default) value: (value)]
                    emit build-tag tag-name tag
                ]
            )
        ]
        input-parameters: rule [data] [
            set name word!
            any [
                set label string!
                | 'default eval set default string!
                | 'value eval set value string!
                | eval 'checked (append tag [checked: true])
                | eval 'required (append tag [required: true])
                | 'error eval set data string! (append tag compose [data-error: (data)])
                | 'match eval set data [word! | issue!] (append tag compose [data-match: (to issue! data)])
                | 'min-length eval set data [string! | integer!] eval set def-error string! (append tag compose [data-minlegth: (data)])
                | style
            ]
        ]
        input: rule [type simple] [
            (simple: default: value: label: def-error: none)
            opt ['simple (simple: true)]
            set type [
                'text | 'password | 'datetime | 'datetime-local | 'date | 'month | 'time | 'week
                | 'number | 'email | 'url | 'search | 'tel | 'color | 'file
            ]
            if (not simple) [
                init-div
                (append tag/class 'form-group)
                emit-tag
            ]
            init-input
            (append tag/class 'form-control)
            (append tag reduce/no-set [type: type])
            input-parameters
            emit-input
            if (validator?) [
                init-div
                (append tag/class [help-block with-errors])
                emit-tag
                (if def-error [emit def-error])
                end-tag
            ]
            if (not simple) [end-tag]
        ]
        checkbox: rule [] [
            'checkbox
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
            init-div
            (append tag/class 'radio)
            emit-tag
            init-input
            set name word!
            set value [word! | string! | number!]
            some [
                eval set label string!
                | eval 'checked (append tag [checked: true])
                | eval 'disabled (append tag [disabled: true])
                | style
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
            (
                size: 50x4
                label: ""
            )
            init-tag
            set name word!
            (
                value: ""
                default: ""
            )
            some [
                set size pair!
                | basic-string-match (label: value value: "")
                | 'default get-user-value set default string!
                | 'value get-user-value set value string!
                | style
            ]
            take-tag
            (
                unless empty? label [emit-label label name]
                append tag compose [
                    cols: (to integer! size/x)
                    rows: (to integer! size/y)
                    name: (name)
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
                br
                | input
                | textarea
                | checkbox
                | radio
                | submit
                | hidden
                | select-input
            ]
        ]
        form-type: none
        form-rule: rule [value form-type] [
            set tag-name 'form
            (form-type: enctype: validator?: none)
            init-tag
            any [
                'multipart (enctype: "multipart/form-data")
                | 'horizontal (form-type: 'horizontal)
                | 'validator (append tag [data-toggle: 'validator] validator?: true)
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
            take-tag
            emit-tag
            into main-rule
            (emit close-tag 'form)
        ]
        elements: rule [] [
            pos: (debug-print ["parse at: " index? pos "::" trim/lines copy/part mold pos 24])
            [
                text-settings
                | page-header
                | basic-elems
                | form-content
                | import
                | do-code
                | make-row
                | user-rules
                | user-rule
                | set-rule
                | heading
                | form-rule
                | script
                | run
                | stylesheet
                | plugins
            ]
            (
                value: none
            )
        ]
        plugins: rule [name t] [
            'enable pos: set name word! (
                either t: load-plugin name [change/part pos t 1] [pos: next pos]
            )
            :pos [main-rule | into main-rule]
        ]
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
            plugin: object bind plugin rules
            if in plugin 'rule [add-rule rules/plugins bind plugin/rule 'emit]
            if in plugin 'startup [return plugin/startup]
        ]
        none
    ]
    comment [
        user-rules: rule [] [fail]
        user-rule-names: make block! 100
        user-words: object []
        user-values: copy/deep [pos: [fail] :pos]
    ]
    out-file: none
    func [
        "Parse simple HTML dialect"
        data [block! file! url!]
        /save
        {If data is file!, save output as HTML file with same name}
        /debug
        "Turn on debug-print mode"
    ] bind [
        if any [file? data url? data] [
            out-file: replace copy data suffix? data %.html
            data: load data
        ]
        debug-print: none
        if debug [
            debug-print: :print
            debug-print "Debug output ON"
        ]
        output: copy ""
        buffer: copy ""
        header?: false
        tag-stack: copy []
        user-rules: copy [fail]
        user-rule-names: make block! 100
        user-words: object []
        user-values: copy/deep [pos: [fail] :pos]
        includes: object [
            style: make block! 1000
            stylesheets: copy ""
            header: copy ""
            body-tag: make block! 10
            body-start: make string! 1000
            body-end: make string! 1000
        ]
        used-styles: make block! 20
        page: reduce/no-set [
            title: "Page generated with Lest"
            meta: copy ""
            lang: "en-US"
        ]
        unless parse data bind rules/main-rule rules [
            error: make error! "LEST: there was error in LEST dialect"
            error/near: pos
            do error
        ]
        body: head buffer
        unless empty? includes/style [
            write %lest-temp.css prestyle includes/style
            debug-print ["CSS wrote to file %lest-temp.css"]
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
        body
    ] 'buffer
]