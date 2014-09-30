REBOL [
    Title: "Lest (preprocessed)"
]
comment "plugin cache"
plugin-cache: [google-analytics [
        rule: use [value web] [
            [
                'ga
                set value word!
                set web word!
                (
                    debug ["==GOOGLE ANALYTICS:" value web]
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
            append script js-path/jquery-2.1.0.min.js
            append script js-path/bootstrap.min.js
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
            | end
        ]
        grid-elems: [
            set type ['row | 'container]
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
                debug ["==GLYPHICON: " name]
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
            (
                value-to-emit: [
                    <div class="container">
                    <div class="navbar-collapse collapse">
                    <ul id="page-nav" class="nav navbar-nav">
                ]
            )
            emit-value
            [some navbar-content | into some navbar-content]
            (value-to-emit: [</ul> </div> </div>])
            emit-value
            end-tag
        ]
        navbar-content: [
            'link (active?: false)
            opt ['active (active?: true)]
            some [
                set target [file! | url! | issue!]
                | set value string!
            ]
            (value-to-emit: ajoin [
                    "<li"
                    either active? [{ class="active">}] [#">"]
                    {<a href="} target {">} value
                    </a>
                    </li>
                ])
            emit-value
        ]
        carousel: [
            'carousel
            init-tag
            (
                debug "==CAROUSEL"
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
                debug "==MODAL"
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
    ] markdown [
        startup: [
            debug "==ENABLE MARKDOWN"
            do %md.reb
        ]
        rule: [
            'markdown
            set value string! (emit markdown value)
        ]
    ] smooth-scrolling [
        startup: [
            debug "==ENABLE SMOOTH SCROLLING"
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
    ] pretty-photo [
        startup: [
            append script js-path/jquery.prettyPhoto.js
            append script {
^-  $(document).ready(function(){
^-    $("a[rel='prettyPhoto']").prettyPhoto();
^-  });
^-}
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
    ] font-awesome [
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
                (debug ["==FA-ICON:" name])
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
    ] lightbox [
        startup: [
            stylesheet css-path/bootstrap-lightbox.min.css
            insert script js-path/bootstrap-lightbox.min.js
        ]
    ] google-maps [
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
            'wysiwyg (debug ["==WYSIWYG matched"])
            init-tag
            opt style
            (
                debug ["==WYSIWYG"]
                tag-name: 'textarea
                append tag/class 'wysiwyg
            )
            emit-tag
            end-tag
        ]
    ] bootstrap-datetime-picker [
        startup: [
            stylesheet css-path/bootstrap-datetimepicker.min.css
            append script js-path/bootstrap-datetimepicker.min.js
        ]
        rule: [
            'datetime
        ]
    ] google-font [
        startup: [
            stylesheet css-path/bootstrap.min.css
        ]
        rule: [
            'google-font
            set name string!
            (
                debug ["==GFONT:" name]
                repend includes/header [
                    {<link href='http://fonts.googleapis.com/css?family=}
                    replace/all name #" " #"+"
                    {:400,300&amp;subset=latin,latin-ext' rel='stylesheet' type='text/css'>}
                ]
                repend includes/style ['google 'fonts name #400]
            )
        ]
    ]]
comment "/plugin cache"
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
