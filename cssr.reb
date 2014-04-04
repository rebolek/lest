

Rebol [
    Title: "CSSR"
    Purpose: "A Style Sheet Dialect that generates CSS"
    Version: 0.1.5
    Date: 17-Jun-2013
    Author: "Christopher Ross-Gill"
    Name: 'cssr
    Type: 'module
    Exports: [to-css]
]

to-css: use [ruleset parser ??][

ruleset: context [
    ; Values
    values: copy []
    unset: func [key [word!]][remove-each [k value] values [k = key]]
    set: func [key [word!] value [any-type!]][
        unset key repend values [key value]
    ]

    ; Values that are zero or more
    colors: copy []
    lengths: copy []
    ; images: copy []
    transitions: copy []
    transformations: copy []
    ; spacing: copy []

    enspace: func [value][join " " value]

    form-color: func [value [tuple! word!]][
        enspace either value/4 [
            ["rgba(" value/1 "," value/2 "," value/3 "," either integer? value: value/4 / 255 [value][round/to value 0.01] ")"]
        ][
            ["rgb(" value/1 "," value/2 "," value/3")"]
        ]
    ]

    form-number: func [value [number!] unit [word! string! none!]][
        enspace case [
            value = 0 ["0"]
            unit [join value unit]
            value [form value]
        ]
    ]

    form-value: func [values /local value choices][
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
                url! file! [enspace [{url('} value {')}]]
                path! [enspace [{url("data:} form value {;base64,} enbase/base take values 64 {")}]]
            ]
            enspace value
        ]
    ]

    form-transform: func [transform [block!] /local name direction][
        ; [
        ;     'translate direction length
        ;   | 'rotate angle opt ['origin percent percent]
        ;   | 'scale [direction number | 1 2 number]
        ; ]

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
                    "scale" either word? transform/1 [uppercase form take transform][""]
                    "(" next form-number take transform none either tail? transform [""][
                        "," form-number take transform none
                    ] ")"
                ]
            ]
        ][keep mold head insert transform name]
    ]

    form-values: func [values [block!]][
        rejoin collect [
            while [not tail? values][keep form-value values]
        ]
    ]

    form-property: func [property [word!] values [string! block!] /vendors /inline prefix][
        if block? values [values: form-values values]
        rejoin collect [
            if any [vendors found? find [transition box-sizing transform-style transition-delay] property][
                foreach prefix [-webkit- -moz- -ms- -o-][
                    keep form-property to word! join prefix form property values
                ]
            ]
            if prefix [insert next values prefix]
            keep ["^/^-" property ":" values ";"]
        ]
    ]

    render: has [value][
        ; sort/skip values 2
        while [value: take lengths][
            value: compose [(value)]
            case [
                not find values 'width [set 'width value]
                not find values 'height [set 'height value]
            ]
        ]
        while [value: take colors][
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
                    ][
                        foreach prefix [-webkit- -moz- -ms- -o-][
                            keep form-property/inline property copy values prefix
                        ]
                    ]
                    
                ]
                switch/default property [][
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
            ; dimensions: copy []
            ; images: copy []
            transitions: copy []
            transformations: copy []
            spacing: copy []
        ]
    ]
]

