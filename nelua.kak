provide-module nelua %§
	require-module lua

	add-highlighter shared/nelua regions

	add-highlighter shared/nelua/ region -match-capture '##\[(=*)\[' '\](=*)\]' fill meta
	add-highlighter shared/nelua/ region '##' $ fill meta
	add-highlighter shared/nelua/ region '#[\[\|]' '[\]\|]#' fill meta

	# currently copied from rc/filetype/lua.kak
	add-highlighter shared/nelua/raw_string  region -match-capture   '\[(=*)\[' '\](=*)\]' fill string
	add-highlighter shared/nelua/raw_comment region -match-capture '--\[(=*)\[' '\](=*)\]' fill comment
	add-highlighter shared/nelua/double_string region '"'   (?<!\\)(?:\\\\)*" fill string
	add-highlighter shared/nelua/single_string region "'"   (?<!\\)(?:\\\\)*' fill string
	add-highlighter shared/nelua/comment       region '--'  $                 fill comment

	add-highlighter shared/nelua/code default-region group

	add-highlighter shared/nelua/code/ regex '(&|\||~|\$)' 0:operator

	# this should really be fixed in upstream lua.kak
	# but I don't know how and I'm concerned
	# add-highlighter shared/nelua/code/ regex '\b([a-zA-Z_]\w*)\h*(?=")' 1:function

	add-highlighter shared/nelua/code/ ref lua/code

	# this feels like a strange overload
	add-highlighter shared/nelua/code/ regex '\b([0-9]+(:?\.[0-9])?(:?[eE]-?[0-9]+)?|0x[0-9a-fA-F]+)_(f(32|64|128)|[ui](s|8|16|32|64|128)|[iunb])\b' 0:value
	add-highlighter shared/nelua/code/ regex '\b([0-9]+(:?\.[0-9])?(:?[eE]-?[0-9]+)?|0x[0-9a-fA-F]+)_(number|byte|[ui]size|float(32|64|128)|u?int(eger|8|16|32|64|128))\b' 0:value

	add-highlighter shared/nelua/code/ regex '(@)[\*\[\]\d]*(\w+)' 1:operator 2:type

	add-highlighter shared/nelua/code/ regex '\b(global|switch|case|defer|continue|fallthrough)\b' 0:keyword

	add-highlighter shared/nelua/code/ regex '\b(nilptr)\b' 0:value

	add-highlighter shared/nelua/code/ regex '\b(0b[01]+)\b' 0:value
	add-highlighter shared/nelua/code/ regex '\b0x[0-9a-fA-F]+\b' 0:value
	add-highlighter shared/nelua/code/ regex '\.\.\.?' 0:operator

	add-highlighter shared/nelua/code/ regex '\b(u?integer|number|byte|[iu]?(size|int(8|16|32|64|128)?)|string|boolean|pointer|void|(nil)?type|varargs|auto|facultative|span|record|enum|union)\b' 0:type
	add-highlighter shared/nelua/code/ regex '\bc(u?short|u?int|u?long(long)?|ptrdiff|[su]?char|size|longdouble|string)\b' 0:type

	define-command nelua-alternative-file -docstring 'Jump to the alternate file (implementation ↔ test)' lua-alternative-file
	define-command nelua-trim-indent lua-trim-indent

	define-command -hidden nelua-indent-on-char %[
	    evaluate-commands -no-hooks -draft -itersel %[
	        # unindent middle and end structures
	        try %[ execute-keys -draft \
	            <a-h><a-k>^\h*(\b(end|else|elseif|until|case)\b|[)}])$<ret> \
	            :nelua-indent-on-new-line<ret> \
	            <a-lt>
	        ]
	    ]
	]

	define-command -hidden nelua-indent-on-new-line %[
	    evaluate-commands -no-hooks -draft -itersel %[
	        # remove trailing white spaces from previous line
	        try %[ execute-keys -draft k : nelua-trim-indent <ret> ]
	        # preserve previous non-empty line indent
	        try %[ execute-keys -draft ,gh<a-?>^[^\n]+$<ret>s\A|.\z<ret>)<a-&> ]
	        # add one indentation level if the previous line is not a comment and:
	        #     - starts with a block keyword that is not closed on the same line,
	        #     - or contains an unclosed function expression,
	        #     - or ends with an enclosed '(' or '{'
	        try %[ execute-keys -draft \
	            , Kx \
	            <a-K>\A\h*--<ret> \
	            <a-K>\A[^\n]*\b(end|until)\b<ret> \
	            <a-k>\A(\h*\b(switch|do|else|elseif|for|(local\h+)?function|if|repeat|while|case|defer)\b|[^\n]*[({]$|[^\n]*\bfunction\b\h*[(])<ret> \
	            <a-:><semicolon><a-gt>
	        ]
	    ]
	]

	define-command -hidden nelua-insert-on-new-line %[
	    evaluate-commands -no-hooks -draft -itersel %[
	        # copy -- comment prefix and following white spaces
	        try %[ execute-keys -draft kxs^\h*\K--\h*<ret> y gh j x<semicolon> P ]
	        # wisely add end structure
	        evaluate-commands -save-regs x %[
	            # save previous line indent in register x
	            try %[ execute-keys -draft kxs^\h+<ret>"xy ] catch %[ reg x '' ]
	            try %[
	                # check that starts with a block keyword that is not closed on the same line
	                execute-keys -draft \
	                    kx \
	                    <a-k>^\h*\b(else|elseif|do|for|(local\h+)?function|if|while|defer|switch)\b|[^\n]\bfunction\b\h*[(]<ret> \
	                    <a-K>\bend\b<ret>
	                # check that the block is empty and is not closed on a different line
	                execute-keys -draft <a-a>i <a-K>^[^\n]+\n[^\n]+\n<ret> jx <a-K>^<c-r>x\b(else|elseif|end)\b<ret>
	                # auto insert end
	                execute-keys -draft o<c-r>xend<esc>
	                # auto insert ) for anonymous function
	                execute-keys -draft kx<a-k>\([^)\n]*function\b<ret>jjA)<esc>
	            ]
	        ]
	    ]
	]

§

hook global BufCreate .+\.nelua %{
	set-option buffer filetype nelua
}

hook -group nelua-highlight global WinSetOption filetype=nelua %{
	require-module nelua
	add-highlighter window/nelua ref nelua
	hook -once -always window WinSetOption filetype=.* %{
		remove-highlighter window/nelua
	}
}

hook global WinSetOption filetype=nelua %{
	require-module nelua

	hook window ModeChange pop:insert:.* -group nelua-trim-indent nelua-trim-indent
	hook window InsertChar .* -group nelua-indent nelua-indent-on-char
	hook window InsertChar \n -group nelua-indent nelua-indent-on-new-line
	hook window InsertChar \n -group nelua-insert nelua-insert-on-new-line

	alias window alt nelua-alternative-file

	hook -once -always window WinSetOption filetype=.* %{
		remove-hooks window nelua-.+
		unalias window alt nelua-alternative-file
	}
}
