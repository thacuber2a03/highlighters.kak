provide-module abnf %{
    add-highlighter shared/abnf regions
    add-highlighter shared/abnf/ region ';' '$' fill comment
    add-highlighter shared/abnf/ region '(%[si])?"' '"' fill string # char-val
    add-highlighter shared/abnf/ region '<' '>' fill string # prose-val

    add-highlighter shared/abnf/grammar default-region group

    add-highlighter shared/abnf/grammar/ regex '(?i)[a-z][\w-]*' 0:variable
    add-highlighter shared/abnf/grammar/ regex '\b(ALPHA|DIGIT|HEXDIG|DQUOTE|SP|HTAB|WSP|LWSP|VCHAR|CHAR|OCTET|CTL|CR|LF|CRLF|BIT)\b' 0:builtin

    # repeat
    add-highlighter shared/abnf/grammar/ regex '([=/]|=/)' 0:operator
    add-highlighter shared/abnf/grammar/ regex '(\d*\*\d*|\d+)(?=(?i)[a-z\("])' 0:meta

    # num-val
    add-highlighter shared/abnf/grammar/ regex '%d\d+(-\d+|(\.\d+)*)?' 0:value
    add-highlighter shared/abnf/grammar/ regex '%x(?i)[\da-f]+(-[\da-f]+|(\.[\da-f]+)*)?' 0:value
    add-highlighter shared/abnf/grammar/ regex '%b[01]+(-[01]+|(\.[01]+)*)?' 0:value
}

hook global BufCreate .*\.abnf$ %{ set-option buffer filetype abnf }

hook global -group abnf-highlight WinSetOption filetype=abnf %{
    require-module abnf
    add-highlighter window/abnf ref abnf
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/abnf }
}

hook global WinSetOption filetype=abnf %{
    require-module abnf

    hook window InsertChar \n -group abnf-insert abnf-insert-on-new-line
    hook window InsertChar \n -group abnf-indent abnf-indent-on-new-line
    hook window ModeChange pop:insert:.* -group abnf-trim-indent %{ try %{ execute-keys -draft <semicolon> x s ^\h+$ <ret> d } }
    set-option buffer extra_word_chars '-'

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window abnf-.+ }
}

define-command -hidden abnf-insert-on-new-line %~
    evaluate-commands -draft -itersel %=
        # copy ';' comment prefix and following white spaces
        try %{ execute-keys -draft k x s '^\h*;\h*' <ret> y jgh P }
    =
~

define-command -hidden abnf-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # cleanup trailing whitespaces from previous line
        try %{ execute-keys -draft k x s \h+$ <ret> d }
        # correct line ending with /
        # doesn't work properly, cursor ends up in
        # the line after the continuation ('rule =/')
        # try %{
        #     execute-keys -draft -itersel \
        #       'k' 'x' 's\h*/$<ret>' 'd' \
        #       'x' 's^(?i)[a-z][\w-]*(?I)\h*=<ret>' 'y' \
        #       '<a-o>' 'j' 'P' 'A/' '<esc>k'
        # }
    }
}

