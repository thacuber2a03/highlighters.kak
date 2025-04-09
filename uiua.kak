# TODO:
# - W in @\W is bold (assumed to be influenced by constant W)
#   - hackily fixed, still an issue though
# - implement full-name functions and &-functions
#   - on it

provide-module uiua %{
	set-face global UiuaMonadicFunction function
	set-face global UiuaDyadicFunction  operator
	set-face global UiuaTriadicFunction type
	set-face global UiuaMonadicModifier attribute
	set-face global UiuaDyadicModifier  meta
	set-face global UiuaNoadicFunction  value
	set-face global UiuaMacro           meta

	add-highlighter shared/uiua regions

	add-highlighter shared/uiua/ region '#' $ fill comment

	add-highlighter shared/uiua/format-string region '\$"' (?<!\\)(\\\\)*" group
	add-highlighter shared/uiua/format-string/ fill string
	add-highlighter shared/uiua/format-string/ regex '_' 0:+r@value

	add-highlighter shared/uiua/format-multistring region '\$\$' $ group
	add-highlighter shared/uiua/format-multistring/ fill string
	add-highlighter shared/uiua/format-multistring/ regex '_' 0:+r@value

	add-highlighter shared/uiua/ region (?<![\$\\@])" (?<!\\)(\\\\)*" fill string
	add-highlighter shared/uiua/ region (?<!\$)\$ $ fill string

	add-highlighter shared/uiua/code default-region group

	add-highlighter shared/uiua/code/ regex '\.|:|◌|∘|¬|±|¯|⌵|√|∿|⌊|⌈|⁅|⧻|△|⇡|⊢|⊣|⇌|♭|¤|⋯|⍉|⍆|⍏|⍖|⊚|⊛|◴|◰|□|⋕'       0:UiuaMonadicFunction
	add-highlighter shared/uiua/code/ regex '=|≠|<|≤|>|≥|\+|-|×|\*|÷|%|◿|ⁿ|ₙ|↧|↥|∠|ℂ|≍|⊟|⊂|⊏|⊡|↯|↙|↘|↻|⤸|▽|⌕|⦷|∊|⊗|⍤' 0:UiuaDyadicFunction
	add-highlighter shared/uiua/code/ regex '/|∧|\\|∵|≡|⍚|⊞|⧅|⧈|⍥|⊕|⊜|◇|⋅|⊙|⟜|⊸|⤙|⤚|◡|◠|˙|˜|∩|⌅|°|⌝'                 0:UiuaMonadicModifier
	add-highlighter shared/uiua/code/ regex '⍜|⊃|⊓|⍢|⬚|⨬|⍣|⍩|∂|∫'                                                    0:UiuaDyadicModifier
	add-highlighter shared/uiua/code/ regex '⚂'                                                                      0:UiuaNoadicFunction
	add-highlighter shared/uiua/code/ regex 'η|π|τ|∞'                                                                0:value

	add-highlighter shared/uiua/code/ regex '\b(tag|now|timezone)\b'                                                        0:UiuaNoadicFunction
	add-highlighter shared/uiua/code/ regex '\b(wait|recv|tryrecv|graphemes|json|csv|xlsx|binary|type|datetime|fft|repr)\b' 0:UiuaMonadicFunction
	add-highlighter shared/uiua/code/ regex '\b(send|map|has|get|remove|img|gif|layout|gen|regex|base)\b'                   0:UiuaDyadicFunction
	add-highlighter shared/uiua/code/ regex '\b(insert|audio|path)\b'                                                       0:UiuaTriadicFunction
	add-highlighter shared/uiua/code/ regex '\b(memo|comptime|quote|dump|spawn|pool)\b'                                     0:UiuaMonadicModifier

	add-highlighter shared/uiua/code/ regex '\butf₈(?![₋₁₂₃₄₅₆₇₈₉₀])' 0:UiuaMonadicFunction # so alone :(

	add-highlighter shared/uiua/code/ regex '&(sc|ts|args|asr|b|clip)\b'                                                           0:UiuaNoadicFunction
	add-highlighter shared/uiua/code/ regex '&(cd|fo|fc|fmd|fde|ftr|fe|fld|fif|fras|frab|s|pf|p|epf|ep|raw|var|cl|runi|runc)\b'    0:UiuaMonadicFunction
	add-highlighter shared/uiua/code/ regex '&(runs|invk|ims|ap|tcpl|tlsl|tcpa|tcpc|tlsc|tcpsnb|tcpaddr|memfree|exit|sl|camcap)\b' 0:UiuaMonadicFunction
	add-highlighter shared/uiua/code/ regex '&(fwa|rs|rb|ru|w|gifs|tcpsrt|tcpswt|ffi)\b'                                           0:UiuaDyadicFunction
	add-highlighter shared/uiua/code/ regex '&(memcpy)\b'                                                                          0:UiuaTriadicFunction
	add-highlighter shared/uiua/code/ regex '&(rl|ast)\b'                                                                          0:UiuaMonadicModifier

	# constants
	#                                                   |hack |
	add-highlighter shared/uiua/code/ regex '\b(e|i|NaN|(?<!\\)W|MaxInt|ε|HexDigits|Days|Months|MonthDays|LeapMonthDays|True|False)\b'     0:builtin
	add-highlighter shared/uiua/code/ regex '\b(NULL|Logo|Lena|Cats|Music|Lorem|Os|Family|Arch|ExeExt|DllExt|Sep|ThisFile|ThisFileName)\b' 0:builtin
	add-highlighter shared/uiua/code/ regex '\b(ThisFileDir|WorkingDir|NumProcs|Planets|Zodiac|Suits|Cards|Chess|Moon|Skin|People|Hair)\b' 0:builtin
	add-highlighter shared/uiua/code/ regex '\b(A₁|A₂|A₃|C₂|C₃|E₃)(?![₋₁₂₃₄₅₆₇₈₉₀])'                                                       0:builtin

	# numbers
	add-highlighter shared/uiua/code/ regex '[`¯]?(?i)(?:[0-9]+(?:\.[0-9]+)?(?:e[-`¯]?[0-9]+)?)' 0:value # normal
	add-highlighter shared/uiua/code/ regex '[`¯]?(?:\d+/[`¯]?\d+)'                              0:value # fractions

	add-highlighter shared/uiua/code/ regex '[A-Z][A-Za-z0-9]*(?:__[`\d]+|₋?[₁₂₃₄₅₆₇₈₉₀]+)?\h*(?=[=←↚])' 0:function  # function definition
	add-highlighter shared/uiua/code/ regex '[A-Z][A-Za-z0-9]*(?:__[`\d]+|₋?[₁₂₃₄₅₆₇₈₉₀]+)?[!‼]+'        0:UiuaMacro # macro

	add-highlighter shared/uiua/code/ regex '\b([dg]+)([ip])\b' 1:UiuaMonadicModifier 2:UiuaMonadicFunction

	add-highlighter shared/uiua/code/ regex '(?<!_)_(?!_)'                                 0:operator # strand notation
	add-highlighter shared/uiua/code/ regex '([A-Z][A-Za-z0-9]*(?:__[`\d]+|₋?[₁₂₃₄₅₆₇₈₉₀]+)?)?\h*~' 0:module   # module operator

	add-highlighter shared/uiua/code/ regex '@(?:(?i)\\u(?:\{[\da-f]+\}|[\da-f]{4})|\\x[\da-f]{2}|(?I)\\[nrt0sb\\"''_WZ]|( )|[^\h\\])' 0:value 1:+r

	add-highlighter shared/uiua/code/ regex '┌─╴[A-Z][A-Za-z0-9]*' 0:module
	add-highlighter shared/uiua/code/ regex '└─╴'                  0:module

	# colors
	add-highlighter shared/uiua/code/ regex '\b(?:(White)|(Black)|(Red)|(Orange)|(Yellow)|(Green)|(Cyan)|(Blue)|(Purple)|(Magenta))\b' \
		1:rgb:000000,rgb:ffffff 2:rgb:ffffff,rgb:000000 3:rgb:ffffff,rgb:ff0000 4:rgb:ffffff,rgb:ffa500  5:rgb:000000,rgb:ffff00 \
		6:rgb:000000,rgb:00ff00 7:rgb:000000,rgb:00ffff 8:rgb:ffffff,rgb:0000ff 9:rgb:ffffff,rgb:800080 10:rgb:ffffff,rgb:ff00ff

	# pride constants
	add-highlighter shared/uiua/code/ regex '\b(R)(a)(i)(n)(b)(o)(w)\b' 0:rgb:000000 1:,rgb:e40303           2:,rgb:ff8c00           3:,rgb:ffed00           4:,rgb:008026           5:,rgb:008026           6:,rgb:004cff 7:,rgb:732982
	add-highlighter shared/uiua/code/ regex '\b(L)(e)(s)(b)(i)(a)(n)\b' 0:rgb:000000 1:,rgb:d52d00           2:,rgb:ef7627           3:,rgb:ff9a56           4:rgb:000000,rgb:ffffff 5:,rgb:d162a4           6:,rgb:b55690 7:,rgb:b55690
	add-highlighter shared/uiua/code/ regex '\b(G)(a)(y)\b'             0:rgb:000000 1:,rgb:078d70           2:,rgb:ffffff           3:rgb:ffffff,rgb:3d1a78
	add-highlighter shared/uiua/code/ regex '\b(B)(i)\b'                0:rgb:ffffff 1:,rgb:d60270           2:,rgb:0038a8
	add-highlighter shared/uiua/code/ regex '\b(T)(r)(a)(n)(s)\b'       0:rgb:000000 1:,rgb:5bcefa           2:,rgb:f5a9b8           3:,rgb:ffffff           4:,rgb:f5a9b8           5:,rgb:5bcefa
	add-highlighter shared/uiua/code/ regex '\b(P)(a)(n)\b'             0:rgb:000000 1:,rgb:ff218c           2:,rgb:ffd800           3:,rgb:21b1ff
	add-highlighter shared/uiua/code/ regex '\b(A)(c)(e)\b'             0:rgb:ffffff 1:,rgb:000000           2:rgb:000000,rgb:ffffff 3:,rgb:800080
	add-highlighter shared/uiua/code/ regex '\b(A)(r)(o)\b'             0:rgb:ffffff 1:,rgb:3da542           2:rgb:000000,rgb:ffffff 3:rgb:ffffff,rgb:000000
	add-highlighter shared/uiua/code/ regex '\b(A)(r)(o)(A)(c)(e)\b'    0:rgb:ffffff 1:rgb:000000,rgb:e38d00 2:rgb:000000,rgb:edce00 3:rgb:000000,rgb:ffffff 4:rgb:000000,rgb:ffffff 5:rgb:000000,rgb:62b0dd 6:,rgb:1a3555
	add-highlighter shared/uiua/code/ regex '\b(E)(n)(b)(y)\b'          0:rgb:000000 1:,rgb:fcf434           2:,rgb:ffffff           3:,rgb:9C59D1           4:rgb:ffffff,rgb:000000
	add-highlighter shared/uiua/code/ regex '\b(F)(l)(u)(i)(d)\b'       0:rgb:000000 1:,rgb:ff76a4           2:,rgb:ffffff           3:,rgb:c011d7           4:rgb:ffffff,rgb:000000 5:,rgb:2f3cbe
	add-highlighter shared/uiua/code/ regex '\b(Q)(u)(e)(e)(r)\b'       0:rgb:000000 1:,rgb:b57edc           2:,rgb:b57edc           3:,rgb:ffffff           4:,rgb:4a8123           5:,rgb:4a8123
	add-highlighter shared/uiua/code/ regex '\b(A)(g)(e)(n)(d)(e)(r)\b' 0:rgb:000000 1:rgb:ffffff,rgb:000000 2:,rgb:bcc4c7           3:,rgb:ffffff           4:,rgb:b7f684           5:,rgb:ffffff           6:,rgb:bcc4c7 7:rgb:ffffff,rgb:000000

	add-highlighter shared/uiua/code/ regex '(⟜)(⊸)' 1:rgb:000000,rgb:fcf434 2:rgb:ffffff,rgb:9C59D1
	add-highlighter shared/uiua/code/ regex '(⊟)(₁)' 1:rgb:ffffff,rgb:3da542 2:rgb:000000,rgb:a7d379
}

hook global BufCreate .*\.ua %{ set-option buffer filetype uiua }

hook global WinSetOption filetype=uiua %{
	set-option buffer extra_word_chars '₋' '₁' '₂' '₃' '₄' '₅' '₆' '₇' '₈' '₉' '₀' 
}

hook -group uiua-highlight global WinSetOption filetype=uiua %{
	require-module uiua
	add-highlighter window/uiua ref uiua
	hook -once -always window WinSetOption filetype=.* %{
		remove-highlighter window/uiua
	}
}
