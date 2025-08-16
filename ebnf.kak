# https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form

provide-module ebnf %{
    add-highlighter shared/ebnf regions

	# huh, no escapes apparently
    add-highlighter shared/ebnf/ region '"' '(?<!\\)(?:\\\\)*"' fill string
    add-highlighter shared/ebnf/ region "'" "(?<!\\)(?:\\\\)*'" fill string

    add-highlighter shared/ebnf/ region '\?' '\?' fill meta # this just makes sense

    add-highlighter shared/ebnf/ region -recurse '\(\*' '\(\*' '\*\)' fill comment

    add-highlighter shared/ebnf/grammar default-region group

    add-highlighter shared/ebnf/grammar/ regex '(?i)\b[a-z]\w*\b' 0:variable # non-terminal

    add-highlighter shared/ebnf/grammar/ regex '(?:\(:|:\)|[=,;\.\[\]\{\}\(\)\|/!-])' 0:operator # meaningful symbols
}

hook global BufCreate .+\.ebnf$ %{ set-option buffer filetype ebnf }

hook global -group ebnf-highlight WinSetOption filetype=ebnf %{
    require-module ebnf
    add-highlighter window/ebnf ref ebnf
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/ebnf }
}

hook global WinSetOption filetype=ebnf %{
    require-module ebnf

    hook window ModeChange pop:insert:.* -group ebnf-trim-indent %{ try %{ execute-keys -draft <semicolon> x s ^\h+$ <ret> d } }
    hook window InsertChar \n -group ebnf-indent ebnf-indent-on-new-line

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window ebnf-.+ }
}

define-command -hidden ebnf-indent-on-new-line %{
    evaluate-commands -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # cleanup trailing whitespaces from previous line
        try %{ execute-keys -draft k x s \h+$ <ret> d }
    }
}


