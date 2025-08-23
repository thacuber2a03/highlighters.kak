provide-module uxntal %§
	add-highlighter shared/uxntal regions

	#                                                          |hack?|
	add-highlighter shared/uxntal/comment region -recurse '\(' '(?<!")\(' '\)' fill comment

	add-highlighter shared/uxntal/macro  region -recurse '[\?!]?\{' '%\S+\s*\{' '\}' group
	add-highlighter shared/uxntal/macro/ regex '%\S+\s*\{' 0:meta
	add-highlighter shared/uxntal/macro/ regex '\}' 0:meta
	add-highlighter shared/uxntal/macro/ ref uxntal

	#                                                                |hack?|
	add-highlighter shared/uxntal/lambda  region -recurse '[\?!]?\{' '(?<!")\{' '\}' group
	add-highlighter shared/uxntal/lambda/ regex '\{' 0:function
	add-highlighter shared/uxntal/lambda/ regex '\}' 0:function
	add-highlighter shared/uxntal/lambda/ ref uxntal

	add-highlighter shared/uxntal/jump-lambda  region -recurse '[\?!]?\{' '[\?!]\{' '\}' group
	add-highlighter shared/uxntal/jump-lambda/ regex '[\?!]\{' 0:+u@variable
	add-highlighter shared/uxntal/jump-lambda/ regex '\}'      0:+u@variable
	add-highlighter shared/uxntal/jump-lambda/ ref uxntal

	add-highlighter shared/uxntal/code default-region group
	add-highlighter shared/uxntal/code/ regex '(?I)(?<=\s)([\da-f]{2}|[\da-f]{4})(?=\s)'  0:meta
	add-highlighter shared/uxntal/code/ regex '(?I)(?<=\s)#([\da-f]{2}|[\da-f]{4})(?=\s)' 0:value

	add-highlighter shared/uxntal/code/ regex '(?I)\|[\da-f]+' 0:attribute
	add-highlighter shared/uxntal/code/ regex '(?I)\$[\da-f]+' 0:meta

	#                                               |hack!|
	add-highlighter shared/uxntal/code/ regex '[\?!][^\s\{]+' 0:+u@variable
	add-highlighter shared/uxntal/code/ regex '[\?!]&\S+'     0:+u@function

	add-highlighter shared/uxntal/code/ regex '[,.;]\S+'        0:variable
	add-highlighter shared/uxntal/code/ regex '(?<=\s)[-=_]\S+' 0:meta
	add-highlighter shared/uxntal/code/ regex '@\S+'            0:module
	add-highlighter shared/uxntal/code/ regex '&\S+'            0:function

	add-highlighter shared/uxntal/code/ regex '"\S+' 0:string

	add-highlighter shared/uxntal/code/ regex \
		'\b(INC|POP|NIP|SWP|ROT|DUP|OVR|EQU|NEQ|GTH|LTH|JMP|JCN|JSR|STH|LDZ|STZ|LDR|STR|LDA|STA|DEI|DEO|ADD|SUB|MUL|DIV|AND|ORA|EOR|SFT)[2kr]{,3}\b' \
		0:keyword

	add-highlighter shared/uxntal/code/ regex '\bLIT[2r]{,2}\b' 0:keyword
	add-highlighter shared/uxntal/code/ regex '\bBRK\b'         0:keyword

	declare-option str-list uxntal_extra_word_chars '_' '-' '<' '>' '/'
§

hook global BufCreate .+\.tal %{ set-option buffer filetype uxntal }

hook global -group uxntal-highlight WinSetOption filetype=uxntal %{
	require-module uxntal
	add-highlighter window/uxntal ref uxntal
	hook -once -always window WinSetOption filetype=.* %{
		remove-highlighter window/uxntal
	}
}

hook global WinSetOption filetype=uxntal %{
	require-module uxntal
	set-option buffer extra_word_chars %opt{uxntal_extra_word_chars}
}
