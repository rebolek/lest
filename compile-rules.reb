REBOL [
	Title: "COMPILE-RULES with integrated dialect framework"
	Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
	File: %compile-rules.reb
	Date: 20-5-2014
 	Version: 1.5.0 ; majorv.minorv.status
				   ; status: 0: unfinished; 1: testing; 2: stable
	History: [
		13-Jan-2003 1.1.0 "History start"
		14-Jan-2003 1.2.0 "First version"
         6-Mar-2003 1.3.0 "Integrating PARSE-DIALECT's functionality in COMPILE-RULES"
         6-Mar-2003 1.4.0 "First working version of COMPILE-RULES with new INTERPRET rule"
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
;    Type: 'module
;    Name: 'compile-rules
;    Exports: [compile-rules control-functions]
]

control-functions: none

context [
    ; PARSE grammar
    element: [
        set val1 paren! (emit/only :val1)                 ; action
      | into grammar (emit/only last-block)               ; sub-rule
      | 'skip (emit 'skip)                                ; skip one
      | 'end (emit 'end)                                  ; match end of string/block
      | 'to set val1 skip (emit 'to emit/only :val1)      ; skip to value
      | 'thru set val1 skip (emit 'thru emit/only :val1)  ; skip thru value
      | 'break (emit 'break)                              ; break iteration
      | 'into (emit 'into) [                              ; parse sub-block
            into grammar (emit/only last-block)
          | set val1 word! (if block? get/any val1 [emit handle-subrule-word val1])
        ]
      | 'interpret 'with [                                ; NEW: handle iteration and control functions, apply rule
            into grammar (emit mk-interpret last-block)
          | set val1 word! (if block? get/any val1 [emit mk-interpret handle-subrule-word val1])
        ]
      | set val1 word!                                    ; look up word (usually, sub-rule or datatype)
            (either block? get/any val1 [emit handle-subrule-word val1] [emit val1])
      | set val1 set-word! (emit :val1)                   ; set word to cursor
      | set val1 get-word! (emit :val1)                   ; get cursor from word
      | set val1 lit-word! (emit :val1)                   ; match literal word
      | set val1 skip (emit :val1)                        ; match value
    ]

    rule: [
        'none (emit 'none)                         ; match nothing
      | 'opt (emit 'opt) element                   ; optional match
      | 'some (emit 'some) element                 ; match one or more
      | 'any (emit 'any) element                   ; match zero or more
      | 'if set val1 paren!                        ; NEW: apply rule only if condition is true
            (start-block   push :val1)
            element
            (end-block     emit mk-if pop last-block)
      | 'either set val1 paren!                    ; NEW: choose rule based on condition
            (push :val1    start-block)
            element
            (end-block     push last-block  start-block)
            element
            (end-block     emit mk-either pop pop last-block)
      | copy val1 1 2 integer! (emit val1) element ; match specified number of times
      | element                                    ; match element once
    ]

    val1: val2: pos: none
    valstack: [ ]
    push: func [value] [insert/only tail valstack value]
    pop: has [value] [value: last valstack remove back tail valstack value]

    complete-rule: [
        ; set value
        'set set val1 word! (emit 'set emit val1) rule
        ; copy match
      | 'copy set val1 word! (emit 'copy emit val1) rule
        ; NEW: evaluate expression and set result
      | 'do set val1 word!
            (start-block   push val1)
            rule
            (end-block     emit/only mk-evaluate pop last-block)
        ; NEW: raise error if rule does not match
      | 'throw set val1 string!
            (start-block   push val1)
            rule
            (end-block     emit/only mk-throw pop last-block)
        ; just match
      | rule
    ]
    
    stack: [ ]
    last-block: none
    ctx: [ ]

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
                        ; TODO: fix DISARM for R3
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
                __stack: [ ]
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
        ; returns: does not return, raises an error!
        /local disarmed
    ] [
        insert head error/arg1 "LEST dialect error: "
        error/near: cursor
        error
    ]

    ; Until we get DO and THROW handled natively, we'll use COMPILE-RULES
    set 'compile-rules func [
        "Compile an extended PARSE rule to a normal PARSE rule"
        rule [block!]
        /all "Return an object with the whole compiled rule"
        ; returns: the result of compiling rule; if /all, an object is returned
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
            ;/args {If value is a script, this will set its system/script/args} 
            ;arg "Args passed to a script. Normally a string." 
            ;/next {Do next expression only.  Return block with result and new position.}
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
            "Evaluates a block in the dialect's context for each value(s) in a series." 
            [throw]
            'word [get-word! word! block!] {Word or block of words to set each time (will be local)} 
            data [series!] "The series to traverse" 
            body [block!] "Block to evaluate each time"
        ] [
            lib/if get-word? :word [word: get :word]
            lib/foreach :word data compose/only [handle-dialect-block (body)]
        ]
        if: lib/func [
            "If condition is TRUE, evaluates the block in the dialect's context." 
            [throw]
            condition 
            then-block [block!] 
        ] [
            lib/if condition [
                handle-dialect-block then-block
            ]
        ]
        loop: lib/func [
            "Evaluates a block in the dialect's context a specified number of times." 
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
            "Evaluates a block in the dialect's context until it is TRUE." 
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
            "Defines a user function in the dialect's context with given spec and body." 
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
        ;function: lib/func [
        ;    "Defines a user function in the dialect's context with local words." 
        ;    [catch]
        ;    spec [block!] {Optional help info followed by arg words (and optional type and string)} 
        ;    vars [block!] "List of words that are local to the function" 
        ;    body [block!] "The body block of the function"
        ;] [
        ;    lib/throw-on-error [func head insert insert tail copy spec /local vars body]
        ;]
        ;does: ib/func [
        ;    {A shortcut to define a function that has no arguments or locals.} 
        ;    [catch] 
        ;    body [block!] "The body block of the function"
        ;] [
        ;    lib/throw-on-error [func [] body]
        ;]
        ;has: lib/func [
        ;    {A shortcut to define a function that has local variables but no arguments.} 
        ;    [catch]
        ;    locals [block!] 
        ;    body [block!]
        ;] [
        ;    lib/throw-on-error [function [] locals body]
        ;]
        forall: lib/func [
            "Evaluates a block in the dialect's context for every value in a series." 
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
            "Evaluates a block in the dialect's context for periodic values in a series." 
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
            "Repeats a block in the dialect's context over a range of values." 
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
            "Evaluates a block in the dialect's context endlessly." 
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
