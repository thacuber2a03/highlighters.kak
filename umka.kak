provide-module -override umka %§
	add-highlighter shared/umka regions

	add-highlighter shared/umka/ region '//'  '$'   fill comment
	add-highlighter shared/umka/ region '/\*' '\*/' fill comment

	add-highlighter shared/umka/double_string region '"' '(?<!\\)(\\\\)*"' group
	add-highlighter shared/umka/double_string/ fill string
	add-highlighter shared/umka/double_string/ regex '\\([0abefnrtv\\]|x(?i)[\da-f]{2})' 0:value

	add-highlighter shared/umka/single_string region "'" "(?<!\\)(\\\\)*'" group
	add-highlighter shared/umka/single_string/ fill value
	add-highlighter shared/umka/single_string/ regex '\\([0abefnrtv\\]|x(?i)[\da-f]{2})' 0:meta

	add-highlighter shared/umka/code default-region group

	add-highlighter shared/umka/code/ regex '\b(true|false|null)\b' 0:value

	add-highlighter shared/umka/code/ regex "\b([a-z_][\w_]*)\b\h*(\*\h*)?(?=\()" 1:function

	add-highlighter shared/umka/code/ regex \
		'\b(break|case|const|continue|default|else|enum|fn|for|import|interface|if|in|map|return|struct|switch|type|var|weak)\b' 0:keyword

	add-highlighter shared/umka/code/ regex '\b([fs]?(print|scan)f|round|trunc|ceil|floor|abs|fabs|sqrt|sin|cos|atan|atan2|exp|log)\b' 0:builtin
	add-highlighter shared/umka/code/ regex '\b(new|make|copy|append|insert|delete|slice|sort|len|cap|sizeof|sizeofself|selfhasptr)\b' 0:builtin
	add-highlighter shared/umka/code/ regex '\b(selftypeeq|typeptr|valid|validkey|keys|resume|memusage|exit)\b' 0:builtin

	add-highlighter shared/umka/code/ regex '^\h*(import)\h*"(?:.*/)?(.*)\.um"\h*$' 1:meta 2:module

	add-highlighter shared/umka/code/ regex '(?<![\)\}\]\w\n])\h*\.[a-z_][\w_]*\b' 0:value

	add-highlighter shared/umka/code/ regex '\b(real(32)?|u?int(8|16|32)?)\b'    0:+b@type
	add-highlighter shared/umka/code/ regex '\b(bool|char|str|void|fiber|any)\b' 0:+b@type

	add-highlighter shared/umka/code/ regex 'type\h+(?i)([a-z_][\w_]*)'  1:type
	add-highlighter shared/umka/code/ regex 'const\h+(?i)([a-z_][\w_]*)' 1:value

	add-highlighter shared/umka/code/ regex '(?i)([a-z_][\w_]*)(?:\h*,\h*([a-z_][\w_]*))\h*(?=:=)' 1:variable

	add-highlighter shared/umka/code/ regex '\b[A-Z][\w_]*\b' 0:type

	add-highlighter shared/umka/code/ regex '((([-\+\*/%&\|~!=:<>])|<<|>>)=?|\+\+|--|&&|\|\||::|\.\.|\?|\^)' 0:operator

	add-highlighter shared/umka/code/ regex '([a-z_][\w_]*)::[a-z_][\w_]*' 1:module

	add-highlighter shared/umka/code/ regex 'fn\h*\(.*?\)\h*(\|).*?(\|)' 1:attribute 2:attribute

	add-highlighter shared/umka/code/ regex '\b(?i)-?\d+\b'            0:value
	add-highlighter shared/umka/code/ regex '\b-?0x(?i)[\da-f]+\b'     0:value
	add-highlighter shared/umka/code/ regex '\b(?i)-?\d+\.\d+\b'       0:value
	add-highlighter shared/umka/code/ regex '\b(?i)-?\d+\.\d+e-?\d+\b' 0:value
	add-highlighter shared/umka/code/ regex '\b(?i)-?\d+e-?\d+\b'      0:value

	declare-option str-list umka_static_words \
		'break' 'case' 'const' 'continue' 'default' 'else' 'enum' 'fn' 'for' 'import' 'interface' 'if' 'in' 'map' 'return' 'struct' 'switch' \
		'type' 'var' 'weak' 'printf' 'scanf' 'fprintf' 'fscanf' 'sprintf' 'sscanf' 'round' 'trunc' 'ceil' 'floor' 'abs' 'fabs' 'sqrt' 'sin' \
		'cos' 'atan' 'atan2' 'exp' 'log' 'new' 'make' 'copy' 'append' 'insert' 'delete' 'slice' 'sort' 'len' 'cap' 'sizeof' 'sizeofself' \
		'selfhasptr' 'selftypeeq' 'typeptr' 'valid' 'validkey' 'keys' 'resume' 'memusage' 'exit'
