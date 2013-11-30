Rebol [
	Title: "Catch-any"
	File: %catch-any.r
	Author: "Ladislav Mecir"
	Purpose: "Catch any REBOL exception"
]

make object! [
	do-block: func [
		; helper for catching BREAK, CONTINUE, THROW or QUIT
		block [block!]
		exception [word!]
		/local result
	] [
		; TRY wraps CATCH/QUIT to circumvent bug#851
		try [
			catch/quit [
				catch [
					loop 1 [
						try [
							set exception 'return
							set/any 'result do block
							set exception none
							return :result
						]
						; an error was triggered
						set exception 'error
						exit
					]
					; BREAK or CONTINUE
					set exception 'break
					exit
				]
				; THROW
				set exception 'throw
				exit
			]
			; QUIT
			set exception 'quit
			exit
		]
	]

	set 'catch-any func [
		{catches any REBOL exception}
		block [block!] {block to evaluate}
		exception [word!] {used to return the exception type}
		/local result
	] either rebol/version >= 2.100.0 [[
		; catch RETURN, EXIT and RETURN/REDO
		; using the DO-BLOCK helper call
		; the helper call is enclosed in a block
		; not containing any additional values
		; to not give REDO any "excess arguments"
		; also, it is necessary to catch all above exceptions again
		; in case they are triggered by REDO
		; TRY wraps CATCH/QUIT to circumvent bug#851
		try [
			catch/quit [
				try [
					catch [
						loop 1 [set/any 'result do-block block exception]
					]
				]
			]
		]
		either get exception [#[unset!]] [:result]
	]] [[
		error? set/any 'result catch [
			error? set/any 'result loop 1 [
				error? result: try [
					; RETURN or EXIT
					set exception 'return
					set/any 'result do block
					
					; no exception
					set exception none
					return get/any 'result
				]
				; an error was triggered
				set exception 'error
				return result
			]
			; BREAK
			set exception 'break
			return get/any 'result
		]
		; THROW
		set exception 'throw
		return get/any 'result
	]]
]