parser: context [
    google-fonts-base-url: http://fonts.googleapis.com/css?family=

    ; Storage
    reset?: false
    rules: []
    google-fonts: []

    ; Basic Types
    zero: use [zero][
        [set zero integer! (zero: either zero? zero [[]][[end skip]]) zero]
    ]
    em: ['em number! | zero]
    pt: ['pt number!]
    px: [opt 'px number!]
    deg: ['deg number! | zero]
    scalar: ['* number! | zero]
    percent: ['pct number! | zero]
    vh: ['vh number! | zero]
    vw: ['vw number! | zero]
    color: [tuple! | named-color]
    time: [time!]
    pair: [pair!]
    binary: [end skip] ; [path! binary!] ; omitted until considered safe
    image: [binary | file! | url!]

    ; Optionals
    named-color: [
        'aqua | 'black | 'blue | 'fuchsia | 'gray | 'green |
        'lime | 'maroon | 'navy | 'olive | 'orange | 'purple |
        'red | 'silver | 'teal | 'white | 'yellow
    ]
    text-style: ['bold | 'italic | 'underline]
    border-style: ['solid | 'dotted | 'dashed]
    transition-attribute: [
          'width | 'height | 'top | 'bottom | 'right | 'left | 'z-index
        | 'background | 'color | 'border | 'opacity | 'margin
        | 'transform | 'font | 'indent | 'spacing
    ]
    direction: ['x | 'y | 'z]
    position-x: ['right | 'left | 'center]
    position-y: ['top | 'bottom | 'middle]
    position: [position-y | position-x]
    positions: [position-y position-x | position-y | position-x]
    repeats: ['repeat-x | 'repeat-y | 'repeat ['x | 'y] | 'no-repeat | 'no 'repeat]
    font-name: [string! | 'sans-serif | 'serif | 'monospace]
    length: [em | pt | px | percent | vh | vw]
    angle: [deg]
    number: [scalar | number!]
    box-model: ['block | 'inline 'block | 'inline-block]

    ; Capture/Use System
    ; parse block [mark ... capture (:captured)]
    mark: capture: captured: none
    use [start extent][
        mark: [start:]
        capture: [extent: (new-line/all captured: copy/part start extent false)]
    ]
    emit: func [name [word!] value [any-type!]][
        value: compose [(value)]
        ; change all the non-standard words
        foreach [from to][
            [no repeat] 'no-repeat
            [no bold] 'normal
            [no italic] 'normal
            [no underline] 'none
            [inline block] 'inline-block
            [line height] 'line-height
        ][
            replace value from to
        ]
        current/set name value
    ]
    emits: func [name [word!]][
        emit name captured
    ]

    ; The All-Powerful Selector Rule
    ; Must be a way to simplify this.
    selector: use [
        dot-word primary qualifier
        form-element form-selectors
        out selectors selector
    ][
        dot-word: use [word continue][
            ; Matches only words that begin .something
            [
                set word word!
                (continue: either #"." = take form word [[]][[end skip]])
                continue
            ]
        ]

        primary: [tag! | issue! | dot-word]
        qualifier: [primary | get-word!]

        form-element: func [element [tag! issue! word! get-word!]][
            either tag? element [to string! element][mold element]
        ]

        form-selectors: func [selectors [block!]][
            selectors: collect [
                parse selectors [
                    some [mark some qualifier capture (keep/only captured)
                    | word! capture (keep captured)]
                ]
            ]

            selectors: collect [
                while [find selectors 'and][
                    keep/only copy/part selectors selectors: find selectors 'and
                    selectors: next selectors
                ] keep/only copy selectors
            ]

            selectors: map-each selector selectors [
                collect [
                    foreach selector reverse collect [
                        while [find selector 'in][
                            keep/only copy/part selector selector: find selector 'in
                            keep 'has
                            selector: next selector
                        ] keep/only copy selector
                    ][keep selector]
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

    ; Each of the Properties fully BNFed
    property: [
          mark box-model capture (emits 'display)
        | mark 'border-box capture (emits 'box-sizing)
        | ['min 'height | 'min-height] mark length capture (emits 'min-height)
        | ['min 'width | 'min-width] mark length capture (emits 'min-width)
        | 'height mark length capture (emits 'height)
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
            | 'radius mark length capture (emits 'border-radius)
            | mark 1 4 length capture (emits 'border-width)
        ]
        | ['radius | 'rounded] mark length capture (emits 'border-radius)
        | 'rounded (emit 'border-radius [em 0.6])
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
            | mark opt 'no 'bold capture (emits 'font-weight)
            | mark opt 'no 'italic capture (emits 'font-style)
            | mark opt 'no 'underline capture (emits 'text-decoration)
            | ['line-through | 'strike 'through] (emit 'text-decoration 'line-through)
        ]
        | 'line 'height mark [length | scalar] capture (emits 'line-height)
        | 'spacing mark number capture (emits 'letter-spacing)
        | mark opt 'no 'bold capture (emits 'font-weight)
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
        | 'float mark position-x capture (emits 'float)
        | 'opaque (emit 'opacity 1)
        | mark 'pointer capture (emits 'cursor)
        | ['canvas | 'background] any [
              mark color capture (emits 'background-color)
            | mark [file! | url!] (emits 'background-image)
            | mark positions capture (emits 'background-position)
            | mark repeats capture (emits 'background-repeat)
            | mark ['contain | 'cover] capture (emits 'background-size)
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

        ; | mark binary capture (emits 'background-image) any [
        ;     mark positions capture (emits 'background-position)
        ;   | mark repeats capture (emits 'background-repeat)
        ; ]
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

        ; Any Singleton Values
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

    ; Control
    current: value: none
    errors: copy []

    ; Format Description
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

    ; CSS Reset Stylesheet
    reset: to string! decompress 64#{
    eJyNU7Fu2zAQncOvIAwUaQ0pkt0mg4x27pBu3YoMpHiSWFOkTFIOnDT/3kfJNtyi
    RQKI4pF8vHv37lgseRfjUBVFTwfyjyRvatcX5HVdROdMKOoQCk+BYsEZ53y/vin5
    L74uV6tytb5LW/e6Jhuo4tZZ4u+HURpdc+V6oe0HtiwY62JvMi6dOmRc6X3GwyBs
    xsUwGIoZd/In1Zh140VPGetWGe/WGB8xPmHcYtxlfIAP4+rtbnSRsPTACriR0uNf
    e2cPPQylwDcAq9uM1zpBa6eAVQQWqkFkAk73ONYWwK1UGd+BFT7RDxkLvTCAhuj1
    lqbZWYDDKNMPNCLY7oXPGDZGeEEEspGwoVIInCq4dLBHDKMz1jiPmEbIxEGOMTrQ
    KJaNJqNCEsFQS1ZlkCsKaRJnMUSdUHEWLjbOARc7EvAdfTIxFDTwUdfpighaTTft
    XiAZRVFoE1K6knCHNbodIRrHfPaevII4T26nufUupch6skjNCpTLjXEYEduPEkQC
    ijVdDWPfC3/IWNQoG4e9BYdRaQd1wMTxZ3aF3VbbipcbdjWgNtq280I6j4Cz3Tgb
    86Cf0ESrsnx33KlQng6tGLHeU0pSmFwY3cKdFIGMtrRhL6xY8q/fv93forfCYMQh
    984Qn5oW6XnUAYG49O4xkA8cEv+t2FmpP5Q5qsX+J9GFQkdNUsJHEtXcq4lfql86
    SXzzjnTbIbVVOpk7ZD4LUCAezPEdTfcumn2XQJMd/gWoJCFTunwglWimjtydz3bz
    VvJUQ15KCl9fby5WJ8dTCybcXKS8dsaIIb3xk3UuYI63XJ+K+sLY3NtVlffuKW9c
    PYZcW5uIaIsm+hEPA31eTMVZPLwGm529jsPL7PUb/DXa0OKBf+FvC8Kfj01abk6t
    W26ODV1ukOxvKxG8Kj8FAAA=
    }

    ; Output
    render: does [
        rejoin collect [
            keep {/* CSSR Output */^/}
            if all [
                block? google-fonts
                not empty? google-fonts
            ][
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
                                    keep back change to url! mold google-fonts/:font/:variant either variant = 1 [":"][","]
                                ]
                            ]
                        ]
                    ]
                ]
                keep "');^/"
            ]
            if reset? [
                keep "^//** CSS Reset Begin */^/^/"
                keep reset
                keep "/* CSS Reset End **/^/"
            ]
            keep "^//** CSSR Output Begin */^/^/"
            foreach [selector rule] rules [
                keep selector
                keep " "
                keep rule/render
                keep "^/"
            ]
            keep "^/^//* CSSR Output End **/^/"
        ]
    ]

    ; Is Modular
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

??: use [mark][[mark: (probe new-line/all copy/part mark 8 false)]]

to-css: func [dialect [file! url! string! block!] /local out][
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