§

hook global BufCreate (.*/)?.*\.um %{ set-option buffer filetype umka }

hook global WinSetOption filetype=umka %{
	require-module umka

	set-option window static_words %opt{umka_static_words}

    # cleanup trailing whitespaces when exiting insert mode
    hook window ModeChange pop:insert:.* -group umka-trim-indent %{ try %{ execute-keys -draft xs^\h+$<ret>d } }
    hook window InsertChar \n -group umka-indent umka-indent-on-new-line
    hook window InsertChar \{ -group umka-indent umka-indent-on-opening-curly-brace
    hook window InsertChar \} -group umka-indent umka-indent-on-closing-curly-brace
    hook window InsertChar \n -group umka-comment-insert umka-insert-comment-on-new-line
    hook window InsertChar \n -group umka-closing-delimiter-insert umka-insert-closing-delimiter-on-new-line

	hook -once -always window WinSetOption filetype=.* %{ remove-hooks window umka-.+ }
}

hook global -group umka-highlight WinSetOption filetype=umka %{
	add-highlighter window/umka ref umka
	hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/umka }
}

define-command -hidden umka-indent-on-new-line %~
    evaluate-commands -draft -itersel %=
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon>K<a-&> }
        # cleanup trailing white spaces on the previous line
        try %{ execute-keys -draft kx s \h+$ <ret>d }
        try %<
            try %{ # line comment
                execute-keys -draft kx s ^\h*// <ret>
            } catch %{ # block comment
                execute-keys -draft <a-?> /\* <ret> <a-K>\*/<ret>
            }
        > catch %<
            # indent after lines with an unclosed { or (
            try %< execute-keys -draft [c[({],[)}] <ret> <a-k> \A[({][^\n]*\n[^\n]*\n?\z <ret> j<a-gt> >
            # indent after a switch's case/default statements
            try %[ execute-keys -draft kx <a-k> ^\h*(case|default).*:$ <ret> j<a-gt> ]
            # deindent closing brace(s) when after cursor
            try %[ execute-keys -draft x <a-k> ^\h*[})] <ret> gh / [})] <ret> m <a-S> 1<a-&> ]
        >
    =
~

define-command -hidden umka-indent-on-opening-curly-brace %[
    # align indent with opening paren when { is entered on a new line after the closing paren
    try %[ execute-keys -draft -itersel h<a-F>)M <a-k> \A\(.*\)\h*\n\h*\{\z <ret> s \A|.\z <ret> 1<a-&> ]
]

define-command -hidden umka-indent-on-closing-curly-brace %[
    # align to opening curly brace when alone on a line
    try %[ execute-keys -itersel -draft <a-h><a-k>^\h+\}$<ret>hms\A|.\z<ret>1<a-&> ]
]

define-command -hidden umka-insert-comment-on-new-line %[
    evaluate-commands -no-hooks -draft -itersel %[
        # copy // comments prefix and following white spaces
        try %{ execute-keys -draft <semicolon><c-s>kx s ^\h*\K/{2,}\h* <ret> y<c-o>P<esc> }
    ]
]

define-command -hidden umka-insert-closing-delimiter-on-new-line %[
    evaluate-commands -no-hooks -draft -itersel %[
        # Wisely add '}'.
        evaluate-commands -save-regs x %[
            # Save previous line indent in register x.
            try %[ execute-keys -draft kxs^\h+<ret>"xy ] catch %[ reg x '' ]
            try %[
                # Validate previous line and that it is not closed yet.
                execute-keys -draft kx <a-k>^<c-r>x.*\{\h*\(?\h*$<ret> j}iJx <a-K>^<c-r>x\)?\h*\}<ret>
                # Insert closing '}'.
                execute-keys -draft o<c-r>x}<esc>
                # Delete trailing '}' on the line below the '{'.
                execute-keys -draft xs\}$<ret>d
            ]
        ]

        # Wisely add ')'.
        evaluate-commands -save-regs x %[
            # Save previous line indent in register x.
            try %[ execute-keys -draft kxs^\h+<ret>"xy ] catch %[ reg x '' ]
            try %[
                # Validate previous line and that it is not closed yet.
                execute-keys -draft kx <a-k>^<c-r>x.*\(\h*$<ret> J}iJx <a-K>^<c-r>x\)<ret>
                # Insert closing ')'.
                execute-keys -draft o<c-r>x)<esc>
                # Delete trailing ')' on the line below the '('.
                execute-keys -draft xs\)\h*\}?\h*$<ret>d
            ]
        ]
    ]
]
