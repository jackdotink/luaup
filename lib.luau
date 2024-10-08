--- Stores the locational information of a token or AST node.
--- 
--- Components:
--- * x: The start index.
--- * y: The end index.
--- * z: Unused.
export type Span = { read x: number, read y: number, read z: number }

--- Represents trivia unimportant to parsing: comments and whitespace.
export type Trivia =
	--- Holds a segment of whitespace. Note that the luaup lexer will lex
	--- multiple characters of whitespace into a single whitespace trivia.
	| { read kind: "whitespace", read text: string, read span: Span }
	--- Holds a comment. Note that the comment header (`--` or `--[[]]`) is
	--- included in the text field.
	| { read kind: "comment", read text: string, read span: Span }

--- A token, such as an identifier, number, string, keyword, or symbol.
--- 
--- Each variant includes `span` and `trivia` fields. The `span` field stores
--- the location of the token, and the `trivia` field stores any trivia in front
--- of the token.
--- 
--- Some tokens have a `text` field which stores the text of the token. This
--- field is only present for tokens that can have different text in each
--- instance, such as identifiers or strings.
export type Token =
	--- The end of file.
	| { read kind: "eof", read span: Span, read trivia: { Trivia } }
	--- An error token, emitted when the lexer encounters an unknown character
	--- or a broken string or number.
	| { read kind: "error", read text: string, read span: Span, read trivia: { Trivia } }
	--- An identifier, such as `foo` or `bar`.
	| { read kind: "ident", read text: string, read span: Span, read trivia: { Trivia } }
	--- A number, such as `123.456` or `0xABCD`.
	| { read kind: "number", read text: string, read span: Span, read trivia: { Trivia } }
	--- A string, such as `"foo"` or `'bar'` or `[[baz]]`.
	| { read kind: "string", read text: string, read span: Span, read trivia: { Trivia } }
	--- An interpolated string with no expr segments, such as `'simple'`.
	| { read kind: "istring_simple", read text: string, read span: Span, read trivia: { Trivia } }
	--- The first segment of an interpolated string, such as `'start{`
	| { read kind: "istring_first", read text: string, read span: Span, read trivia: { Trivia } }
	--- A middle segment of an interpolated string, such as `}middle{`.
	| { read kind: "istring_middle", read text: string, read span: Span, read trivia: { Trivia } }
	--- The last segment of an interpolated string, such as `}last'`.
	| { read kind: "istring_last", read text: string, read span: Span, read trivia: { Trivia } }
	--- A function attribute, such as `@native`.
	| { read kind: "attribute", read text: string, read span: Span, read trivia: { Trivia } }
	--- The `and` keyword.
	| { read kind: "and", read span: Span, read trivia: { Trivia } }
	--- The `break` keyword.
	| { read kind: "break", read span: Span, read trivia: { Trivia } }
	--- The `do` keyword.
	| { read kind: "do", read span: Span, read trivia: { Trivia } }
	--- The `else` keyword.
	| { read kind: "else", read span: Span, read trivia: { Trivia } }
	--- The `elseif` keyword.
	| { read kind: "elseif", read span: Span, read trivia: { Trivia } }
	--- The `end` keyword.
	| { read kind: "end", read span: Span, read trivia: { Trivia } }
	--- The `false` keyword.
	| { read kind: "false", read span: Span, read trivia: { Trivia } }
	--- The `for` keyword.
	| { read kind: "for", read span: Span, read trivia: { Trivia } }
	--- The `function` keyword.
	| { read kind: "function", read span: Span, read trivia: { Trivia } }
	--- The `if` keyword.
	| { read kind: "if", read span: Span, read trivia: { Trivia } }
	--- The `in` keyword.
	| { read kind: "in", read span: Span, read trivia: { Trivia } }
	--- The `local` keyword.
	| { read kind: "local", read span: Span, read trivia: { Trivia } }
	--- The `nil` keyword.
	| { read kind: "nil", read span: Span, read trivia: { Trivia } }
	--- The `not` keyword.
	| { read kind: "not", read span: Span, read trivia: { Trivia } }
	--- The `or` keyword.
	| { read kind: "or", read span: Span, read trivia: { Trivia } }
	--- The `repeat` keyword.
	| { read kind: "repeat", read span: Span, read trivia: { Trivia } }
	--- The `return` keyword.
	| { read kind: "return", read span: Span, read trivia: { Trivia } }
	--- The `then` keyword.
	| { read kind: "then", read span: Span, read trivia: { Trivia } }
	--- The `true` keyword.
	| { read kind: "true", read span: Span, read trivia: { Trivia } }
	--- The `until` keyword.
	| { read kind: "until", read span: Span, read trivia: { Trivia } }
	--- The `while` keyword.
	| { read kind: "while", read span: Span, read trivia: { Trivia } }
	-- The `+=` symbol.
	| { read kind: "+=", read span: Span, read trivia: { Trivia } }
	-- The `-=` symbol.
	| { read kind: "-=", read span: Span, read trivia: { Trivia } }
	-- The `*=` symbol.
	| { read kind: "*=", read span: Span, read trivia: { Trivia } }
	-- The `/=` symbol.
	| { read kind: "/=", read span: Span, read trivia: { Trivia } }
	-- The `//=` symbol.
	| { read kind: "//=", read span: Span, read trivia: { Trivia } }
	-- The `%=` symbol.
	| { read kind: "%=", read span: Span, read trivia: { Trivia } }
	-- The `^=` symbol.
	| { read kind: "^=", read span: Span, read trivia: { Trivia } }
	-- The `..=` symbol.
	| { read kind: "..=", read span: Span, read trivia: { Trivia } }
	-- The `+` symbol.
	| { read kind: "+", read span: Span, read trivia: { Trivia } }
	-- The `-` symbol.
	| { read kind: "-", read span: Span, read trivia: { Trivia } }
	-- The `*` symbol.
	| { read kind: "*", read span: Span, read trivia: { Trivia } }
	-- The `/` symbol.
	| { read kind: "/", read span: Span, read trivia: { Trivia } }
	-- The `//` symbol.
	| { read kind: "//", read span: Span, read trivia: { Trivia } }
	-- The `%` symbol.
	| { read kind: "%", read span: Span, read trivia: { Trivia } }
	-- The `^` symbol.
	| { read kind: "^", read span: Span, read trivia: { Trivia } }
	-- The `..` symbol.
	| { read kind: "..", read span: Span, read trivia: { Trivia } }
	-- The `<` symbol.
	| { read kind: "<", read span: Span, read trivia: { Trivia } }
	-- The `<=` symbol.
	| { read kind: "<=", read span: Span, read trivia: { Trivia } }
	-- The `>` symbol.
	| { read kind: ">", read span: Span, read trivia: { Trivia } }
	-- The `>=` symbol.
	| { read kind: ">=", read span: Span, read trivia: { Trivia } }
	-- The `==` symbol.
	| { read kind: "==", read span: Span, read trivia: { Trivia } }
	-- The `~=` symbol.
	| { read kind: "~=", read span: Span, read trivia: { Trivia } }
	-- The `#` symbol.
	| { read kind: "#", read span: Span, read trivia: { Trivia } }
	-- The `...` symbol.
	| { read kind: "...", read span: Span, read trivia: { Trivia } }
	-- The `&` symbol.
	| { read kind: "&", read span: Span, read trivia: { Trivia } }
	-- The `|` symbol.
	| { read kind: "|", read span: Span, read trivia: { Trivia } }
	-- The `?` symbol.
	| { read kind: "?", read span: Span, read trivia: { Trivia } }
	-- The `:` symbol.
	| { read kind: ":", read span: Span, read trivia: { Trivia } }
	-- The `::` symbol.
	| { read kind: "::", read span: Span, read trivia: { Trivia } }
	-- The `->` symbol.
	| { read kind: "->", read span: Span, read trivia: { Trivia } }
	-- The `=` symbol.
	| { read kind: "=", read span: Span, read trivia: { Trivia } }
	-- The `,` symbol.
	| { read kind: ",", read span: Span, read trivia: { Trivia } }
	-- The `;` symbol.
	| { read kind: ";", read span: Span, read trivia: { Trivia } }
	-- The `.` symbol.
	| { read kind: ".", read span: Span, read trivia: { Trivia } }
	-- The `(` symbol.
	| { read kind: "(", read span: Span, read trivia: { Trivia } }
	-- The `)` symbol.
	| { read kind: ")", read span: Span, read trivia: { Trivia } }
	-- The `{` symbol.
	| { read kind: "{", read span: Span, read trivia: { Trivia } }
	-- The `}` symbol.
	| { read kind: "}", read span: Span, read trivia: { Trivia } }
	-- The `[` symbol.
	| { read kind: "[", read span: Span, read trivia: { Trivia } }
	-- The `]` symbol.
	| { read kind: "]", read span: Span, read trivia: { Trivia } }

--- A token with a specific kind, such as `TokenKind<"+">` or `TokenKind<"string">`.
export type TokenKind<Kind> = { read kind: Kind, read text: string, read span: Span, read trivia: { Trivia } } -- Token & { read kind: Kind }

--- A pair of a node and optional separator, such as `node,` or `node`.
--- 
--- This is used within `AstSeparated` to represent nodes like the arguments
--- passed to a function, which would be `AstSeparated<AstExpr>`.
export type AstPair<Node, Sep> = { read node: Node, read sep: (Sep & Token)? }

--- A list of nodes separated by tokens, such as `foo, bar, baz`.
--- 
--- This is used in many places, notably function arguments, table fields, and
--- stats in blocks.
export type AstSeparated<Node, Sep> = { AstPair<Node, Sep> }

--- Delimiters that surround something, such as `(foo)` or `{bar}`.
--- 
--- Note that this node does not store the node within the delimiters, it only
--- stores the delimiters themselves.
export type AstDelim<Open, Close> = {
	--- The opening delimiter; the `(` in `(foo)`.
	read open: Open & Token,

	--- The closing delimiter; the `)` in `(foo)`.
	read close: Close & Token,
}

--- A generic declaration without default types; the `<A, B, C...>` in
--- `<A, B, C...>() -> ()`.
--- 
--- This is used in function declarations, local function declarations, and
--- function types.
--- 
--- All names must come before all packs. For example, `<A, B..., C>` is invalid
--- because `C` comes after `B...`.
export type AstGenericDeclaration = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A, B, C...>`.
	read angles: AstDelim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A, B,` in `A, B, C...`.
	read names: AstSeparated<TokenKind<"ident">, TokenKind<",">>,

	--- The generic type packs; the `C...` in `A, B, C...`.
	read packs: AstSeparated<{
		--- The name; the `C` in `C...`.
		read name: TokenKind<"ident">,

		--- The dots; the `...` in `C...`.
		read dots: TokenKind<"...">,
	}, TokenKind<",">>,
}

--- A generic declaration with optional default types; the
--- `<A = number, B... = (number, ...string)>` in
--- `type T<A = number, B... = (number, ...string)> = {}`.
--- 
--- This is used in type declarations.
--- 
--- In addition to the rules of `AstGenericDeclaration`, this node also requires
--- that any declarations after a declaration with a default type also have a
--- default type. For example, `<A = number, B>` is invalid because `B` doesn't
--- have a default type, but comes after a type with a default type.
export type AstGenericDeclarationWithDefaults = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A = number, B... = (number, ...string)>`.
	read angles: AstDelim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A = number,` in
	--- `<A = number, B... = (number, ...string)>`.
	read names: AstSeparated<{
		--- The name; the `A` in `A = number`.
		read name: TokenKind<"ident">,

		--- The default type; the `= number` in `A = number`.
		read default: {
			--- The equals sign; the `=` in `= number`.
			read equals: TokenKind<"=">,

			--- The type; the `number` in `= number`.
			read type: AstType,
		}?,
	}, TokenKind<",">>,

	--- The generic type packs; the `B... = (number, ...string)` in
	--- `<A = number, B... = (number, ...string)>`.
	read packs: AstSeparated<{
		--- The name; the `B` in `B... = (number, ...string)`.
		read name: TokenKind<"ident">,

		--- The dots; the first `...` in `B... = (number, ...string)`.
		read dots: TokenKind<"...">,

		--- The default type; the `= (number, ...string)` in
		--- `B... = (number, ...string)`.
		read default: {
			--- The equals sign; the `=` in `= (number, ...string)`.
			read equals: TokenKind<"=">,

			--- The type; the `(number, ...string)` in `= (number, ...string)`.
			read pack: AstTypePack,
		}?,
	}, TokenKind<",">>,
}

--- An argument to a type, such as `foo` or `...bar` or `bar...`.
--- 
--- This is used in reference types for arguments to types. As an example:
--- `foo<bar, baz...>` would have two `AstTypeArg`s: `bar` and `baz...`.
export type AstTypeArg = AstType | AstTypePack

--- A table type field with a name key, such as `read foo: bar` or
--- `bar: number`.
export type AstTableTypeField_NameProp = {
	read kind: "nameprop",

	--- The access modifier; the `read` in `read foo: bar`.
	--- 
	--- This token should only have values of `read` or `write`.
	read access: TokenKind<"ident">?,

	--- The name; the `foo` in `read foo: bar`.
	read name: TokenKind<"ident">,

	--- The colon; the `:` in `read foo: bar`.
	read colon: TokenKind<":">,

	--- The type; the `bar` in `read foo: bar`.
	read type: AstType,
}

--- A table type field with a string key, such as `read ["foo"]: bar` or
--- `['bar']: number`.
export type AstTableTypeField_StringProp = {
	read kind: "stringprop",

	--- The access modifier; the `read` in `read ["foo"]: bar`.
	--- 
	--- This token should only have values of `read` or `write`.
	read access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `read ["foo"]: bar`.
	read bracks: AstDelim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `"foo"` in `read ["foo"]: bar`.
	read key: TokenKind<"string">,

	--- The colon; the `:` in `read ["foo"]: bar`.
	read colon: TokenKind<":">,

	--- The type; the `bar` in `read ["foo"]: bar`.
	read type: AstType,
}

--- A table type indexer field, such as `read [number]: string` or
--- `[string]: number`.
export type AstTableTypeField_Indexer = {
	read kind: "indexer",

	--- The access modifier; the `read` in `read [number]: string`.
	--- 
	--- This token should only have values of `read` or `write`.
	read access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `read [number]: string`.
	read bracks: AstDelim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `number` in `read [number]: string`.
	read key: AstType,

	--- The colon; the `:` in `read [number]: string`.
	read colon: TokenKind<":">,

	--- The type; the `string` in `read [number]: string`.
	read type: AstType,
}

--- A table type field, such as `read foo: bar` or `["foo"]: bar` or
--- `write [number]: string`.
export type AstTableTypeField =
	| AstTableTypeField_NameProp
	| AstTableTypeField_StringProp
	| AstTableTypeField_Indexer

--- A tail type in a type pack, such as `...foo` or `bar...`.
export type AstTailType = AstTypePack_Variadic | AstTypePack_Generic

--- The literal type `nil`.
export type AstType_Nil = {
	read kind: "nil",

	--- The `nil` token.
	read tok: TokenKind<"nil">,
}

--- The literal types `true` and `false`.
export type AstType_Boolean = {
	read kind: "boolean",

	--- The `true` or `false` token.
	read tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A string literal type, such as `"foo"` or `'bar'` or `[[baz]]`.
export type AstType_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- A reference type, such as `foo` or `foo<bar>` or `foo.bar<baz>`.
export type AstType_Reference = {
	read kind: "reference",

	--- The optional prefix; the `foo.` in `foo.bar<baz>`.
	read prefix: {
		--- The name; the `foo` in `foo.`.
		read name: TokenKind<"ident">,

		--- The dot; the `.` in `foo.`.
		read dot: TokenKind<".">,
	}?,

	--- The name; the `bar` in `foo.bar<baz>`.
	read name: TokenKind<"ident">,

	--- The optional generics; the `<baz>` in `foo.bar<baz>`.
	read generics: {
		--- The angles surrounding the generic declaration; the `<>` in
		--- `<baz>`.
		read angles: AstDelim<TokenKind<"<">, TokenKind<">">>,

		--- The generic types; the `baz` in `<baz>`.
		read types: AstSeparated<AstTypeArg, TokenKind<",">>,
	}?,
}

--- A typeof type, such as `typeof(foo)` or `typeof(10)`.
export type AstType_Typeof = {
	read kind: "typeof",

	--- The `typeof` token.
	read typeof_tok: TokenKind<"ident">,

	--- The parentheses surrounding the expr; the `()` in `typeof(foo)`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `typeof(foo)`.
	read expr: AstExpr,
}

--- An array type, such as `{ foo }` or `{ number }`.
export type AstType_Array = {
	read kind: "array",

	--- The braces surrounding the type; the `{}` in `{ number }`.
	read braces: AstDelim<TokenKind<"{">, TokenKind<"}">>,

	--- The type; the `number` in `{ number }`.
	read type: AstType,
}

--- A table type, such as `{ foo: bar, ["baz"]: number, [number]: string }`.
export type AstType_Table = {
	read kind: "table",

	--- The braces surrounding the type; the `{}` in `{ foo: bar }`.
	read braces: AstDelim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo: bar` in `{ foo: bar }`.
	read fields: AstSeparated<AstTableTypeField, TokenKind<","> | TokenKind<";">>,
}

--- A function type, such as `<T>(foo: T, ...bar) -> baz`.
export type AstType_Function = {
	read kind: "function",

	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...bar) -> baz`.
	read generics: AstGenericDeclaration?,

	--- The parentheses surrounding the arguments; the `()` in
	--- `<T>(foo: T, ...bar) -> baz`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in `<T>(foo: T, ...bar) -> baz`.
	read params: AstSeparated<{
		--- The optional name of the parameter; the `foo:` in `foo: T`.
		read name: {
			--- The name; the `foo` in `foo:`.
			read name: TokenKind<"ident">,

			--- The colon; the `:` in `foo:`.
			read colon: TokenKind<":">,
		}?,

		--- The type of the parameter; the `T` in `foo: T`.
		read type: AstType,
	}, TokenKind<",">>,

	--- The optional varargs; the `...bar` in `<T>(foo: T, ...bar) -> baz`.
	read varargs: AstTailType?,

	--- The arrow; the `->` in `<T>(foo: T, ...bar) -> baz`.
	read arrow: TokenKind<"->">,

	--- The return type; the `baz` in `<T>(foo: T, ...bar) -> baz`.
	read ret: AstReturnType,
}

--- A parenthesized type, such as `(foo)` or `(bar)`.
export type AstType_Paren = {
	read kind: "paren",

	--- The parentheses surrounding the type; the `()` in `(foo)`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The type; the `foo` in `(foo)`.
	read type: AstType,
}

--- An optional type, such as `foo?` or `bar?`.
export type AstType_Optional = {
	read kind: "optional",

	--- The type; the `foo` in `foo?`.
	read type: AstType,

	--- The question mark; the `?` in `foo?`.
	read question: TokenKind<"?">,
}

--- A union type, such as `| foo | bar` or `foo | bar`.
export type AstType_Union = {
	read kind: "union",

	--- The optional leading pipe; the `|` in `| foo | bar`.
	read leading: TokenKind<"|">?,

	--- The types; the `foo | bar` in `| foo | bar`.
	read types: AstSeparated<AstType, TokenKind<"|">>,
}

--- An intersection type, such as `& foo & bar` or `foo & bar`.
export type AstType_Intersection = {
	read kind: "intersection",

	--- The optional leading ampersand; the `&` in `& foo & bar`.
	read leading: TokenKind<"&">?,

	--- The types; the `foo & bar` in `& foo & bar`.
	read types: AstSeparated<AstType, TokenKind<"&">>,
}

--- A type, such as `number` or `foo` or `{}`.
--- 
--- This node is used in many places, such as variable declarations, function
--- parameters, and type declarations themselves.
export type AstType =
	| AstType_Nil
	| AstType_Boolean
	| AstType_String
	| AstType_Reference
	| AstType_Typeof
	| AstType_Array
	| AstType_Table
	| AstType_Function
	| AstType_Paren
	| AstType_Optional
	| AstType_Union
	| AstType_Intersection

--- A variadic type pack, such as `...foo` or `...number`.
export type AstTypePack_Variadic = {
	read kind: "variadic",

	--- The dots; the `...` in `...foo`.
	read dots: TokenKind<"...">,

	--- The type; the `foo` in `...foo`.
	read type: AstType,
}

--- A generic type pack, such as `foo...` or `T...`.
export type AstTypePack_Generic = {
	read kind: "generic",

	--- The name; the `foo` in `foo...`.
	read name: TokenKind<"ident">,

	--- The dots; the `...` in `foo...`.
	read dots: TokenKind<"...">,
}

--- A list type pack, such as `(foo, bar, baz...)` or `(number...)`.
export type AstTypePack_List = {
	read kind: "list",

	--- The parentheses surrounding the type pack; the `()` in
	--- `(foo, bar, baz...)`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The types; the `foo, bar,` in `(foo, bar, baz...)`.
	read types: AstSeparated<AstType, TokenKind<",">>,

	--- The optional tail type pack; the `baz...` in `(foo, bar, baz...)`.
	read tail: AstTailType?,
}

--- A type pack, such as `...foo` or `foo...` or `(foo, bar, baz...)`.
export type AstTypePack =
	| AstTypePack_Variadic
	| AstTypePack_Generic
	| AstTypePack_List

--- A return type, such as `(foo, bar, baz...)` or `(foo | bar, baz)` or `foo`.
export type AstReturnType = AstType | AstTypePack

--- A binding, such as `foo: bar` or `foo`.
--- 
--- This is used in a few places, such as function parameters and local variable
--- declarations.
export type AstBinding = {
	--- The name; the `foo` in `foo: bar`.
	read name: TokenKind<"ident">,

	--- The optional type; the `: bar` in `foo: bar`.
	read type: {
		--- The colon; the `:` in `: bar`.
		read colon: TokenKind<":">,

		--- The type; the `bar` in `: bar`.
		read type: AstType,
	}?,
}

--- An interpolated string with no exprs, such as `'simple'`.
export type AstIString_Simple = {
	read kind: "simple",

	--- The string token.
	read tok: TokenKind<"istring_simple">,
}

--- An interpolated string with exprs, such as `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type AstIString_Complex = {
	read kind: "complex",

	--- The first segment; the `'foo {'` in `'foo {1} bar {2} baz'`.
	read first: TokenKind<"istring_first">,

	--- The middle segments; the `1} bar {2` in `'foo {1} bar {2} baz'`.
	--- 
	--- This needs better documentation. Someone please remind me to do this.
	read middle: AstSeparated<AstExpr, TokenKind<"istring_middle">>,

	--- The last segment; the `} baz'` in `'foo {1} bar {2} baz'`.
	read last: TokenKind<"istring_last">,
}

--- An interpolated string, such as `'simple'` or `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type AstIString = AstIString_Simple | AstIString_Complex

--- A branch of an if-else expr, such as `foo then bar`.
export type AstIfElseExprBranch = {
	--- The condition; the `foo` in `foo then bar`.
	read condition: AstExpr,

	--- The `then` token; the `then` in `foo then bar`.
	read then_tok: TokenKind<"then">,

	--- The body; the `bar` in `foo then bar`.
	read body: AstExpr,
}

--- An unary operator: `+`, `-`, `not`, or `#`.
export type AstUnaryOperator =
	| TokenKind<"+">
	| TokenKind<"-">
	| TokenKind<"not">
	| TokenKind<"#">

--- A binary operator: `+`, `-`, `*`, `/`, `//`, `%`, `^`, `..`, `<`, `<=`, `>`,
--- `>=`, `==`, `~=`, `and`, or `or`.
export type AstBinaryOperator =
	| TokenKind<"+">
	| TokenKind<"-">
	| TokenKind<"*">
	| TokenKind<"/">
	| TokenKind<"//">
	| TokenKind<"%">
	| TokenKind<"^">
	| TokenKind<"..">
	| TokenKind<"<">
	| TokenKind<"<=">
	| TokenKind<">">
	| TokenKind<">=">
	| TokenKind<"==">
	| TokenKind<"~=">
	| TokenKind<"and">
	| TokenKind<"or">

--- The literal expr `nil`.
export type AstExpr_Nil = {
	read kind: "nil",

	--- The `nil` token.
	read tok: TokenKind<"nil">,
}

--- The literal expr `true` and `false`.
export type AstExpr_Boolean = {
	read kind: "boolean",

	--- The `true` or `false` token.
	read tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A number literal expr, such as `123` or `0xABCD`.
export type AstExpr_Number = {
	read kind: "number",

	--- The number token.
	read tok: TokenKind<"number">,
}

--- A string literal expr, such as `"foo"` or `'bar'` or `[[baz]]`.
export type AstExpr_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- The literal expr `...`.
export type AstExpr_Varargs = {
	read kind: "varargs",

	--- The `...` token.
	read tok: TokenKind<"...">,
}

--- An interpolated string expr, such as `'simple'` or
--- `'foo {1} bar {2} baz'` or `'hello {"world"}'`.
export type AstExpr_IString = {
	read kind: "istring",

	--- The interpolated string; the `'simple'` in `'simple'`.
	read istring: AstIString,
}

--- A table literal expr, such as `{ foo = bar }` or `{ 1, 2, 3 }`.
export type AstExpr_Table = {
	read kind: "table",

	--- The table literal.
	read table: AstTable,
}

--- An anonymous function expr, such as
--- `@native function(foo, bar) return foo + bar end` or `function() end`.
export type AstExpr_Function = {
	read kind: "function",
	
	--- The function attributes; the `@native` in
	--- `@native function(foo, bar) return foo + bar end`.
	read attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	read function_tok: TokenKind<"function">,
	
	--- The function body; the `(foo, bar) return foo + bar end` in
	--- `@native function(foo, bar) return foo + bar end`.
	read body: AstFunctionBody,
}

--- An if-else expr, such as `if foo then bar elseif baz then qux else quux`.
export type AstExpr_IfElse = {
	read kind: "ifelse",

	--- The `if` token; the `if` in
	--- `if foo then bar elseif baz then qux else quux`.
	read if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar elseif baz then qux` in
	--- `if foo then bar elseif baz then qux else quux`.
	read branches: AstSeparated<AstIfElseExprBranch, TokenKind<"elseif">>,

	--- The `else` token; the `else` in
	--- `if foo then bar elseif baz then qux else quux`.
	read else_tok: TokenKind<"else">,

	--- The else body; the `quux` in
	--- `if foo then bar elseif baz then qux else quux`.
	read else_body: AstExpr,
}

--- A var expr, such as `foo.bar[baz]()` or `foo`.
export type AstExpr_Var = {
	read kind: "var",

	--- The var.
	read var: AstVar,
}

--- A type assertion expr, such as `foo :: bar` or `{} :: { number }`.
export type AstExpr_Assertion = {
	read kind: "assertion",

	--- The expr; the `foo` in `foo :: bar`.
	read expr: AstExpr,

	--- The double colon; the `::` in `foo :: bar`.
	read colon: TokenKind<"::">,

	--- The type; the `bar` in `foo :: bar`.
	read type: AstType,
}

--- An unary expr, such as `-foo` or `not bar`.
export type AstExpr_Unary = {
	read kind: "unary",

	--- The operator; the `-` in `-foo`.
	read operator: AstUnaryOperator,

	--- The expr; the `foo` in `-foo`.
	read expr: AstExpr,
}

--- A binary expr, such as `foo + bar` or `baz and qux`.
export type AstExpr_Binary = {
	read kind: "binary",

	--- The left expr; the `foo` in `foo + bar`.
	read left: AstExpr,

	--- The operator; the `+` in `foo + bar`.
	read operator: AstBinaryOperator,

	--- The right expr; the `bar` in `foo + bar`.
	read right: AstExpr,
}

--- An expression, such as `nil` or `foo` or `foo + bar`.
--- 
--- This node is used in many places, such as function arguments, table fields,
--- variable assignments, and return stats.
export type AstExpr =
	| AstExpr_Nil
	| AstExpr_Boolean
	| AstExpr_Number
	| AstExpr_String
	| AstExpr_Varargs
	| AstExpr_IString
	| AstExpr_Table
	| AstExpr_Function
	| AstExpr_IfElse
	| AstExpr_Var
	| AstExpr_Assertion
	| AstExpr_Unary
	| AstExpr_Binary

--- Pack argument to a call, such as `(foo, bar)` or `()`.
export type AstFunctionArg_Pack = {
	read kind: "pack",

	--- The parens surrounding the pack; the `()` in `()`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The exprs; the `foo, bar` in `(foo, bar)`.
	read exprs: AstSeparated<AstExpr, TokenKind<",">>,
}

--- Table argument to a call, such as `{ foo = bar }` or `{}`.
export type AstFunctionArg_Table = {
	read kind: "table",

	--- The table literal.
	read table: AstTable,
}

--- String argument to a call, such as `"foo"` or `'bar'`.
export type AstFunctionArg_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- An argument to a call, such as `(foo, bar)` or `()` or `"baz"`.
export type AstFunctionArg =
	| AstFunctionArg_Pack
	| AstFunctionArg_Table
	| AstFunctionArg_String

--- A name as a variable, such as `foo`.
export type AstVarRoot_Name = {
	read kind: "name",

	--- The name token.
	read tok: TokenKind<"ident">,
}

--- A parenthesized expr, such as `(foo)` or `(1 + 1)`.
export type AstVarRoot_Paren = {
	read kind: "paren",

	--- The parentheses surrounding the expr; the `()` in `(foo)`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `(foo)`.
	read expr: AstExpr,
}

--- The root of a variable, such as `foo` or `(foo)`.
export type AstVarRoot = AstVarRoot_Name | AstVarRoot_Paren

--- A named index, such as `root.foo` or `root.bar`.
export type AstVarSuffix_NameIndex = {
	read kind: "nameindex",

	--- The dot; the `.` in `.foo`.
	read dot: TokenKind<".">,

	--- The name; the `foo` in `.foo`.
	read name: TokenKind<"ident">,
}

--- An expr index, such as `root[foo]` or `root[1 + 1]`.
export type AstVarSuffix_ExprIndex = {
	read kind: "exprindex",

	--- The brackets surrounding the expr; the `[]` in `[foo]`.
	read bracks: AstDelim<TokenKind<"[">, TokenKind<"]">>,

	--- The expr; the `foo` in `[foo]`.
	read expr: AstExpr,
}

--- A call, such as `root:method(foo)` or `root()`.
export type AstVarSuffix_Call = {
	read kind: "call",

	--- The optional method; the `:method` in `root:method(foo)`.
	read method: {
		--- The colon; the `:` in `:method`.
		read colon: TokenKind<":">,

		--- The name; the `method` in `:method`.
		read name: TokenKind<"ident">,
	}?,
	
	--- The argument; the `(foo)` in `root:method(foo)`.
	read arg: AstFunctionArg,
}

--- A suffix of a variable, such as `.foo` or `[bar]` or `()`.
export type AstVarSuffix =
	| AstVarSuffix_NameIndex
	| AstVarSuffix_ExprIndex
	| AstVarSuffix_Call

--- A variable, such as `foo` or `foo.bar()[baz]`.
--- 
--- This node is used in exprs, assignments, and function calls. This is
--- essentially anything that can appear on the left side of an assignment stat
--- or before a function call.
--- 
--- As an example:
export type AstVar = {
	--- The root of the variable; the `foo` in `foo.bar()[baz]`.
	read root: AstVarRoot,

	--- The suffixes of the variable; the `.bar()[baz]` in `foo.bar()[baz]`.
	read suffixes: { AstVarSuffix },
}

--- A table field with a name key, such as `foo = bar` or `bar = 1`.
export type AstTableField_NameKey = {
	read kind: "namekey",

	--- The name; the `foo` in `foo = bar`.
	read name: TokenKind<"ident">,

	--- The equals sign; the `=` in `foo = bar`.
	read equals: TokenKind<"=">,

	--- The value; the `bar` in `foo = bar`.
	read value: AstExpr,
}

--- A table field with an expr key, such as `[foo] = bar` or `[1] = 2`.
export type AstTableField_ExprKey = {
	read kind: "exprkey",

	--- The brackets surrounding the key; the `[]` in `[foo] = bar`.
	read bracks: AstDelim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `foo` in `[foo] = bar`.
	read key: AstExpr,

	--- The equals sign; the `=` in `[foo] = bar`.
	read equals: TokenKind<"=">,

	--- The value; the `bar` in `[foo] = bar`.
	read value: AstExpr,
}

--- A table field with no key, such as `foo` or `1`.
export type AstTableField_NoKey = {
	read kind: "nokey",

	--- The value; the `foo` in `foo`.
	read value: AstExpr,
}

--- A table field, such as `foo = bar` or `[baz] = qux` or `quux`.
export type AstTableField =
	| AstTableField_NameKey
	| AstTableField_ExprKey
	| AstTableField_NoKey

--- A table literal, such as `{ foo = bar, [baz] = qux, quux }`.
export type AstTable = {
	--- The braces surrounding the table; the `{}` in `{ foo = bar }`.
	read braces: AstDelim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo = bar` in `{ foo = bar }`.
	read fields: AstSeparated<AstTableField, TokenKind<","> | TokenKind<";">>,
}

--- A function body, such as `<T>(foo: T, ...: bar): baz return 10 end`.
--- 
--- This is used in anonymous functions, function declarations, and local
--- function declarations.
export type AstFunctionBody = {
	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read generics: AstGenericDeclaration?,

	--- The parentheses surrounding the parameters; the `()` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read parens: AstDelim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read params: AstSeparated<AstBinding, TokenKind<",">>,

	--- The optional varargs; the `...: bar` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read varargs: {
		--- The dots; the `...` in `...: bar`.
		read dots: TokenKind<"...">,

		--- The optional type; the `: bar` in `...: bar`.
		read type: {
			--- The colon; the `:` in `: bar`.
			read colon: TokenKind<":">,

			--- The type; the `bar` in `: bar`.
			read type: AstType | AstTypePack_Generic,
		}?,
	}?,

	--- The return type; the `: baz` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read ret: {
		--- The colon; the `:` in `: baz`.
		read colon: TokenKind<":">,

		--- The type; the `baz` in `: baz`.
		read type: AstReturnType,
	}?,

	--- The block; the `return 10` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read block: AstBlock,

	--- The `end` token; the `end` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read end_tok: TokenKind<"end">,
}

--- A branch in an if stat, such as `foo then bar()`
export type AstIfStatBranch = {
	--- The condition; the `foo` in `foo then bar()`.
	read condition: AstExpr,

	--- The `then` token.
	read then_tok: TokenKind<"then">,

	--- The block; the `bar()` in `foo then bar()`.
	read block: AstBlock,
}

--- A compound operator: `+=`, `-=`, `*=`, `/=`, `//=`, `%=`, `*=`, `or `..=`.
export type AstCompoundOperator = 
	| TokenKind<"+=">
	| TokenKind<"-=">
	| TokenKind<"*=">
	| TokenKind<"/=">
	| TokenKind<"//=">
	| TokenKind<"%=">
	| TokenKind<"^=">
	| TokenKind<"..=">

--- An assignment stat, such as `foo, bar = baz, qux` or `foo = bar`.
export type AstStat_Assign = {
	read kind: "assign",

	--- The left side of the assignment; the `foo, bar` in
	--- `foo, bar = baz, qux`.
	read left: AstSeparated<AstVar, TokenKind<",">>,

	--- The equals sign; the `=` in `foo, bar = baz, qux`.
	read equals: TokenKind<"=">,

	--- The right side of the assignment; the `baz, qux` in
	--- `foo, bar = baz, qux`.
	read right: AstSeparated<AstExpr, TokenKind<",">>,
}

--- A compound assignment stat, such as `foo += bar`.
export type AstStat_CompoundAssign = {
	read kind: "compoundassign",

	--- The left side of the assignment; the `foo` in `foo += bar`.
	read left: AstVar,

	--- The compound operator; the `+=` in `foo += bar`.
	read operator: AstCompoundOperator,

	--- The right side of the assignment; the `bar` in `foo += bar`.
	read right: AstExpr,
}

--- A function call stat, such as `foo.bar()` or `baz()`.
export type AstStat_Call = {
	read kind: "call",

	--- A var ending with a call suffix.
	--- 
	--- This call not ending with a call suffix will result in a syntax error
	--- when emitted.
	read call: AstVar,
}

--- A do stat, such as `do foo() end`.
export type AstStat_Do = {
	read kind: "do",
	
	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block within the do; the `foo()` in `do foo() end`.
	read block: AstBlock,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A while stat, such as `while foo do bar() end`.
export type AstStat_While = {
	read kind: "while",

	--- The `while` token.
	read while_tok: TokenKind<"while">,

	--- The condition; the `foo` in `while foo do bar() end`.
	read condition: AstExpr,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `while foo do bar() end`.
	read block: AstBlock,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A repeat stat, such as `repeat foo() until bar`.
export type AstStat_Repeat = {
	read kind: "repeat",

	--- The `repeat` token.
	read repeat_tok: TokenKind<"repeat">,
	
	--- The block; the `foo()` in `repeat foo() until bar`.
	read block: AstBlock,

	--- The `until` token.
	read until_tok: TokenKind<"until">,

	--- The condition; the `bar` in `repeat foo() until bar`.
	read condition: AstExpr,
}

--- An if stat, such as
--- `if foo then bar() elseif baz then qux() else quux() end`.
export type AstStat_If = {
	read kind: "if",

	--- The `if` token.
	read if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar() elseif baz then qux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read branches: AstSeparated<AstIfStatBranch, TokenKind<"elseif">>,

	--- The optional else branch; the `else quux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read else_branch: {
		--- The `else` token.
		read else_tok: TokenKind<"else">,

		--- The else branch block; the `quux()` in `else quux()`.
		read block: AstBlock,
	}?,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A numeric for loop stat, such as `for foo = 1, 2, 3 do bar() end`.
export type AstStat_NumericFor = {
	read kind: "numericfor",

	--- The `for` token.
	read for_tok: TokenKind<"for">,

	--- The binding; the `foo` in `for foo = 1, 2, 3  do bar() end`.
	read binding: AstBinding,

	--- The equals token; the `=` in `for foo = 1, 2, 3 do bar() end`.
	read equals: TokenKind<"=">,

	--- The start expr; the `1` in `for foo = 1, 2, 3 do bar() end`.
	read start_expr: AstExpr,

	--- The comma between the start and end; the first comma in
	--- `for foo = 1, 2, 3 do bar() end`.
	read comma: TokenKind<",">,

	--- The end expr; the `2` in `for foo = 1, 2, 3 do bar() end`.
	read end_expr: AstExpr,

	--- The optional step; the `, 3` in `for foo = 1, 2, 3 do bar() end`.
	read step: {
		--- The comma between the end and step; the comma in `, 3` and the
		--- second comma in `for foo = 1, 2, 3 do bar() end`.
		read comma: TokenKind<",">,

		--- The step expr; the `3` in `, 3` and the `3` in
		--- `for foo = 1, 2, 3 do bar() end`.
		read expr: AstExpr,
	}?,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `for foo = 1, 2, 3 do bar() end`.
	read block: AstBlock,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A for-in loop stat, such as `for foo: bar, baz in qux, quux do quuz() end`.
export type AstStat_ForIn = {
	read kind: "forin",

	--- The `for` token.
	read for_tok: TokenKind<"for">,

	--- The bindings; the `foo: bar, baz` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read bindings: AstSeparated<AstBinding, TokenKind<",">>,

	--- The `in` token.
	read in_tok: TokenKind<"in">,

	--- The exprs; the `qux, quux` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read exprs: AstSeparated<AstExpr, TokenKind<",">>,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `quuz()` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read block: AstBlock,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A function declaration stat, such as
--- `@native function foo.bar:baz() return 1 end`.
export type AstStat_Function = {
	read kind: "function",
	
	--- The attributes; the `@native` in
	--- `@native function foo.bar:baz() return 1 end`.
	read attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	read function_tok: TokenKind<"function">,

	--- The name; the `foo.bar` in
	--- `@native function foo.bar:baz() return 1 end`.
	read names: AstSeparated<TokenKind<"ident">, TokenKind<".">>,

	--- The optional method; the `:baz` in
	--- `@native function foo.bar:baz() return 1 end`.
	read method: {
		--- The colon; the `:` in `:baz`.
		read colon: TokenKind<":">,
		
		--- The method name; the `baz` in `:baz`.
		read name: TokenKind<"ident">,
	}?,

	--- The function body; the `() return 1 end` in
	--- `@native function foo.bar:baz() return 1 end`.
	read body: AstFunctionBody,
}

--- A local function declaration stat, such as
--- `@native local function foo() return 1 end`.
export type AstStat_LocalFunction = {
	read kind: "localfunction",
	
	--- The attributes; the `@native` in
	--- `@native local function foo() return 1 end`.
	read attributes: { TokenKind<"attribute"> },

	--- The `local` token.
	read local_tok: TokenKind<"local">,

	--- The `function` token.
	read function_tok: TokenKind<"function">,

	--- The name; the `foo` in `@native local function foo() return 1 end`.
	read name: TokenKind<"ident">,

	--- The function body; the `() return 1 end` in
	--- `@native local function foo() return 1 end`.
	read body: AstFunctionBody,
}

--- A local variable stat, such as `local foo: bar, baz = qux, quux, quuz`.
export type AstStat_LocalVariable = {
	read kind: "localvariable",

	--- The `local` token.
	read local_tok: TokenKind<"local">,

	--- The bindings; the `foo: bar, baz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read bindings: AstSeparated<AstBinding, TokenKind<",">>,

	--- The optional values; the `= qux, quux, quuz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read values: {
		--- The equals; the `=` in `= qux, quux, quuz`.
		read equals: TokenKind<"=">,

		--- The exprs; the `qux, quux, quuz` in `= qux, quux, quuz`.
		read exprs: AstSeparated<AstExpr, TokenKind<",">>,
	}?,
}

--- A type declaration stat, such as `export type foo<bar> = baz`.
export type AstStat_Type = {
	read kind: "type",

	--- The optional `export` token.
	--- 
	--- Note that the value of this identifier must be `export` otherwise this
	--- will result in a syntax error.
	read export_tok: TokenKind<"ident">?,

	--- The `type` token.
	---
	--- Note that the value of this identifier must be `type` otherwise this
	--- will result in a syntax error.
	read type_tok: TokenKind<"ident">,

	--- The name of the type; the `foo` in `export type foo<bar> = baz`.
	read name: TokenKind<"ident">,

	--- The optional generic declarations; the `<bar>` in `export type foo<bar> = baz`.
	read generics: AstGenericDeclarationWithDefaults?,

	--- The equals token; the `=` in `export type foo<bar> = baz`.
	read equals: TokenKind<"=">,

	--- The type; the `baz` in `export type foo<bar> = baz`.
	read type: AstType,
}

--- A statement in a block, such as `foo()` or `local foo = bar` or `foo = bar`.
export type AstStat =
	| AstStat_Assign
	| AstStat_CompoundAssign
	| AstStat_Call
	| AstStat_Do
	| AstStat_While
	| AstStat_Repeat
	| AstStat_If
	| AstStat_NumericFor
	| AstStat_ForIn
	| AstStat_Function
	| AstStat_LocalFunction
	| AstStat_LocalVariable
	| AstStat_Type

--- A return laststat, such as `return foo, bar, baz` or `return`.
export type AstLastStat_Return = {
	read kind: "return",

	--- The `return` token.
	read return_tok: TokenKind<"return">,

	--- The returned exprs; the `foo, bar, baz` in `return foo, bar, baz`.
	read exprs: AstSeparated<AstExpr, TokenKind<",">>,
}

--- A `break` laststat.
export type AstLastStat_Break = {
	read kind: "break",
	
	--- The `break` token.
	read tok: TokenKind<"break">,
}

--- A `continue` laststat.
export type AstLastStat_Continue = {
	read kind: "continue",

	--- The `continue` token.
	--- 
	--- Note that the value of this identifier must be `continue` otherwise this
	--- will result in a syntax error.
	read tok: TokenKind<"ident">,
}

--- The last statement in a block, such as `return`, `break`, or `continue`.
export type AstLastStat =
	| AstLastStat_Return
	| AstLastStat_Break
	| AstLastStat_Continue

--- A block of stats, ending with an optional laststat, such as
--- `foo(); bar(); return baz;`.
export type AstBlock = {
	--- The stats, the `foo(); bar();` in `foo(); bar(); return baz;`.
	read stats: AstSeparated<AstStat, TokenKind<";">>,

	--- The optional laststat, the `return baz;` in `foo(); bar(); return baz;`.
	read laststat: {
		--- The laststat; the `return baz` in `return baz;`.
		read stat: AstLastStat,

		--- The optional semicolon; the `;` in `return baz;`.
		read semicolon: TokenKind<";">?,
	}?,
}

--- A full AST with a block and eof.
export type Ast = {
	--- The block of stats.
	read block: AstBlock,

	--- The eof token.
	read eof: TokenKind<"eof">,
}

local ast = {}

export type Visitor<Self> = {
	visit_token: (self: Self, token: Token) -> (),

	visit_generic_declaration: (self: Self, generic_declaration: AstGenericDeclaration) -> (),
	visit_generic_declaration_end: (self: Self, generic_declaration: AstGenericDeclaration) -> (),
	
	visit_generic_declaration_with_defaults: (self: Self, generic_declaration_with_defaults: AstGenericDeclarationWithDefaults) -> (),
	visit_generic_declaration_with_defaults_end: (self: Self, generic_declaration_with_defaults: AstGenericDeclarationWithDefaults) -> (),

	visit_type_arg: (self: Self, typearg: AstTypeArg) -> (),
	visit_type_arg_end: (self: Self, typearg: AstTypeArg) -> (),

	visit_table_type_field_nameprop: (self: Self, field: AstTableTypeField_NameProp) -> (),
	visit_table_type_field_nameprop_end: (self: Self, field: AstTableTypeField_NameProp) -> (),
	visit_table_type_field_stringprop: (self: Self, field: AstTableTypeField_StringProp) -> (),
	visit_table_type_field_stringprop_end: (self: Self, field: AstTableTypeField_StringProp) -> (),
	visit_table_type_field_indexer: (self: Self, field: AstTableTypeField_Indexer) -> (),
	visit_table_type_field_indexer_end: (self: Self, field: AstTableTypeField_Indexer) -> (),
	visit_table_type_field: (self: Self, field: AstTableTypeField) -> (),
	visit_table_type_field_end: (self: Self, field: AstTableTypeField) -> (),

	visit_tail_type: (self: Self, tail_type: AstTailType) -> (),
	visit_tail_type_end: (self: Self, tail_type: AstTailType) -> (),

	visit_type_nil: (self: Self, type: AstType_Nil) -> (),
	visit_type_nil_end: (self: Self, type: AstType_Nil) -> (),
	visit_type_boolean: (self: Self, type: AstType_Boolean) -> (),
	visit_type_boolean_end: (self: Self, type: AstType_Boolean) -> (),
	visit_type_string: (self: Self, type: AstType_String) -> (),
	visit_type_string_end: (self: Self, type: AstType_String) -> (),
	visit_type_reference: (self: Self, type: AstType_Reference) -> (),
	visit_type_reference_end: (self: Self, type: AstType_Reference) -> (),
	visit_type_typeof: (self: Self, type: AstType_Typeof) -> (),
	visit_type_typeof_end: (self: Self, type: AstType_Typeof) -> (),
	visit_type_array: (self: Self, type: AstType_Array) -> (),
	visit_type_array_end: (self: Self, type: AstType_Array) -> (),
	visit_type_table: (self: Self, type: AstType_Table) -> (),
	visit_type_table_end: (self: Self, type: AstType_Table) -> (),
	visit_type_function: (self: Self, type: AstType_Function) -> (),
	visit_type_function_end: (self: Self, type: AstType_Function) -> (),
	visit_type_paren: (self: Self, type: AstType_Paren) -> (),
	visit_type_paren_end: (self: Self, type: AstType_Paren) -> (),
	visit_type_optional: (self: Self, type: AstType_Optional) -> (),
	visit_type_optional_end: (self: Self, type: AstType_Optional) -> (),
	visit_type_union: (self: Self, type: AstType_Union) -> (),
	visit_type_union_end: (self: Self, type: AstType_Union) -> (),
	visit_type_intersection: (self: Self, type: AstType_Intersection) -> (),
	visit_type_intersection_end: (self: Self, type: AstType_Intersection) -> (),
	visit_type: (self: Self, type: AstType) -> (),
	visit_type_end: (self: Self, type: AstType) -> (),

	visit_typepack_variadic: (self: Self, type: AstTypePack_Variadic) -> (),
	visit_typepack_variadic_end: (self: Self, type: AstTypePack_Variadic) -> (),
	visit_typepack_generic: (self: Self, type: AstTypePack_Generic) -> (),
	visit_typepack_generic_end: (self: Self, type: AstTypePack_Generic) -> (),
	visit_typepack_list: (self: Self, type: AstTypePack_List) -> (),
	visit_typepack_list_end: (self: Self, type: AstTypePack_List) -> (),
	visit_typepack: (self: Self, type: AstTypePack) -> (),
	visit_typepack_end: (self: Self, type: AstTypePack) -> (),

	visit_return_type: (self: Self, return_type: AstReturnType) -> (),
	visit_return_type_end: (self: Self, return_type: AstReturnType) -> (),

	visit_binding: (self: Self, binding: AstBinding) -> (),
	visit_binding_end: (self: Self, binding: AstBinding) -> (),

	visit_istring_simple: (self: Self, istring: AstIString_Simple) -> (),
	visit_istring_simple_end: (self: Self, istring: AstIString_Simple) -> (),
	visit_istring_complex: (self: Self, istring: AstIString_Complex) -> (),
	visit_istring_complex_end: (self: Self, istring: AstIString_Complex) -> (),
	visit_istring: (self: Self, istring: AstIString) -> (),
	visit_istring_end: (self: Self, istring: AstIString) -> (),

	visit_ifelse_expr_branch: (self: Self, branch: AstIfElseExprBranch) -> (),
	visit_ifelse_expr_branch_end: (self: Self, branch: AstIfElseExprBranch) -> (),

	visit_unary_operator: (self: Self, operator: AstUnaryOperator) -> (),
	visit_binary_operator: (self: Self, operator: AstBinaryOperator) -> (),

	visit_expr_nil: (self: Self, expr: AstExpr_Nil) -> (),
	visit_expr_nil_end: (self: Self, expr: AstExpr_Nil) -> (),
	visit_expr_boolean: (self: Self, expr: AstExpr_Boolean) -> (),
	visit_expr_boolean_end: (self: Self, expr: AstExpr_Boolean) -> (),
	visit_expr_number: (self: Self, expr: AstExpr_Number) -> (),
	visit_expr_number_end: (self: Self, expr: AstExpr_Number) -> (),
	visit_expr_string: (self: Self, expr: AstExpr_String) -> (),
	visit_expr_string_end: (self: Self, expr: AstExpr_String) -> (),
	visit_expr_varargs: (self: Self, expr: AstExpr_Varargs) -> (),
	visit_expr_varargs_end: (self: Self, expr: AstExpr_Varargs) -> (),
	visit_expr_istring: (self: Self, expr: AstExpr_IString) -> (),
	visit_expr_istring_end: (self: Self, expr: AstExpr_IString) -> (),
	visit_expr_table: (self: Self, expr: AstExpr_Table) -> (),
	visit_expr_table_end: (self: Self, expr: AstExpr_Table) -> (),
	visit_expr_function: (self: Self, expr: AstExpr_Function) -> (),
	visit_expr_function_end: (self: Self, expr: AstExpr_Function) -> (),
	visit_expr_ifelse: (self: Self, expr: AstExpr_IfElse) -> (),
	visit_expr_ifelse_end: (self: Self, expr: AstExpr_IfElse) -> (),
	visit_expr_var: (self: Self, expr: AstExpr_Var) -> (),
	visit_expr_var_end: (self: Self, expr: AstExpr_Var) -> (),
	visit_expr_assertion: (self: Self, expr: AstExpr_Assertion) -> (),
	visit_expr_assertion_end: (self: Self, expr: AstExpr_Assertion) -> (),
	visit_expr_unary: (self: Self, expr: AstExpr_Unary) -> (),
	visit_expr_unary_end: (self: Self, expr: AstExpr_Unary) -> (),
	visit_expr_binary: (self: Self, expr: AstExpr_Binary) -> (),
	visit_expr_binary_end: (self: Self, expr: AstExpr_Binary) -> (),
	visit_expr: (self: Self, expr: AstExpr) -> (),
	visit_expr_end: (self: Self, expr: AstExpr) -> (),

	visit_function_arg_pack: (self: Self, arg: AstFunctionArg_Pack) -> (),
	visit_function_arg_pack_end: (self: Self, arg: AstFunctionArg_Pack) -> (),
	visit_function_arg_table: (self: Self, arg: AstFunctionArg_Table) -> (),
	visit_function_arg_table_end: (self: Self, arg: AstFunctionArg_Table) -> (),
	visit_function_arg_string: (self: Self, arg: AstFunctionArg_String) -> (),
	visit_function_arg_string_end: (self: Self, arg: AstFunctionArg_String) -> (),
	visit_function_arg: (self: Self, arg: AstFunctionArg) -> (),
	visit_function_arg_end: (self: Self, arg: AstFunctionArg) -> (),

	visit_var_root_name: (self: Self, root: AstVarRoot_Name) -> (),
	visit_var_root_name_end: (self: Self, root: AstVarRoot_Name) -> (),
	visit_var_root_paren: (self: Self, root: AstVarRoot_Paren) -> (),
	visit_var_root_paren_end: (self: Self, root: AstVarRoot_Paren) -> (),
	visit_var_root: (self: Self, root: AstVarRoot) -> (),
	visit_var_root_end: (self: Self, root: AstVarRoot) -> (),

	visit_var_suffix_nameindex: (self: Self, suffix: AstVarSuffix_NameIndex) -> (),
	visit_var_suffix_nameindex_end: (self: Self, suffix: AstVarSuffix_NameIndex) -> (),
	visit_var_suffix_exprindex: (self: Self, suffix: AstVarSuffix_ExprIndex) -> (),
	visit_var_suffix_exprindex_end: (self: Self, suffix: AstVarSuffix_ExprIndex) -> (),
	visit_var_suffix_call: (self: Self, suffix: AstVarSuffix_Call) -> (),
	visit_var_suffix_call_end: (self: Self, suffix: AstVarSuffix_Call) -> (),
	visit_var_suffix: (self: Self, suffix: AstVarSuffix) -> (),
	visit_var_suffix_end: (self: Self, suffix: AstVarSuffix) -> (),

	visit_var: (self: Self, var: AstVar) -> (),
	visit_var_end: (self: Self, var: AstVar) -> (),

	visit_table_field_namekey: (self: Self, field: AstTableField_NameKey) -> (),
	visit_table_field_namekey_end: (self: Self, field: AstTableField_NameKey) -> (),
	visit_table_field_exprkey: (self: Self, field: AstTableField_ExprKey) -> (),
	visit_table_field_exprkey_end: (self: Self, field: AstTableField_ExprKey) -> (),
	visit_table_field_nokey: (self: Self, field: AstTableField_NoKey) -> (),
	visit_table_field_nokey_end: (self: Self, field: AstTableField_NoKey) -> (),
	visit_table_field: (self: Self, field: AstTableField) -> (),
	visit_table_field_end: (self: Self, field: AstTableField) -> (),

	visit_table: (self: Self, table: AstTable) -> (),
	visit_table_end: (self: Self, table: AstTable) -> (),

	visit_function_body: (self: Self, body: AstFunctionBody) -> (),
	visit_function_body_end: (self: Self, body: AstFunctionBody) -> (),

	visit_ifstat_branch: (self: Self, branch: AstIfStatBranch) -> (),
	visit_ifstat_branch_end: (self: Self, branch: AstIfStatBranch) -> (),

	visit_compound_operator: (self: Self, operator: AstCompoundOperator) -> (),

	visit_stat_assign: (self: Self, stat: AstStat_Assign) -> (),
	visit_stat_assign_end: (self: Self, stat: AstStat_Assign) -> (),
	visit_stat_compoundassign: (self: Self, stat: AstStat_CompoundAssign) -> (),
	visit_stat_compoundassign_end: (self: Self, stat: AstStat_CompoundAssign) -> (),
	visit_stat_call: (self: Self, stat: AstStat_Call) -> (),
	visit_stat_call_end: (self: Self, stat: AstStat_Call) -> (),
	visit_stat_do: (self: Self, stat: AstStat_Do) -> (),
	visit_stat_do_end: (self: Self, stat: AstStat_Do) -> (),
	visit_stat_while: (self: Self, stat: AstStat_While) -> (),
	visit_stat_while_end: (self: Self, stat: AstStat_While) -> (),
	visit_stat_repeat: (self: Self, stat: AstStat_Repeat) -> (),
	visit_stat_repeat_end: (self: Self, stat: AstStat_Repeat) -> (),
	visit_stat_if: (self: Self, stat: AstStat_If) -> (),
	visit_stat_if_end: (self: Self, stat: AstStat_If) -> (),
	visit_stat_numericfor: (self: Self, stat: AstStat_NumericFor) -> (),
	visit_stat_numericfor_end: (self: Self, stat: AstStat_NumericFor) -> (),
	visit_stat_forin: (self: Self, stat: AstStat_ForIn) -> (),
	visit_stat_forin_end: (self: Self, stat: AstStat_ForIn) -> (),
	visit_stat_function: (self: Self, stat: AstStat_Function) -> (),
	visit_stat_function_end: (self: Self, stat: AstStat_Function) -> (),
	visit_stat_localfunction: (self: Self, stat: AstStat_LocalFunction) -> (),
	visit_stat_localfunction_end: (self: Self, stat: AstStat_LocalFunction) -> (),
	visit_stat_localvariable: (self: Self, stat: AstStat_LocalVariable) -> (),
	visit_stat_localvariable_end: (self: Self, stat: AstStat_LocalVariable) -> (),
	visit_stat_type: (self: Self, stat: AstStat_Type) -> (),
	visit_stat_type_end: (self: Self, stat: AstStat_Type) -> (),
	visit_stat: (self: Self, stat: AstStat) -> (),
	visit_stat_end: (self: Self, stat: AstStat) -> (),

	visit_laststat_return: (self: Self, laststat: AstLastStat_Return) -> (),
	visit_laststat_return_end: (self: Self, laststat: AstLastStat_Return) -> (),
	visit_laststat_break: (self: Self, laststat: AstLastStat_Break) -> (),
	visit_laststat_break_end: (self: Self, laststat: AstLastStat_Break) -> (),
	visit_laststat_continue: (self: Self, laststat: AstLastStat_Continue) -> (),
	visit_laststat_continue_end: (self: Self, laststat: AstLastStat_Continue) -> (),
	visit_laststat: (self: Self, laststat: AstLastStat) -> (),
	visit_laststat_end: (self: Self, laststat: AstLastStat) -> (),

	visit_block: (self: Self, block: AstBlock) -> (),
	visit_block_end: (self: Self, block: AstBlock) -> (),

	visit_ast: (self: Self, ast: Ast) -> (),
	visit_ast_end: (self: Self, ast: Ast) -> (),
}

local function visitor<Self>(): Visitor<Self>
	local noop: any = function() end

	return {
		visit_token = noop,

		visit_generic_declaration = noop,
		visit_generic_declaration_end = noop,
		
		visit_generic_declaration_with_defaults = noop,
		visit_generic_declaration_with_defaults_end = noop,

		visit_type_arg = noop,
		visit_type_arg_end = noop,

		visit_table_type_field_nameprop = noop,
		visit_table_type_field_nameprop_end = noop,
		visit_table_type_field_stringprop = noop,
		visit_table_type_field_stringprop_end = noop,
		visit_table_type_field_indexer = noop,
		visit_table_type_field_indexer_end = noop,
		visit_table_type_field = noop,
		visit_table_type_field_end = noop,

		visit_tail_type = noop,
		visit_tail_type_end = noop,

		visit_type_nil = noop,
		visit_type_nil_end = noop,
		visit_type_boolean = noop,
		visit_type_boolean_end = noop,
		visit_type_string = noop,
		visit_type_string_end = noop,
		visit_type_reference = noop,
		visit_type_reference_end = noop,
		visit_type_typeof = noop,
		visit_type_typeof_end = noop,
		visit_type_array = noop,
		visit_type_array_end = noop,
		visit_type_table = noop,
		visit_type_table_end = noop,
		visit_type_function = noop,
		visit_type_function_end = noop,
		visit_type_paren = noop,
		visit_type_paren_end = noop,
		visit_type_optional = noop,
		visit_type_optional_end = noop,
		visit_type_union = noop,
		visit_type_union_end = noop,
		visit_type_intersection = noop,
		visit_type_intersection_end = noop,
		visit_type = noop,
		visit_type_end = noop,

		visit_typepack_variadic = noop,
		visit_typepack_variadic_end = noop,
		visit_typepack_generic = noop,
		visit_typepack_generic_end = noop,
		visit_typepack_list = noop,
		visit_typepack_list_end = noop,
		visit_typepack = noop,
		visit_typepack_end = noop,

		visit_return_type = noop,
		visit_return_type_end = noop,

		visit_binding = noop,
		visit_binding_end = noop,

		visit_istring_simple = noop,
		visit_istring_simple_end = noop,
		visit_istring_complex = noop,
		visit_istring_complex_end = noop,
		visit_istring = noop,
		visit_istring_end = noop,

		visit_ifelse_expr_branch = noop,
		visit_ifelse_expr_branch_end = noop,

		visit_unary_operator = noop,
		visit_binary_operator = noop,

		visit_expr_nil = noop,
		visit_expr_nil_end = noop,
		visit_expr_boolean = noop,
		visit_expr_boolean_end = noop,
		visit_expr_number = noop,
		visit_expr_number_end = noop,
		visit_expr_string = noop,
		visit_expr_string_end = noop,
		visit_expr_varargs = noop,
		visit_expr_varargs_end = noop,
		visit_expr_istring = noop,
		visit_expr_istring_end = noop,
		visit_expr_table = noop,
		visit_expr_table_end = noop,
		visit_expr_function = noop,
		visit_expr_function_end = noop,
		visit_expr_ifelse = noop,
		visit_expr_ifelse_end = noop,
		visit_expr_var = noop,
		visit_expr_var_end = noop,
		visit_expr_assertion = noop,
		visit_expr_assertion_end = noop,
		visit_expr_unary = noop,
		visit_expr_unary_end = noop,
		visit_expr_binary = noop,
		visit_expr_binary_end = noop,
		visit_expr = noop,
		visit_expr_end = noop,

		visit_function_arg_pack = noop,
		visit_function_arg_pack_end = noop,
		visit_function_arg_table = noop,
		visit_function_arg_table_end = noop,
		visit_function_arg_string = noop,
		visit_function_arg_string_end = noop,
		visit_function_arg = noop,
		visit_function_arg_end = noop,

		visit_var_root_name = noop,
		visit_var_root_name_end = noop,
		visit_var_root_paren = noop,
		visit_var_root_paren_end = noop,
		visit_var_root = noop,
		visit_var_root_end = noop,

		visit_var_suffix_nameindex = noop,
		visit_var_suffix_nameindex_end = noop,
		visit_var_suffix_exprindex = noop,
		visit_var_suffix_exprindex_end = noop,
		visit_var_suffix_call = noop,
		visit_var_suffix_call_end = noop,
		visit_var_suffix = noop,
		visit_var_suffix_end = noop,

		visit_var = noop,
		visit_var_end = noop,

		visit_table_field_namekey = noop,
		visit_table_field_namekey_end = noop,
		visit_table_field_exprkey = noop,
		visit_table_field_exprkey_end = noop,
		visit_table_field_nokey = noop,
		visit_table_field_nokey_end = noop,
		visit_table_field = noop,
		visit_table_field_end = noop,

		visit_table = noop,
		visit_table_end = noop,

		visit_function_body = noop,
		visit_function_body_end = noop,

		visit_ifstat_branch = noop,
		visit_ifstat_branch_end = noop,

		visit_compound_operator = noop,

		visit_stat_assign = noop,
		visit_stat_assign_end = noop,
		visit_stat_compoundassign = noop,
		visit_stat_compoundassign_end = noop,
		visit_stat_call = noop,
		visit_stat_call_end = noop,
		visit_stat_do = noop,
		visit_stat_do_end = noop,
		visit_stat_while = noop,
		visit_stat_while_end = noop,
		visit_stat_repeat = noop,
		visit_stat_repeat_end = noop,
		visit_stat_if = noop,
		visit_stat_if_end = noop,
		visit_stat_numericfor = noop,
		visit_stat_numericfor_end = noop,
		visit_stat_forin = noop,
		visit_stat_forin_end = noop,
		visit_stat_function = noop,
		visit_stat_function_end = noop,
		visit_stat_localfunction = noop,
		visit_stat_localfunction_end = noop,
		visit_stat_localvariable = noop,
		visit_stat_localvariable_end = noop,
		visit_stat_type = noop,
		visit_stat_type_end = noop,
		visit_stat = noop,
		visit_stat_end = noop,

		visit_laststat_return = noop,
		visit_laststat_return_end = noop,
		visit_laststat_break = noop,
		visit_laststat_break_end = noop,
		visit_laststat_continue = noop,
		visit_laststat_continue_end = noop,
		visit_laststat = noop,
		visit_laststat_end = noop,

		visit_block = noop,
		visit_block_end = noop,

		visit_ast = noop,
		visit_ast_end = noop,
	}
end

do
	local visit_generic_declaration: <Self>(self: Self, visitor: Visitor<Self>, generic_declaration: AstGenericDeclaration) -> ()
	local visit_generic_declaration_with_defaults: <Self>(self: Self, visitor: Visitor<Self>, generic_declaration_with_defaults: AstGenericDeclarationWithDefaults) -> ()
	local visit_type: <Self>(self: Self, visitor: Visitor<Self>, type: AstType) -> ()
	local visit_typepack: <Self>(self: Self, visitor: Visitor<Self>, typepack: AstTypePack) -> ()
	local visit_return_type: <Self>(self: Self, visitor: Visitor<Self>, return_type: AstReturnType) -> ()
	local visit_expr: <Self>(self: Self, visitor: Visitor<Self>, expr: AstExpr) -> ()
	local visit_var: <Self>(self: Self, visitor: Visitor<Self>, var: AstVar) -> ()
	local visit_table: <Self>(self: Self, visitor: Visitor<Self>, table: AstTable) -> ()
	local visit_function_body: <Self>(self: Self, visitor: Visitor<Self>, body: AstFunctionBody) -> ()
	local visit_stat: <Self>(self: Self, visitor: Visitor<Self>, stat: AstStat) -> ()
	local visit_laststat: <Self>(self: Self, visitor: Visitor<Self>, laststat: AstLastStat) -> ()
	local visit_block: <Self>(self: Self, visitor: Visitor<Self>, block: AstBlock) -> ()

	function visit_generic_declaration<Self>(self: Self, visitor: Visitor<Self>, generic_declaration: AstGenericDeclaration)
		visitor.visit_generic_declaration(self, generic_declaration)
		visitor.visit_token(self, generic_declaration.angles.open)

		for _, pair in generic_declaration.names do
			local node, sep = pair.node, pair.sep

			visitor.visit_token(self, node)

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		for _, pair in generic_declaration.packs do
			local node, sep = pair.node, pair.sep

			visitor.visit_token(self, node.name)
			visitor.visit_token(self, node.dots)

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		visitor.visit_token(self, generic_declaration.angles.close)
		visitor.visit_generic_declaration_end(self, generic_declaration)
	end

	function visit_generic_declaration_with_defaults<Self>(self: Self, visitor: Visitor<Self>, generic_declaration_with_defaults: AstGenericDeclarationWithDefaults)
		visitor.visit_generic_declaration_with_defaults(self, generic_declaration_with_defaults)
		visitor.visit_token(self, generic_declaration_with_defaults.angles.open)

		for _, pair in generic_declaration_with_defaults.names do
			local node, sep = pair.node, pair.sep

			visitor.visit_token(self, node.name)

			local default = node.default
			if default then
				visitor.visit_token(self, default.equals)
				visit_type(self, visitor, default.type)
			end

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		for _, pair in generic_declaration_with_defaults.packs do
			local node, sep = pair.node, pair.sep

			visitor.visit_token(self, node.name)
			visitor.visit_token(self, node.dots)

			local default = node.default
			if default then
				visitor.visit_token(self, default.equals)
				visit_typepack(self, visitor, default.pack)
			end

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		visitor.visit_token(self, generic_declaration_with_defaults.angles.close)
		visitor.visit_generic_declaration_with_defaults_end(self, generic_declaration_with_defaults)
	end

	function visit_type<Self>(self: Self, visitor: Visitor<Self>, type: AstType)
		visitor.visit_type(self, type)

		if type.kind == "nil" then
			visitor.visit_type_nil(self, type)
			visitor.visit_token(self, type.tok)
			visitor.visit_type_nil_end(self, type)
		elseif type.kind == "boolean" then
			visitor.visit_type_boolean(self, type)
			visitor.visit_token(self, type.tok)
			visitor.visit_type_boolean_end(self, type)
		elseif type.kind == "string" then
			visitor.visit_type_string(self, type)
			visitor.visit_token(self, type.tok)
			visitor.visit_type_string_end(self, type)
		elseif type.kind == "reference" then
			visitor.visit_type_reference(self, type)
			
			local prefix = type.prefix
			if prefix then
				visitor.visit_token(self, prefix.name)
				visitor.visit_token(self, prefix.dot)
			end

			visitor.visit_token(self, type.name)

			local generics = type.generics
			if generics then
				visitor.visit_token(self, generics.angles.open)

				for _, pair in generics.types do
					local node, sep = pair.node, pair.sep

					visitor.visit_type_arg(self, node)

					if 
						node.kind == "variadic"
						or node.kind == "generic"
						or node.kind == "list"
					then
						visit_typepack(self, visitor, node)
					else
						visit_type(self, visitor, node)
					end

					visitor.visit_type_arg_end(self, node)

					if sep then
						visitor.visit_token(self, sep)
					end
				end

				visitor.visit_token(self, generics.angles.close)
			end

			visitor.visit_type_reference_end(self, type)
		elseif type.kind == "typeof" then
			visitor.visit_type_typeof(self, type)
			visitor.visit_token(self, type.typeof_tok)
			visitor.visit_token(self, type.parens.open)
			visit_expr(self, visitor, type.expr)
			visitor.visit_token(self, type.parens.close)
			visitor.visit_type_typeof_end(self, type)
		elseif type.kind == "array" then
			visitor.visit_type_array(self, type)
			visitor.visit_token(self, type.braces.open)
			visit_type(self, visitor, type.type)
			visitor.visit_token(self, type.braces.close)
			visitor.visit_type_array_end(self, type)
		elseif type.kind == "table" then
			visitor.visit_type_table(self, type)
			visitor.visit_token(self, type.braces.open)

			for _, pair in type.fields do
				local node, sep = pair.node, pair.sep

				visitor.visit_table_type_field(self, node)

				if node.kind == "nameprop" then
					visitor.visit_table_type_field_nameprop(self, node)

					local access = node.access
					if access then
						visitor.visit_token(self, access)
					end

					visitor.visit_token(self, node.name)
					visitor.visit_token(self, node.colon)
					visit_type(self, visitor, node.type)

					visitor.visit_table_type_field_nameprop_end(self, node)
				elseif node.kind == "stringprop" then
					visitor.visit_table_type_field_stringprop(self, node)

					local access = node.access
					if access then
						visitor.visit_token(self, access)
					end

					visitor.visit_token(self, node.bracks.open)
					visitor.visit_token(self, node.key)
					visitor.visit_token(self, node.bracks.close)
					visitor.visit_token(self, node.colon)
					visit_type(self, visitor, node.type)

					visitor.visit_table_type_field_stringprop_end(self, node)
				elseif node.kind == "indexer" then
					visitor.visit_table_type_field_indexer(self, node)

					local access = node.access
					if access then
						visitor.visit_token(self, access)
					end

					visitor.visit_token(self, node.bracks.open)
					visit_type(self, visitor, node.key)
					visitor.visit_token(self, node.bracks.close)
					visitor.visit_token(self, node.colon)
					visit_type(self, visitor, node.type)

					visitor.visit_table_type_field_indexer_end(self, node)
				end

				visitor.visit_table_type_field_end(self, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_token(self, type.braces.close)
			visitor.visit_type_table_end(self, type)
		elseif type.kind == "function" then
			visitor.visit_type_function(self, type)

			local generics = type.generics
			if generics then
				visit_generic_declaration(self, visitor, generics)
			end

			visitor.visit_token(self, type.parens.open)

			for _, pair in type.params do
				local node, sep = pair.node, pair.sep

				local name = node.name
				if name then
					visitor.visit_token(self, name.name)
					visitor.visit_token(self, name.colon)
				end

				visit_type(self, visitor, node.type)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			local varargs = type.varargs
			if varargs then
				visitor.visit_tail_type(self, varargs)

				if varargs.kind == "variadic" then
					visitor.visit_typepack_variadic(self, varargs)
					visitor.visit_token(self, varargs.dots)
					visit_type(self, visitor, varargs.type)
					visitor.visit_typepack_variadic_end(self, varargs)
				elseif varargs.kind == "generic" then
					visitor.visit_typepack_generic(self, varargs)
					visitor.visit_token(self, varargs.name)
					visitor.visit_token(self, varargs.dots)
					visitor.visit_typepack_generic_end(self, varargs)
				end

				visitor.visit_tail_type_end(self, varargs)
			end

			visitor.visit_token(self, type.parens.close)
			visitor.visit_token(self, type.arrow)
			visit_return_type(self, visitor, type.ret)
			visitor.visit_type_function_end(self, type)
		elseif type.kind == "paren" then
			visitor.visit_type_paren(self, type)
			visitor.visit_token(self, type.parens.open)
			visit_type(self, visitor, type.type)
			visitor.visit_token(self, type.parens.close)
			visitor.visit_type_paren_end(self, type)
		elseif type.kind == "optional" then
			visitor.visit_type_optional(self, type)
			visit_type(self, visitor, type.type)
			visitor.visit_token(self, type.question)
			visitor.visit_type_optional_end(self, type)
		elseif type.kind == "union" then
			visitor.visit_type_union(self, type)
			
			local leading = type.leading
			if leading then
				visitor.visit_token(self, leading)
			end

			for _, pair in type.types do
				local node, sep = pair.node, pair.sep

				visit_type(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_type_union_end(self, type)
		elseif type.kind == "intersection" then
			visitor.visit_type_intersection(self, type)
			
			local leading = type.leading
			if leading then
				visitor.visit_token(self, leading)
			end

			for _, pair in type.types do
				local node, sep = pair.node, pair.sep

				visit_type(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_type_intersection_end(self, type)
		end

		visitor.visit_type_end(self, type)
	end

	function visit_typepack<Self>(self: Self, visitor: Visitor<Self>, typepack: AstTypePack)
		visitor.visit_typepack(self, typepack)

		if typepack.kind == "variadic" then
			visitor.visit_typepack_variadic(self, typepack)
			visitor.visit_token(self, typepack.dots)
			visit_type(self, visitor, typepack.type)
			visitor.visit_typepack_variadic_end(self, typepack)
		elseif typepack.kind == "generic" then
			visitor.visit_typepack_generic(self, typepack)
			visitor.visit_token(self, typepack.name)
			visitor.visit_token(self, typepack.dots)
			visitor.visit_typepack_generic_end(self, typepack)
		elseif typepack.kind == "list" then
			visitor.visit_typepack_list(self, typepack)
			visitor.visit_token(self, typepack.parens.open)

			for _, pair in typepack.types do
				local node, sep = pair.node, pair.sep

				visit_type(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			local tail = typepack.tail
			if tail then
				visitor.visit_tail_type(self, tail)

				if tail.kind == "variadic" then
					visitor.visit_typepack_variadic(self, tail)
					visitor.visit_token(self, tail.dots)
					visit_type(self, visitor, tail.type)
					visitor.visit_typepack_variadic_end(self, tail)
				elseif tail.kind == "generic" then
					visitor.visit_typepack_generic(self, tail)
					visitor.visit_token(self, tail.name)
					visitor.visit_token(self, tail.dots)
					visitor.visit_typepack_generic_end(self, tail)
				end

				visitor.visit_tail_type_end(self, tail)
			end

			visitor.visit_token(self, typepack.parens.close)
			visitor.visit_typepack_list_end(self, typepack)
		end

		visitor.visit_typepack_end(self, typepack)
	end

	function visit_return_type<Self>(self: Self, visitor: Visitor<Self>, return_type: AstReturnType)
		visitor.visit_return_type(self, return_type)

		if
			return_type.kind == "variadic"
			or return_type.kind == "generic"
			or return_type.kind == "list"
		then
			visit_typepack(self, visitor, return_type)
		else 
			visit_type(self, visitor, return_type)
		end

		visitor.visit_return_type_end(self, return_type)
	end

	function visit_expr<Self>(self: Self, visitor: Visitor<Self>, expr: AstExpr)
		visitor.visit_expr(self, expr)

		if expr.kind == "nil" then
			visitor.visit_expr_nil(self, expr)
			visitor.visit_token(self, expr.tok)
			visitor.visit_expr_nil_end(self, expr)
		elseif expr.kind == "boolean" then
			visitor.visit_expr_boolean(self, expr)
			visitor.visit_token(self, expr.tok)
			visitor.visit_expr_boolean_end(self, expr)
		elseif expr.kind == "number" then
			visitor.visit_expr_number(self, expr)
			visitor.visit_token(self, expr.tok)
			visitor.visit_expr_number_end(self, expr)
		elseif expr.kind == "string" then
			visitor.visit_expr_string(self, expr)
			visitor.visit_token(self, expr.tok)
			visitor.visit_expr_string_end(self, expr)
		elseif expr.kind == "varargs" then
			visitor.visit_expr_varargs(self, expr)
			visitor.visit_token(self, expr.tok)
			visitor.visit_expr_varargs_end(self, expr)
		elseif expr.kind == "istring" then
			visitor.visit_expr_istring(self, expr)

			local istring = expr.istring
			visitor.visit_istring(self, istring)

			if istring.kind == "simple" then
				visitor.visit_istring_simple(self, istring)
				visitor.visit_token(self, istring.tok)
				visitor.visit_istring_simple_end(self, istring)
			elseif istring.kind == "complex" then
				visitor.visit_istring_complex(self, istring)
				visitor.visit_token(self, istring.first)
				
				for _, pair in istring.middle do
					local node, sep = pair.node, pair.sep

					visit_expr(self, visitor, node)

					if sep then
						visitor.visit_token(self, sep)
					end
				end

				visitor.visit_token(self, istring.last)
				visitor.visit_istring_complex_end(self, istring)
			end

			visitor.visit_istring_end(self, istring)
			visitor.visit_expr_istring_end(self, expr)
		elseif expr.kind == "table" then
			visitor.visit_expr_table(self, expr)
			visit_table(self, visitor, expr.table)
			visitor.visit_expr_table_end(self, expr)
		elseif expr.kind == "function" then
			visitor.visit_expr_function(self, expr)
			
			for _, tok in expr.attributes do
				visitor.visit_token(self, tok)
			end

			visitor.visit_token(self, expr.function_tok)
			visit_function_body(self, visitor, expr.body)
			visitor.visit_expr_function_end(self, expr)
		elseif expr.kind == "ifelse" then
			visitor.visit_expr_ifelse(self, expr)
			visitor.visit_token(self, expr.if_tok)

			for _, pair in expr.branches do
				local node, sep = pair.node, pair.sep

				visitor.visit_ifelse_expr_branch(self, node)

				visit_expr(self, visitor, node.condition)
				visitor.visit_token(self, node.then_tok)
				visit_expr(self, visitor, node.body)

				visitor.visit_ifelse_expr_branch_end(self, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_token(self, expr.else_tok)
			visit_expr(self, visitor, expr.else_body)
			visitor.visit_expr_ifelse_end(self, expr)
		elseif expr.kind == "var" then
			visitor.visit_expr_var(self, expr)
			visit_var(self, visitor, expr.var)
			visitor.visit_expr_var_end(self, expr)
		elseif expr.kind == "assertion" then
			visitor.visit_expr_assertion(self, expr)
			visit_expr(self, visitor, expr.expr)
			visitor.visit_token(self, expr.colon)
			visit_type(self, visitor, expr.type)
			visitor.visit_expr_assertion_end(self, expr)
		elseif expr.kind == "unary" then
			visitor.visit_expr_unary(self, expr)
			visitor.visit_unary_operator(self, expr.operator)
			visitor.visit_token(self, expr.operator)
			visit_expr(self, visitor, expr.expr)
			visitor.visit_expr_unary_end(self, expr)
		elseif expr.kind == "binary" then
			visitor.visit_expr_binary(self, expr)
			visit_expr(self, visitor, expr.left)
			visitor.visit_binary_operator(self, expr.operator)
			visitor.visit_token(self, expr.operator)
			visit_expr(self, visitor, expr.right)
			visitor.visit_expr_binary_end(self, expr)
		end

		visitor.visit_expr_end(self, expr)
	end

	function visit_var<Self>(self: Self, visitor: Visitor<Self>, var: AstVar)
		visitor.visit_var(self, var)

		local root = var.root
		visitor.visit_var_root(self, root)

		if root.kind == "name" then
			visitor.visit_var_root_name(self, root)
			visitor.visit_token(self, root.tok)
			visitor.visit_var_root_name_end(self, root)
		elseif root.kind == "paren" then
			visitor.visit_var_root_paren(self, root)
			visitor.visit_token(self, root.parens.open)
			visit_expr(self, visitor, root.expr)
			visitor.visit_token(self, root.parens.close)
			visitor.visit_var_root_paren_end(self, root)
		end

		for _, suffix in var.suffixes do
			visitor.visit_var_suffix(self, suffix)

			if suffix.kind == "nameindex" then
				visitor.visit_var_suffix_nameindex(self, suffix)
				visitor.visit_token(self, suffix.dot)
				visitor.visit_token(self, suffix.name)
				visitor.visit_var_suffix_nameindex_end(self, suffix)
			elseif suffix.kind == "exprindex" then
				visitor.visit_var_suffix_exprindex(self, suffix)
				visitor.visit_token(self, suffix.bracks.open)
				visit_expr(self, visitor, suffix.expr)
				visitor.visit_token(self, suffix.bracks.close)
				visitor.visit_var_suffix_exprindex_end(self, suffix)
			elseif suffix.kind == "call" then
				visitor.visit_var_suffix_call(self, suffix)
				
				local method = suffix.method
				if method then
					visitor.visit_token(self, method.colon)
					visitor.visit_token(self, method.name)
				end

				local arg = suffix.arg
				visitor.visit_function_arg(self, arg)

				if arg.kind == "pack" then
					visitor.visit_function_arg_pack(self, arg)
					visitor.visit_token(self, arg.parens.open)

					for _, pair in arg.exprs do
						local node, sep = pair.node, pair.sep

						visit_expr(self, visitor, node)

						if sep then
							visitor.visit_token(self, sep)
						end
					end

					visitor.visit_token(self, arg.parens.close)
					visitor.visit_function_arg_pack_end(self, arg)
				elseif arg.kind == "table" then
					visitor.visit_function_arg_table(self, arg)
					visit_table(self, visitor, arg.table)
					visitor.visit_function_arg_table_end(self, arg)
				elseif arg.kind == "string" then
					visitor.visit_function_arg_string(self, arg)
					visitor.visit_token(self, arg.tok)
					visitor.visit_function_arg_string_end(self, arg)
				end

				visitor.visit_function_arg_end(self, arg)
				visitor.visit_var_suffix_call_end(self, suffix)
			end

			visitor.visit_var_suffix_end(self, suffix)
		end

		visitor.visit_var_end(self, var)
	end

	function visit_table<Self>(self: Self, visitor: Visitor<Self>, table: AstTable)
		visitor.visit_table(self, table)
		visitor.visit_token(self, table.braces.open)

		for _, pair in table.fields do
			local node, sep = pair.node, pair.sep

			visitor.visit_table_field(self, node)

			if node.kind == "namekey" then
				visitor.visit_table_field_namekey(self, node)
				visitor.visit_token(self, node.name)
				visitor.visit_token(self, node.equals)
				visit_expr(self, visitor, node.value)
				visitor.visit_table_field_namekey_end(self, node)
			elseif node.kind == "exprkey" then
				visitor.visit_table_field_exprkey(self, node)
				visitor.visit_token(self, node.bracks.open)
				visit_expr(self, visitor, node.key)
				visitor.visit_token(self, node.bracks.close)
				visitor.visit_token(self, node.equals)
				visit_expr(self, visitor, node.value)
				visitor.visit_table_field_exprkey_end(self, node)
			elseif node.kind == "nokey" then
				visitor.visit_table_field_nokey(self, node)
				visit_expr(self, visitor, node.value)
				visitor.visit_table_field_nokey_end(self, node)
			end

			visitor.visit_table_field_end(self, node)

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		visitor.visit_token(self, table.braces.close)
		visitor.visit_table_end(self, table)
	end

	function visit_function_body<Self>(self: Self, visitor: Visitor<Self>, body: AstFunctionBody)
		visitor.visit_function_body(self, body)
		
		local generics = body.generics
		if generics then
			visit_generic_declaration(self, visitor, generics)
		end

		visitor.visit_token(self, body.parens.open)

		for _, pair in body.params do
			local node, sep = pair.node, pair.sep

			visitor.visit_token(self, node.name)

			local type = node.type
			if type then
				visitor.visit_token(self, type.colon)
				visit_type(self, visitor, type.type)
			end

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		local varargs = body.varargs
		if varargs then
			visitor.visit_token(self, varargs.dots)

			local type = varargs.type
			if type then
				visitor.visit_token(self, type.colon)

				local inner = type.type
				if inner.kind == "generic" then
					visitor.visit_typepack_generic(self, inner)
					visitor.visit_token(self, inner.name)
					visitor.visit_token(self, inner.dots)
					visitor.visit_typepack_generic_end(self, inner)
				else
					visit_type(self, visitor, inner)
				end
			end
		end

		visitor.visit_token(self, body.parens.close)

		local ret = body.ret
		if ret then
			visitor.visit_token(self, ret.colon)
			visit_return_type(self, visitor, ret.type)
		end

		visit_block(self, visitor, body.block)
		visitor.visit_token(self, body.end_tok)
		visitor.visit_function_body_end(self, body)
	end

	function visit_stat<Self>(self: Self, visitor: Visitor<Self>, stat: AstStat)
		visitor.visit_stat(self, stat)

		if stat.kind == "assign" then
			visitor.visit_stat_assign(self, stat)

			for _, pair in stat.left do
				local node, sep = pair.node, pair.sep

				visit_var(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_token(self, stat.equals)

			for _, pair in stat.right do
				local node, sep = pair.node, pair.sep

				visit_expr(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_stat_assign_end(self, stat)
		elseif stat.kind == "compoundassign" then
			visitor.visit_stat_compoundassign(self, stat)
			visit_var(self, visitor, stat.left)
			visitor.visit_compound_operator(self, stat.operator)
			visitor.visit_token(self, stat.operator)
			visit_expr(self, visitor, stat.right)
			visitor.visit_stat_compoundassign_end(self, stat)
		elseif stat.kind == "call" then
			visitor.visit_stat_call(self, stat)
			visit_var(self, visitor, stat.call)
			visitor.visit_stat_call_end(self, stat)
		elseif stat.kind == "do" then
			visitor.visit_stat_do(self, stat)
			visitor.visit_token(self, stat.do_tok)
			visit_block(self, visitor, stat.block)
			visitor.visit_token(self, stat.end_tok)
			visitor.visit_stat_do_end(self, stat)
		elseif stat.kind == "while" then
			visitor.visit_stat_while(self, stat)
			visitor.visit_token(self, stat.while_tok)
			visit_expr(self, visitor, stat.condition)
			visitor.visit_token(self, stat.do_tok)
			visit_block(self, visitor, stat.block)
			visitor.visit_token(self, stat.end_tok)
			visitor.visit_stat_while_end(self, stat)
		elseif stat.kind == "repeat" then
			visitor.visit_stat_repeat(self, stat)
			visitor.visit_token(self, stat.repeat_tok)
			visit_block(self, visitor, stat.block)
			visitor.visit_token(self, stat.until_tok)
			visit_expr(self, visitor, stat.condition)
			visitor.visit_stat_repeat_end(self, stat)
		elseif stat.kind == "if" then
			visitor.visit_stat_if(self, stat)
			visitor.visit_token(self, stat.if_tok)

			for _, pair in stat.branches do
				local node, sep = pair.node, pair.sep

				visitor.visit_ifstat_branch(self, node)

				visit_expr(self, visitor, node.condition)
				visitor.visit_token(self, node.then_tok)
				visit_block(self, visitor, node.block)

				visitor.visit_ifstat_branch_end(self, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			local else_branch = stat.else_branch
			if else_branch then
				visitor.visit_token(self, else_branch.else_tok)
				visit_block(self, visitor, else_branch.block)
			end

			visitor.visit_token(self, stat.end_tok)
			visitor.visit_stat_if_end(self, stat)
		elseif stat.kind == "numericfor" then
			visitor.visit_stat_numericfor(self, stat)
			visitor.visit_token(self, stat.for_tok)

			local binding = stat.binding
			visitor.visit_binding(self, binding)
			visitor.visit_token(self, binding.name)

			local type = binding.type
			if type then
				visitor.visit_token(self, type.colon)
				visit_type(self, visitor, type.type)
			end

			visitor.visit_binding_end(self, binding)

			visitor.visit_token(self, stat.equals)
			visit_expr(self, visitor, stat.start_expr)
			visitor.visit_token(self, stat.comma)
			visit_expr(self, visitor, stat.end_expr)

			local step = stat.step
			if step then
				visitor.visit_token(self, step.comma)
				visit_expr(self, visitor, step.expr)
			end

			visitor.visit_token(self, stat.do_tok)
			visit_block(self, visitor, stat.block)
			visitor.visit_token(self, stat.end_tok)
			visitor.visit_stat_numericfor_end(self, stat)
		elseif stat.kind == "forin" then
			visitor.visit_stat_forin(self, stat)
			visitor.visit_token(self, stat.for_tok)
			
			for _, pair in stat.bindings do
				local node, sep = pair.node, pair.sep

				visitor.visit_binding(self, node)
				visitor.visit_token(self, node.name)

				local type = node.type
				if type then
					visitor.visit_token(self, type.colon)
					visit_type(self, visitor, type.type)
				end

				visitor.visit_binding_end(self, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_token(self, stat.in_tok)

			for _, pair in stat.exprs do
				local node, sep = pair.node, pair.sep

				visit_expr(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_token(self, stat.do_tok)
			visit_block(self, visitor, stat.block)
			visitor.visit_token(self, stat.end_tok)
			visitor.visit_stat_forin_end(self, stat)
		elseif stat.kind == "function" then
			visitor.visit_stat_function(self, stat)
			
			for _, tok in stat.attributes do
				visitor.visit_token(self, tok)
			end

			visitor.visit_token(self, stat.function_tok)

			for _, pair in stat.names do
				local node, sep = pair.node, pair.sep

				visitor.visit_token(self, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			local method = stat.method
			if method then
				visitor.visit_token(self, method.colon)
				visitor.visit_token(self, method.name)
			end

			visit_function_body(self, visitor, stat.body)
			visitor.visit_stat_function_end(self, stat)
		elseif stat.kind == "localfunction" then
			visitor.visit_stat_localfunction(self, stat)
			
			for _, tok in stat.attributes do
				visitor.visit_token(self, tok)
			end

			visitor.visit_token(self, stat.local_tok)
			visitor.visit_token(self, stat.function_tok)
			visitor.visit_token(self, stat.name)
			visit_function_body(self, visitor, stat.body)
			visitor.visit_stat_localfunction_end(self, stat)
		elseif stat.kind == "localvariable" then
			visitor.visit_stat_localvariable(self, stat)
			visitor.visit_token(self, stat.local_tok)

			for _, pair in stat.bindings do
				local node, sep = pair.node, pair.sep

				visitor.visit_token(self, node.name)

				local type = node.type
				if type then
					visitor.visit_token(self, type.colon)
					visit_type(self, visitor, type.type)
				end

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			local values = stat.values
			if values then
				visitor.visit_token(self, values.equals)

				for _, pair in values.exprs do
					local node, sep = pair.node, pair.sep

					visit_expr(self, visitor, node)

					if sep then
						visitor.visit_token(self, sep)
					end
				end
			end

			visitor.visit_stat_localvariable_end(self, stat)
		elseif stat.kind == "type" then
			visitor.visit_stat_type(self, stat)
			
			local export_tok = stat.export_tok
			if export_tok then
				visitor.visit_token(self, export_tok)
			end

			visitor.visit_token(self, stat.type_tok)
			visitor.visit_token(self, stat.name)
			
			local generics = stat.generics
			if generics then
				visit_generic_declaration_with_defaults(self, visitor, generics)
			end

			visitor.visit_token(self, stat.equals)
			visit_type(self, visitor, stat.type)
			visitor.visit_stat_type_end(self, stat)
		end

		visitor.visit_stat_end(self, stat)
	end

	function visit_laststat<Self>(self: Self, visitor: Visitor<Self>, laststat: AstLastStat)
		visitor.visit_laststat(self, laststat)

		if laststat.kind == "return" then
			visitor.visit_laststat_return(self, laststat)
			visitor.visit_token(self, laststat.return_tok)

			for _, pair in laststat.exprs do
				local node, sep = pair.node, pair.sep

				visit_expr(self, visitor, node)

				if sep then
					visitor.visit_token(self, sep)
				end
			end

			visitor.visit_laststat_return_end(self, laststat)
		elseif laststat.kind == "break" then
			visitor.visit_laststat_break(self, laststat)
			visitor.visit_token(self, laststat.tok)
			visitor.visit_laststat_break_end(self, laststat)
		elseif laststat.kind == "continue" then
			visitor.visit_laststat_continue(self, laststat)
			visitor.visit_token(self, laststat.tok)
			visitor.visit_laststat_continue_end(self, laststat)
		end

		visitor.visit_laststat_end(self, laststat)
	end

	function visit_block<Self>(self: Self, visitor: Visitor<Self>, block: AstBlock)
		visitor.visit_block(self, block)

		for _, pair in block.stats do
			local node, sep = pair.node, pair.sep

			visit_stat(self, visitor, node)

			if sep then
				visitor.visit_token(self, sep)
			end
		end

		local laststat = block.laststat
		if laststat then
			visit_laststat(self, visitor, laststat.stat)

			local semicolon = laststat.semicolon
			if semicolon then
				visitor.visit_token(self, semicolon)
			end
		end

		visitor.visit_block_end(self, block)
	end

	function ast.visit<Self>(self: Self, visitor: Visitor<Self>, ast: Ast)
		visitor.visit_ast(self, ast)
		visit_block(self, visitor, ast.block)
		visitor.visit_token(self, ast.eof)
		visitor.visit_ast_end(self, ast)
	end
end

do
	local span_generic_declaration: (node: AstGenericDeclaration) -> Span
	local span_generic_declaration_with_defaults: (node: AstGenericDeclarationWithDefaults) -> Span
	local span_type_arg: (node: AstTypeArg) -> Span
	local span_table_type_field: (node: AstTableTypeField) -> Span
	local span_tail_type: (node: AstTailType) -> Span
	local span_type: (node: AstType) -> Span
	local span_type_pack: (node: AstTypePack) -> Span
	local span_return_type: (node: AstReturnType) -> Span
	local span_binding: (node: AstBinding) -> Span
	local span_istring: (node: AstIString) -> Span
	local span_if_else_expr_branch: (node: AstIfElseExprBranch) -> Span
	local span_expr: (node: AstExpr) -> Span
	local span_function_arg: (node: AstFunctionArg) -> Span
	local span_var_root: (node: AstVarRoot) -> Span
	local span_var_suffix: (node: AstVarSuffix) -> Span
	local span_var: (node: AstVar) -> Span
	local span_table_field: (node: AstTableField) -> Span
	local span_table: (node: AstTable) -> Span
	local span_function_body: (node: AstFunctionBody) -> Span
	local span_if_stat_branch: (node: AstIfStatBranch) -> Span
	local span_stat: (node: AstStat) -> Span
	local span_laststat: (node: AstLastStat) -> Span
	local span_block: (node: AstBlock) -> Span

	local function merge(left: Span, right: Span): Span
		return {
			x = left.x,
			y = right.y,
			z = 0,
		}
	end

	function span_generic_declaration(node: AstGenericDeclaration): Span
		local angles = node.angles
		return merge(angles.open.span, angles.close.span)
	end

	function span_generic_declaration_with_defaults(node: AstGenericDeclarationWithDefaults): Span
		local angles = node.angles
		return merge(angles.open.span, angles.close.span)
	end

	function span_type_arg(node: AstTypeArg): Span
		if
			node.kind == "variadic"
			or node.kind == "generic"
			or node.kind == "list"
		then
			return span_type_pack(node)
		else
			return span_type(node)
		end
	end

	function span_table_type_field(node: AstTableTypeField): Span
		local access = node.access

		if access == nil then
			local span: Span

			if node.kind == "nameprop" then
				span = node.name.span
			elseif node.kind == "stringprop" or node.kind == "indexer" then
				span = node.bracks.open.span
			else
				error("unreachable")
			end

			return merge(span, span_type(node.type))
		else
			return merge(access.span, span_type(node.type))
		end
	end

	function span_tail_type(node: AstTailType): Span
		if
			node.kind == "variadic"
			or node.kind == "generic"
			or node.kind == "list"
		then
			return span_type_pack(node)
		else
			return span_type(node)
		end
	end

	function span_type(node: AstType): Span
		if
			node.kind == "nil"
			or node.kind == "boolean"
			or node.kind == "string"
		then
			return node.tok.span
		elseif node.kind == "reference" then
			local prefix = node.prefix
			local generics = node.generics

			return merge(
				if prefix then prefix.name.span else node.name.span,
				if generics then generics.angles.close.span else node.name.span
			)
		elseif node.kind == "typeof" then
			return merge(
				node.typeof_tok.span,
				node.parens.close.span
			)
		elseif node.kind == "array" or node.kind == "table" then
			return merge(
				node.braces.open.span,
				node.braces.close.span
			)
		elseif node.kind == "function" then
			return merge(
				node.parens.open.span,
				span_return_type(node.ret)
			)
		elseif node.kind == "paren" then
			return merge(
				node.parens.open.span,
				node.parens.close.span
			)
		elseif node.kind == "optional" then
			return merge(
				span_type(node.type),
				node.question.span
			)
		elseif node.kind == "union" or node.kind == "intersection" then
			local leading = node.leading
			local last = node.types[(#node.types :: any) :: number]

			return merge(
				if leading then leading.span else span_type(node.types[1].node),
				span_type(last.node)
			) :: Span
		else
			error("unreachable")
		end
	end

	function span_type_pack(node: AstTypePack): Span
		if node.kind == "variadic" then
			return merge(
				node.dots.span,
				span_type(node.type)
			)
		elseif node.kind == "generic" then
			return merge(
				node.name.span,
				node.dots.span
			)
		elseif node.kind == "list" then
			local parens = node.parens
			return merge(
				parens.open.span,
				parens.close.span
			)
		else
			error("unreachable")
		end
	end

	function span_return_type(node: AstReturnType): Span
		if
			node.kind == "variadic"
			or node.kind == "generic"
			or node.kind == "list"
		then
			return span_type_pack(node)
		else
			return span_type(node)
		end
	end

	function span_binding(node: AstBinding): Span
		local type = node.type
		if type then
			return merge(
				node.name.span,
				span_type(type.type)
			)
		else
			return node.name.span
		end
	end

	function span_istring(node: AstIString): Span
		if node.kind == "simple" then
			return node.tok.span
		elseif node.kind == "complex" then
			local first = node.first
			local last = node.last

			return merge(
				first.span,
				last.span
			)
		else
			error("unreachable")
		end
	end

	function span_if_else_expr_branch(node: AstIfElseExprBranch): Span
		return merge(
			span_expr(node.condition),
			span_expr(node.body)
		)
	end

	function span_expr(node: AstExpr): Span
		if
			node.kind == "nil"
			or node.kind == "boolean"
			or node.kind == "number"
			or node.kind == "string"
			or node.kind == "varargs"
		then
			return node.tok.span
		elseif node.kind == "istring" then
			return span_istring(node.istring)
		elseif node.kind == "table" then
			return span_table(node.table)
		elseif node.kind == "function" then
			local attribute = node.attributes[1]

			if attribute then
				return merge(
					attribute.span,
					span_function_body(node.body)
				)
			else
				return merge(
					node.function_tok.span,
					span_function_body(node.body)
				)
			end
		elseif node.kind == "ifelse" then
			return merge(
				node.if_tok.span,
				span_expr(node.else_body)
			)
		elseif node.kind == "var" then
			return span_var(node.var)
		elseif node.kind == "assertion" then
			return merge(
				span_expr(node.expr),
				span_type(node.type)
			)
		elseif node.kind == "unary" then
			return merge(
				node.operator.span,
				span_expr(node.expr)
			)
		elseif node.kind == "binary" then
			return merge(
				span_expr(node.left),
				span_expr(node.right)
			)
		else
			error("unreachable")
		end
	end

	function span_function_arg(node: AstFunctionArg): Span
		if node.kind == "pack" then
			local parens = node.parens
			return merge(
				parens.open.span,
				parens.close.span
			)
		elseif node.kind == "table" then
			return span_table(node.table)
		elseif node.kind == "string" then
			return node.tok.span
		else
			error("unreachable")
		end
	end

	function span_var_root(node: AstVarRoot): Span
		if node.kind == "name" then
			return node.tok.span
		elseif node.kind == "paren" then
			return merge(
				node.parens.open.span,
				node.parens.close.span
			)
		else
			error("unreachable")
		end
	end

	function span_var_suffix(node: AstVarSuffix): Span
		if node.kind == "nameindex" then
			return merge(
				node.dot.span,
				node.name.span
			)
		elseif node.kind == "exprindex" then
			local bracks = node.bracks
			return merge(
				bracks.open.span,
				bracks.close.span
			)
		elseif node.kind == "call" then
			local method = node.method
			local arg = node.arg

			if method then
				return merge(
					method.colon.span,
					span_function_arg(arg)
				)
			else
				return span_function_arg(arg)
			end
		else
			error("unreachable")
		end
	end

	function span_var(node: AstVar): Span
		local root = node.root
		local last = node.suffixes[(#node.suffixes :: any) :: number]

		if last then
			return merge(
				span_var_root(root),
				span_var_suffix(last)
			)
		else
			return span_var_root(root)
		end
	end

	function span_table_field(node: AstTableField): Span
		if node.kind == "namekey" then
			return merge(
				node.name.span,
				span_expr(node.value)
			)
		elseif node.kind == "exprkey" then
			local bracks = node.bracks
			return merge(
				bracks.open.span,
				span_expr(node.value)
			)
		elseif node.kind == "nokey" then
			return span_expr(node.value)
		else
			error("unreachable")
		end
	end

	function span_table(node: AstTable): Span
		local braces = node.braces
		return merge(
			braces.open.span,
			braces.close.span
		)
	end

	function span_function_body(node: AstFunctionBody): Span
		local generics = node.generics

		if generics then
			return merge(
				generics.angles.open.span,
				node.end_tok.span
			)
		else
			return merge(
				node.parens.open.span,
				node.end_tok.span
			)
		end
	end

	function span_if_stat_branch(node: AstIfStatBranch): Span
		local block = node.block

		if (#block.stats :: any) == 0 then
			return merge(
				span_expr(node.condition),
				node.then_tok.span
			)
		else
			return merge(
				span_expr(node.condition),
				span_block(block)
			)
		end
	end

	function span_stat(node: AstStat): Span
		if node.kind == "assign" then
			local first = node.left[1]
			local last = node.right[(#node.right :: any) :: number]

			return merge(
				span_var(first.node),
				span_expr(last.node)
			)
		elseif node.kind == "compoundassign" then
			return merge(
				span_var(node.left),
				span_expr(node.right)
			)
		elseif node.kind == "call" then
			return span_var(node.call)
		elseif node.kind == "do" then
			return merge(
				node.do_tok.span,
				node.end_tok.span
			)
		elseif node.kind == "while" then
			return merge(
				node.while_tok.span,
				node.end_tok.span
			)
		elseif node.kind == "repeat" then
			return merge(
				node.repeat_tok.span,
				span_expr(node.condition)
			)
		elseif node.kind == "if" then
			return merge(
				node.if_tok.span,
				node.end_tok.span
			)
		elseif node.kind == "numericfor" or node.kind == "forin" then
			return merge(
				node.for_tok.span,
				node.end_tok.span
			)
		elseif node.kind == "function" then
			local attribute = node.attributes[1]

			if attribute then
				return merge(
					attribute.span,
					span_function_body(node.body)
				)
			else
				return merge(
					node.function_tok.span,
					span_function_body(node.body)
				)
			end
		elseif node.kind == "localfunction" then
			local attribute = node.attributes[1]

			if attribute then
				return merge(
					attribute.span,
					span_function_body(node.body)
				)
			else
				return merge(
					node.local_tok.span,
					span_function_body(node.body)
				)
			end
		elseif node.kind == "localvariable" then
			local values = node.values

			if values then
				local exprs = values.exprs
				local last = exprs[(#exprs :: any) :: number]

				return merge(
					node.local_tok.span,
					span_expr(last.node)
				)
			else
				local bindings = node.bindings
				local last = bindings[(#bindings :: any) :: number]

				return merge(
					node.local_tok.span,
					span_binding(last.node)
				)
			end
		elseif node.kind == "type" then
			local export_tok = node.export_tok

			if export_tok then
				return merge(
					export_tok.span,
					span_type(node.type)
				)
			else
				return merge(
					node.type_tok.span,
					span_type(node.type)
				)
			end
		else
			error("unreachable")
		end
	end

	function span_laststat(node: AstLastStat): Span
		if node.kind == "return" then
			local exprs = node.exprs
			local last = exprs[(#exprs :: any) :: number]

			return merge(
				node.return_tok.span,
				span_expr(last.node)
			)
		elseif node.kind == "break" or node.kind == "continue" then
			return node.tok.span
		else
			error("unreachable")
		end
	end

	function span_block(node: AstBlock): Span
		local stats = node.stats
		local first = stats[1]
		local laststat = node.laststat

		if first == nil and laststat == nil then
			error("attempt to get the span of an empty block")
		end

		if first == nil and laststat ~= nil then
			local semicolon = laststat.semicolon

			if semicolon then
				return merge(
					span_laststat(laststat.stat),
					semicolon.span
				)
			else
				return span_laststat(laststat.stat)
			end
		elseif laststat ~= nil then
			local semicolon = laststat.semicolon

			if semicolon then
				return merge(
					span_stat(first.node),
					semicolon.span
				)
			else
				return merge(
					span_stat(first.node),
					span_laststat(laststat.stat)
				)
			end
		else
			local last = stats[(#stats :: any) :: number]
			local sep = last.sep

			if sep then
				return merge(
					span_stat(first.node),
					sep.span
				)
			else
				return merge(
					span_stat(first.node),
					span_stat(last.node)
				)
			end
		end
	end

	ast.span = {
		generic_declaration = span_generic_declaration,
		generic_declaration_with_defaults = span_generic_declaration_with_defaults,
		type_arg = span_type_arg,
		table_type_field = span_table_type_field,
		tail_type = span_tail_type,
		type = span_type,
		type_pack = span_type_pack,
		return_type = span_return_type,
		binding = span_binding,
		istring = span_istring,
		if_else_expr_branch = span_if_else_expr_branch,
		expr = span_expr,
		function_arg = span_function_arg,
		var_root = span_var_root,
		var_suffix = span_var_suffix,
		var = span_var,
		table_field = span_table_field,
		table = span_table,
		function_body = span_function_body,
		if_stat_branch = span_if_stat_branch,
		stat = span_stat,
		laststat = span_laststat,
		block = span_block,
	}
end

export type ParseError = {
	message: string,
	span: Span,
}

local tokens: (text: string) -> { Token }

do
	local load: (text: string) -> ()
	local next_token: () -> Token

	local line: number

	local current_token: Token
	local current_kind: typeof((({} :: any) :: Token).kind)
	local lookahead_token: Token
	local lookahead_kind: typeof((({} :: any) :: Token).kind)

	do
		local buf: buffer
		local pos: number
		local len: number

		local brace_count: number
		local brace_stack: { number } = {}

		local function char(c: string)
			return (string.byte(c))
		end

		local function peek()
			if pos == len then
				return 0
			else
				return buffer.readu8(buf, pos)
			end
		end

		local function bump()
			if pos ~= len then
				pos += 1
			end
		end

		local function bump_any()
			if peek() == char("\n") then
				line += 1
			end

			bump()
		end

		local function bump_peek()
			bump()
			return peek()
		end

		local function bump_any_peek()
			bump_any()
			return peek()
		end

		local function is_whitespace(c: number): boolean
			return c == char(" ") or c == char("\t") or c == char("\n") or c == char("\r")
		end

		local function is_digit(c: number): boolean
			return char("0") <= c and c <= char("9")
		end

		local function is_alpha(c: number): boolean
			return (char("a") <= c and c <= char("z")) or (char("A") <= c and c <= char("Z"))
		end

		local function number(): "number" | "error"
			local start = pos
			local base = 10

			local c: number = peek()

			if c == char("0") then
				c = bump_peek()

				if c == char("x") or c == char("X") then
					c = bump_peek()
					base = 16
				elseif c == char("b") or c == char("B") then
					c = bump_peek()
					base = 2
				end
			end

			while is_digit(c) or c == char(".") or c == char("_") do
				c = bump_peek()
			end

			if c == char("e") or c == char("E") then
				c = bump_peek()

				if c == char("+") or c == char("-") then
					c = bump_peek()
				end
			end

			while is_digit(c) or is_alpha(c :: any) or c == char("_") do
				c = bump_peek()
			end

			local text: string
			if base == 10 then
				text = buffer.readstring(buf, start, pos - start) :: string
			else
				text = buffer.readstring(buf, start + 2, pos - start - 2) :: string
			end

			if tonumber(text, base) then
				return "number"
			else
				return "error"
			end
		end
		
		local function string_backslash()
			local c = peek()

			if c == char("\r") then
				c = bump_peek()

				if c == char("\n") then
					bump()
					line += 1
				end
			elseif c == char("z") then
				bump()

				while is_whitespace(peek()) do
					bump_any()
				end
			else
				bump_any()
			end
		end

		local function quoted_string(): "string" | "error"
			local delim = peek()
			local c = bump_peek()

			while c ~= delim do
				if c == 0 or c == char("\n") or c == char("\r") then
					return "error"
				elseif c == char("\\") then
					bump()
					string_backslash()
				else
					bump()
				end

				c = peek()
			end

			bump()
			return "string"
		end

		local function long_seperator(): number
			local count = 0

			while peek() == char("=") do
				bump()
				count += 1
			end
			
			return count
		end

		local function long_string(eqs: number): "string" | "error"
			bump()

			while true do
				local c = peek()

				if c == char("]") then
					bump()

					if long_seperator() == eqs and peek() == char("]") then
						bump()
						return "string"
					end
				elseif c == 0 then
					return "error"
				else
					bump_any()
				end
			end
		end

		local function istring_section(
			from: "start" | "middle"
		): "istring_simple" | "istring_first" | "istring_middle" | "istring_last" | "error"
			local c = peek()

			while c ~= char("`") do
				if c == 0 or c == char("\n") or c == char("\r") then
					print("a")
					return "error"
				elseif c == char("\\") then
					bump()

					if peek() == char("u") then
						bump()

						if peek() == char("{") then
							bump()
						end
					else
						string_backslash()
					end
				elseif c == char("{") then
					bump()

					if peek() == char("{") then
						bump()
						return "error"
					else
						table.insert(brace_stack, brace_count)

						if from == "start" then
							return "istring_first"
						else
							return "istring_middle"
						end
					end
				else
					bump()
				end

				c = peek()
			end

			bump()

			if from == "start" then
				return "istring_simple"
			else
				return "istring_last"
			end
		end

		local function comment(): "comment" | "error"
			local c = peek()

			if c == char("[") then
				bump()
				local eqs = long_seperator()

				if peek() == char("[") then
					local result = long_string(eqs)

					if result == "error" then
						return "error"
					else
						return "comment"
					end
				end
			end

			while c ~= 0 and c ~= char("\n") and c ~= char("\r") do
				c = bump_peek()
			end

			return "comment"
		end

		local function next_kind(): typeof((({} :: any) :: Token | Trivia).kind)
			local c = peek()

			if c == 0 then
				return "eof"
			elseif is_whitespace(c) then
				repeat
					bump_any()
				until not is_whitespace(peek())

				return "whitespace"
			elseif is_alpha(c :: any) or c == char("_") then
				local start = pos
				local first = c

				repeat
					c = bump_peek()
				until not (is_alpha(c :: any) or is_digit(c :: any) or c == char("_"))

				if first == char("l") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "local" then text else "ident"
				elseif first == char("e") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "end" or text == "elseif" or text == "else" then text else "ident"
				elseif first == char("t") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "then" or text == "true" then text else "ident"
				elseif first == char("r") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "return" or text == "repeat" then text else "ident"
				elseif first == char("f") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "function" or text == "for" or text == "false" then text else "ident"
				elseif first == char("i") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "if" or text == "in" then text else "ident"
				elseif first == char("d") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "do" then text else "ident"
				elseif first == char("n") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "nil" or text == "not" then text else "ident"
				elseif first == char("o") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "or" then text else "ident"
				elseif first == char("a") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "and" then text else "ident"
				elseif first == char("b") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "break" then text else "ident"
				elseif first == char("w") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "while" then text else "ident"
				elseif first == char("u") then
					local text = buffer.readstring(buf, start, pos - start) :: string
					return if text == "until" then text else "ident"
				else
					return "ident"
				end
			elseif is_digit(c :: number) then
				return if number() then "number" else "error"
			elseif c == char("'") or c == char('"') then
				return quoted_string()
			elseif c == char("`") then
				bump()
				return istring_section("start")
			elseif c == char("{") then
				brace_count += 1
				bump()
				return "{"
			elseif c == char("}") then
				if #brace_stack ~= 0 and brace_stack[#brace_stack] == brace_count then
					table.remove(brace_stack)
					return istring_section("middle")
				else
					brace_count -= 1
					bump()
					return "}"
				end
			elseif c == char("[") then
				bump()

				local eqs = long_seperator()
				
				if peek() == char("[") then
					return long_string(eqs)
				elseif eqs > 0 then
					return "error"
				else
					return "["
				end
			elseif c == char("-") then
				c = bump_peek()

				if c == char(">") then
					bump()
					return "->"
				elseif c == char("=") then
					bump()
					return "-="
				elseif c == char("-") then
					bump()
					return comment()
				else
					return "-"
				end
			end

			bump()

			if c == char(",") then
				return ","
			elseif c == char("(") then
				return "("
			elseif c == char(")") then
				return ")"
			elseif c == char("=") then
				c = peek()

				if c == char("=") then
					bump()
					return "=="
				else
					return "="
				end
			elseif c == char(".") then
				c = peek()

				if c == char(".") then
					c = bump_peek()

					if c == char(".") then
						bump()
						return "..."
					elseif c == char("=") then
						bump()
						return "..="
					else
						return ".."
					end
				elseif is_digit(c) then
					pos -= 1
					return number()
				else
					return "."
				end
			elseif c == char(":") then
				c = peek()

				if c == char(":") then
					bump()
					return "::"
				else
					return ":"
				end
			elseif c == char(">") then
				c = peek()

				if c == char("=") then
					bump()
					return ">="
				else
					return ">"
				end
			elseif c == char("<") then
				c = peek()

				if c == char("=") then
					bump()
					return "<="
				else
					return "<"
				end
			elseif c == char("]") then
				return "]"
			elseif c == char("|") then
				return "|"
			elseif c == char("?") then
				return "?"
			elseif c == char("+") then
				c = peek()

				if c == char("=") then
					bump()
					return "+="
				else
					return "+"
				end
			elseif c == char("*") then
				c = peek()

				if c == char("=") then
					bump()
					return "*="
				else
					return "*"
				end
			elseif c == char("#") then
				return "#"
			elseif c == char("&") then
				return "&"
			elseif c == char("~") then
				c = peek()

				if c == char("=") then
					bump()
					return "~="
				else
					return "error"
				end
			elseif c == char("^") then
				c = peek()

				if c == char("=") then
					bump()
					return "^="
				else
					return "^"
				end
			elseif c == char("/") then
				c = peek()

				if c == char("/") then
					c = bump_peek()

					if c == char("=") then
						bump()
						return "//="
					else
						return "//"
					end
				elseif c == char("=") then
					bump()
					return "/="
				else
					return "/"
				end
			elseif c == char(";") then
				return ";"
			elseif c == char("%") then
				c = peek()

				if c == char("=") then
					bump()
					return "%="
				else
					return "%"
				end
			end

			return "error"
		end

		function next_token(): Token
			local trivia = {}

			while true do
				local start = pos
				local kind = next_kind()

				if kind == "whitespace" or kind == "comment" then
					table.insert(trivia, {
						kind = kind,
						text = buffer.readstring(buf, start, pos - start),
						span = { x = start, y = pos, z = 0 },
					})
				else
					if
						kind == "error"
						or kind == "ident"
						or kind == "number"
						or kind == "string"
						or kind == "istring_simple"
						or kind == "istring_first"
						or kind == "istring_middle"
						or kind == "istring_last"
						or kind == "attribute"
					then
						return {
							kind = kind,
							text = buffer.readstring(buf, start, pos - start),
							span = { x = start, y = pos, z = 0 },
							trivia = trivia,
						} :: any
					else
						return {
							kind = kind,
							span = { x = start, y = pos, z = 0 },
							trivia = trivia,
						} :: any
					end
				end
			end
		end

		function load(text: string)
			buf = buffer.fromstring(text)
			len = buffer.len(buf)
			pos = 0

			brace_count = 0
			table.clear(brace_stack)

			line = 1

			current_token = next_token()
			current_kind = current_token.kind
			lookahead_token = next_token()
			lookahead_kind = lookahead_token.kind
		end
	end

	local function consume(): Token
		local result = current_token

		current_token = lookahead_token
		current_kind = lookahead_kind
		lookahead_token = next_token()
		lookahead_kind = lookahead_token.kind
		
		return result
	end

	function tokens(input: string): { Token }
		load(input)

		local result = {}

		while current_kind ~= "eof" do
			table.insert(result, consume())
		end

		table.insert(result, current_token)

		return result
	end

	local function display(token: Token): string
		local kind = token.kind

		if 
			kind == "ident"
			or kind == "number"
			or kind == "string"
		then
			return kind
		elseif kind == "attribute" or kind == "error" then
			return "'" .. (token :: any).text .. "'"
		else
			return "'" .. kind .. "'"
		end
	end

	local function report(message: string, span: Span?): never
		local report: ParseError = {
			message = message,
			span = span or current_token.span,
		}

		print(line, debug.traceback())
		error(report)
	end

	local function expect<T>(kind: T & typeof((({} :: any) :: Token).kind)): TokenKind<T>
		if current_kind == kind :: any then
			return consume() :: any
		else
			local display_expected

			if kind == "ident" or "number" or "string" then
				display_expected = kind
			else
				display_expected = "'" .. (kind :: any) .. "'"
			end

			local display_current

			if current_kind == "ident"
				or current_kind == "number"
				or current_kind == "string"
			then
				display_current = current_kind
			elseif current_kind == "attribute" or current_kind == "error" then
				display_current = "'" .. (current_token :: any).text .. "'"
			else
				display_current = "'" .. current_kind .. "'"
			end

			return report(`expected {display_expected}, but got {display_current} instead`)
		end
	end

	local parse_type: () -> AstType
	local parse_return_type: () -> AstReturnType
	local parse_generic_declaration: () -> AstGenericDeclaration
	local parse_generic_declaration_with_defaults: () -> AstGenericDeclarationWithDefaults
	local parse_expr: () -> AstExpr
	local parse_var: () -> AstVar
	local parse_table: () -> AstTable
	local parse_block: () -> AstBlock

	do
		local parse_simple_type: (allow_list_pack: boolean) -> AstType | AstTypePack_List
		local parse_type_suffix: (type: AstType) -> AstType

		function parse_generic_declaration(): AstGenericDeclaration
			local open = expect("<")
			local names: AstSeparated<TokenKind<"ident">, TokenKind<",">> = {}
			local packs: AstSeparated<{
				read name: TokenKind<"ident">,
				read dots: TokenKind<"...">,
			}, TokenKind<",">> = {}

			while true do
				if current_kind == "ident" and lookahead_kind == "..." then
					break
				else
					local name = expect("ident")

					if current_kind == "," then
						table.insert(names, {
							node = name,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(names, {
							node = name,
							sep = nil
						})

						return {
							angles = { open = open, close = expect(">") },
							names = names,
							packs = packs,
						}
					end
				end
			end

			while true do
				local name = expect("ident")
				local dots = expect("...")

				if current_kind == "," then
					table.insert(packs, {
						node = { name = name, dots = dots },
						sep = consume() :: TokenKind<",">,
					})
				else
					table.insert(packs, {
						node = { name = name, dots = dots },
						sep = nil,
					})

					return {
						angles = { open = open, close = consume() :: TokenKind<">"> },
						names = names,
						packs = packs,
					}
				end
			end
		end

		local function parse_tail_type(): AstTailType
			if current_kind == "..." then
				local dots = consume() :: TokenKind<"...">
				local type = parse_type()
				return { kind = "variadic", dots = dots, type = type }
			elseif current_kind == "ident" and lookahead_kind == "..." then
				local name = consume() :: TokenKind<"ident">
				local dots = consume() :: TokenKind<"...">
				return { kind = "generic", name = name, dots = dots }
			else
				error("unreachable")
			end
		end

		function parse_generic_declaration_with_defaults(): AstGenericDeclarationWithDefaults
			local open = expect("<")
			local names: AstSeparated<{
				read name: TokenKind<"ident">,
				read default: {
					read equals: TokenKind<"=">,
					read type: AstType,
				}?,
			}, TokenKind<",">> = {}
			local packs: AstSeparated<{
				read name: TokenKind<"ident">,
				read dots: TokenKind<"...">,
				read default: {
					read equals: TokenKind<"=">,
					read pack: AstTypePack,
				}?,
			}, TokenKind<",">> = {}

			while true do
				if current_kind == "ident" and lookahead_kind == "..." then
					break
				else
					local name = expect("ident")
					local default: {
						read equals: TokenKind<"=">,
						read type: AstType,
					}? = nil
					
					if current_kind == "=" then
						local equals = consume() :: TokenKind<"=">
						local type = parse_type()
						default = { equals = equals, type = type }
					end

					if current_kind == "," then
						table.insert(names, {
							node = { name = name, default = default },
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(names, {
							node = { name = name, default = default },
							sep = nil
						})

						return {
							angles = { open = open, close = expect(">") },
							names = names,
							packs = packs,
						}
					end
				end
			end

			while true do
				local name = expect("ident")
				local dots = expect("...")
				local default: {
					read equals: TokenKind<"=">,
					read pack: AstTypePack,
				}? = nil

				if current_kind == "=" then
					local equals = consume() :: TokenKind<"=">
					local pack: AstTypePack

					if
						current_kind == "..."
						or (current_kind == "ident" and lookahead_kind == "...")
					then
						pack = parse_tail_type()
					elseif current_kind == "(" then
						local maybe_pack = parse_simple_type(true)

						if maybe_pack.kind == "list" then
							pack = maybe_pack
						elseif maybe_pack.kind == "function" then
							report("expected type pack after '=', found function type", ast.span.type(maybe_pack))
						else
							error("unreachable")
						end
					else
						report(`expected type pack after '=', found {display(current_token)}`)
					end

					default = { equals = equals, pack = pack }
				end

				if current_kind == "," then
					table.insert(packs, {
						node = { name = name, dots = dots, default = default },
						sep = consume() :: TokenKind<",">,
					})
				else
					table.insert(packs, {
						node = { name = name, dots = dots, default = default },
						sep = nil,
					})

					return {
						angles = { open = open, close = expect(">") },
						names = names,
						packs = packs,
					}
				end
			end
		end

		local function parse_function_type_params(): (AstSeparated<{
			read name: {
				read name: TokenKind<"ident">,
				read colon: TokenKind<":">,
			}?,

			read type: AstType,
		}, TokenKind<",">>, AstTailType?)
			local params: AstSeparated<{
				read name: {
					read name: TokenKind<"ident">,
					read colon: TokenKind<":">,
				}?,

				read type: AstType,
			}, TokenKind<",">> = {}

			while true do
				if
					current_kind == "..."
					or (current_kind == "ident" and lookahead_kind == "...")
				then
					local pack = parse_tail_type()
					return params, pack
				end

				local name: {
					read name: TokenKind<"ident">,
					read colon: TokenKind<":">,
				}? = nil

				if current_kind == "ident" and lookahead_kind == ":" then
					name = {
						name = consume() :: TokenKind<"ident">,
						colon = consume() :: TokenKind<":">,
					}
				end

				local type = parse_type()

				if current_kind == "," then
					table.insert(params, {
						node = { name = name, type = type },
						sep = consume() :: TokenKind<",">,
					})
				else
					table.insert(params, {
						node = { name = name, type = type },
						sep = nil,
					})

					return params, nil
				end
			end
		end

		function parse_simple_type(allow_list_pack: boolean): AstType | AstTypePack_List
			if current_kind == "nil" then
				return { kind = "nil", tok = consume() :: TokenKind<"nil"> }
			elseif current_kind == "true" or current_kind == "false" then
				return { kind = "boolean", tok = consume() :: TokenKind<"true"> }
			elseif current_kind == "string" then
				return { kind = "string", tok = consume() :: TokenKind<"string"> }
			elseif current_kind == "ident" then
				if (current_token :: TokenKind<"ident">).text == "typeof" then
					local typeof_tok = consume() :: TokenKind<"ident">
					local open = expect("(")
					local expr = parse_expr()
					local close = expect(")")

					return {
						kind = "typeof",
						typeof_tok = typeof_tok,
						parens = { open = open, close = close },
						expr = expr,
					}
				else
					local name = consume() :: TokenKind<"ident">
					local prefix: {
						read name: TokenKind<"ident">,
						read dot: TokenKind<".">,
					}? = nil

					if current_kind == "." then
						prefix = { name = name, dot = consume() :: TokenKind<"."> }
						name = expect("ident")
					elseif current_kind == "..." then
						local message = "unexpected '...' after type name; type pack is not allowed in this context"
						report(message)
					end

					if current_kind == "<" then
						local open = consume() :: TokenKind<"<">
						local generics: AstSeparated<AstTypeArg, TokenKind<",">> = {}

						if current_kind == ">" then
							return {
								kind = "reference",
								prefix = prefix,
								name = name,
								generics = {
									angles = { open = open, close = consume() :: TokenKind<">"> },
									types = generics
								},
							}
						else
							while true do
								local generic: AstTypeArg

								if
									current_kind == "..."
									or (current_kind == "ident" and lookahead_kind == "...")
								then
									generic = parse_tail_type()
								elseif current_kind == "(" then
									local type = parse_simple_type(true)

									if type.kind == "list" then
										generic = type
									else
										generic = parse_type_suffix(type)
									end
								else
									generic = parse_type()
								end

								if current_kind == "," then
									table.insert(generics, {
										node = generic,
										sep = consume() :: TokenKind<",">,
									})
								else
									table.insert(generics, {
										node = generic,
										sep = nil,
									})

									return {
										kind = "reference",
										prefix = prefix,
										name = name,
										generics = {
											angles = { open = open, close = expect(">") },
											types = generics
										},
									}
								end
							end
						end
					else
						return {
							kind = "reference",
							prefix = prefix,
							name = name,
							generics = nil,
						}
					end
				end
			elseif current_kind == "{" then
				local open = consume() :: TokenKind<"{">
				local had_indexer = false
				local fields: AstSeparated<AstTableTypeField, TokenKind<","> | TokenKind<";">> = {}

				while current_kind ~= "}" do
					local access: TokenKind<"ident">? = nil
					local field: AstTableTypeField

					if current_kind == "ident" and lookahead_kind ~= ":" then
						local text = (current_token :: TokenKind<"ident">).text

						if text == "read" or text == "write" then
							access = consume() :: TokenKind<"ident">
						end
					end

					if current_kind == "[" then
						if lookahead_kind == "string" then
							local open = consume() :: TokenKind<"[">
							local key = consume() :: TokenKind<"string">
							local close = expect("]")
							local colon = expect(":")
							local type = parse_type()
	
							field = {
								kind = "stringprop" :: "stringprop",
								access = access,
								bracks = { open = open, close = close },
								key = key,
								colon = colon,
								type = type,
							}
						else
							local open = consume() :: TokenKind<"[">
							local key = parse_type()
							local close = expect("]")
							local colon = expect(":")
							local type = parse_type()

							field = {
								kind = "indexer" :: "indexer",
								access = access,
								bracks = { open = open, close = close },
								key = key,
								colon = colon,
								type = type,
							}

							if had_indexer then
								report("table types cannot have more than one indexer", ast.span.table_type_field(field))
							else
								had_indexer = true
							end
						end
					elseif current_kind == "ident" and lookahead_kind == ":" then
						local name = consume() :: TokenKind<"ident">
						local colon = consume() :: TokenKind<":">
						local type = parse_type()

						field = {
							kind = "nameprop" :: "nameprop",
							access = access,
							name = name,
							colon = colon,
							type = type,
						}
					elseif #fields == 0 then
						local type = parse_type()
						local close = expect("}")

						if access ~= nil then
							report(`'{access.text}' keyword is illegal in this position`, access.span)
						end

						return {
							kind = "array",
							braces = { open = open, close = close },
							type = type,
						}
					end

					if current_kind == "," or current_kind == ";" then
						table.insert(fields, {
							node = field,
							sep = consume() :: TokenKind<","> | TokenKind<";">,
						})
					else
						table.insert(fields, {
							node = field,
							sep = nil,
						})

						break
					end
				end

				local close = expect("}")

				return {
					kind = "table",
					braces = { open = open, close = close },
					fields = fields,
				}
			elseif current_kind == "(" or current_kind == "<" then
				local force_function_type = current_kind == "<"
				local generics: AstGenericDeclaration? = (
					if force_function_type then parse_generic_declaration()
					else nil
				)

				local open = expect("(")
				local params: AstSeparated<{
					read name: {
						read name: TokenKind<"ident">,
						read colon: TokenKind<":">,
					}?,

					read type: AstType,
				}, TokenKind<",">>, tail: AstTailType?

				if current_kind ~= ")" then
					params, tail = parse_function_type_params()
				else
					params = {}
				end

				local close = expect(")")

				if not force_function_type then
					for _, pair in params do
						if pair.node.name ~= nil then
							force_function_type = true
							break
						end
					end
				end

				local return_type_introducer = current_kind == "->"

				if not force_function_type and not return_type_introducer then
					if allow_list_pack then
						local types: AstSeparated<AstType, TokenKind<",">> = {}

						for _, pair in params do
							table.insert(types, {
								node = pair.node.type,
								sep = pair.sep,
							})
						end

						return {
							kind = "list",
							parens = { open = open, close = close },
							types = types,
						}
					elseif ((#params :: any) :: number) == 1 and tail == nil then
						return {
							kind = "paren",
							parens = { open = open, close = close },
							type = params[1].node.type,
						}
					end
				end

				local arrow = expect("->")
				local ret = parse_return_type()

				return {
					kind = "function",
					generics = generics,
					parens = { open = open, close = close },
					params = params,
					varargs = tail,
					arrow = arrow,
					ret = ret,
				}
			else
				return report(`expected type, but got {display(current_token)}`)
			end
		end

		function parse_type_suffix(current_type: AstType?): AstType
			local types: AstSeparated<AstType, TokenKind<"|"> | TokenKind<"&">> = {}
			local leading = if current_type then nil else consume()
			local is_union, is_intersection = false, false

			if leading then
				if leading.kind == "|" then
					is_union = true
				elseif leading.kind == "&" then
					is_intersection = true
				else
					error("unreachable")
				end
			end

			while true do
				local type: AstType

				if current_type then
					type = current_type
					current_type = nil
				else
					type = parse_simple_type(false) :: AstType
				end

				if current_kind == "?" then
					if is_intersection then
						report("optional types cannot be used in intersections")
					else
						local question = consume() :: TokenKind<"?">
						current_type = { kind = "optional", type = type, question = question }
						is_union = true
					end
				elseif current_kind == "|" then
					if is_intersection then
						report("unions and intersections cannot be mixed")
					else
						local pipe = consume() :: TokenKind<"|">
						table.insert(types, { node = type, sep = pipe })
						is_union = true
					end
				elseif current_kind == "&" then
					if is_union then
						report("unions and intersections cannot be mixed")
					else
						local amp = consume() :: TokenKind<"&">
						table.insert(types, { node = type, sep = amp })
						is_intersection = true
					end
				elseif #types == 0 and leading == nil then
					return type
				else
					table.insert(types, { node = type, sep = nil })
					break
				end
			end

			if is_union then
				return {
					kind = "union",
					leading = leading :: TokenKind<"|">,
					types = types :: AstSeparated<AstType, TokenKind<"|">>,
				}
			elseif is_intersection then
				return {
					kind = "intersection",
					leading = leading :: TokenKind<"&">,
					types = types :: AstSeparated<AstType, TokenKind<"&">>,
				}
			else
				error("unreachable")
			end
		end

		function parse_type(): AstType
			local type: AstType? = nil

			if current_kind ~= "|" and current_kind ~= "&" then
				type = parse_simple_type(false) :: AstType
			end

			return parse_type_suffix(type)
		end

		function parse_return_type(): AstReturnType
			if current_kind ~= "(" then
				if
					current_kind == "..."
					or (current_kind == "ident" and lookahead_kind == "...")
				then
					return parse_tail_type()
				else
					return parse_type()
				end
			end

			local open = consume() :: TokenKind<"(">
			local params: AstSeparated<{
				read name: {
					read name: TokenKind<"ident">,
					read colon: TokenKind<":">,
				}?,

				read type: AstType,
			}, TokenKind<",">>, tail: AstTailType?

			if current_kind ~= ")" then
				params, tail = parse_function_type_params()
			else
				params = {}
			end

			local close = expect(")")

			local has_named_param = false
			for _, pair in params do
				if pair.node.name ~= nil then
					has_named_param = true
					break
				end
			end

			if current_kind ~= "->" and not has_named_param then
				if ((#params :: any) :: number) == 1 and tail == nil then
					local paren_type = {
						kind = "paren",
						parens = { open = open, close = close },
						type = params[1].node.type,
					}

					return parse_type_suffix(paren_type)
				else
					local types: AstSeparated<AstType, TokenKind<",">> = {}

					for _, pair in params do
						table.insert(types, {
							node = pair.node.type,
							sep = pair.sep,
						})
					end

					return {
						kind = "list",
						parens = { open = open, close = close },
						types = types,
					}
				end
			else
				local arrow = expect("->")
				local ret = parse_return_type()

				return {
					kind = "function",
					generics = nil,
					parens = { open = open, close = close },
					params = params,
					varargs = tail,
					arrow = arrow,
					ret = ret,
				}
			end
		end
	end

	local function parse_binding(): AstBinding
		local name = expect("ident")

		if current_kind == ":" then
			local colon = consume() :: TokenKind<":">
			local type = parse_type()
			
			return { name = name, type = { colon = colon, type = type } }
		else
			return { name = name, type = nil }
		end
	end

	local function parse_function_body(): AstFunctionBody
		local generics: AstGenericDeclaration? = nil

		if current_kind == "<" then
			generics = parse_generic_declaration()
		end

		local open = expect("(")
		local params: AstSeparated<AstBinding, TokenKind<",">> = {}
		local varargs: {
			read dots: TokenKind<"...">,
			
			read type: {
				read colon: TokenKind<":">,
				read type: AstType | AstTypePack_Generic,
			}?,
		}? = nil

		if current_kind ~= ")" then
			while true do
				if current_kind == "ident" then
					local binding = parse_binding()

					if current_kind == "," then
						table.insert(params, {
							node = binding,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(params, {
							node = binding,
							sep = nil,
						})

						break
					end
				elseif current_kind == "..." then
					local dots = consume() :: TokenKind<"...">

					if current_kind == ":" then
						local colon = consume() :: TokenKind<":">
						local type: AstType | AstTypePack_Generic

						if current_kind == "ident" and lookahead_kind == "..." then
							type = {
								kind = "generic",
								name = consume() :: TokenKind<"ident">,
								dots = consume() :: TokenKind<"...">,
							}
						else
							type = parse_type()
						end

						varargs = { dots = dots, type = { colon = colon, type = type } }
					else
						varargs = { dots = dots, type = nil }
					end

					break
				else
					report(`expected binding, but got {display(current_token)}`)
				end
			end
		end

		local close = expect(")")
		local ret: { read colon: TokenKind<":">, read type: AstReturnType }? = nil

		if current_kind == ":" then
			local colon = consume() :: TokenKind<":">
			local type = parse_return_type()

			ret = { colon = colon, type = type }
		end

		local block = parse_block()
		local end_tok = expect("end")

		return {
			generics = generics,
			parens = { open = open, close = close },
			params = params,
			varargs = varargs,
			ret = ret,
			block = block,
			end_tok = end_tok,
		}
	end

	do
		local function parse_simple_expr(): AstExpr
			if current_kind == "nil" then
				return { kind = "nil", tok = consume() :: TokenKind<"nil"> }
			elseif current_kind == "true" or current_kind == "false" then
				return { kind = "boolean", tok = consume() :: TokenKind<"true"> | TokenKind<"false"> }
			elseif current_kind == "number" then
				return { kind = "number", tok = consume() :: TokenKind<"number"> }
			elseif current_kind == "string" then
				return { kind = "string", tok = consume() :: TokenKind<"string"> }
			elseif current_kind == "..." then
				return { kind = "varargs", tok = consume() :: TokenKind<"..."> }
			elseif current_kind == "istring_simple" then
				return {
					kind = "istring",
					istring = {
						kind = "simple",
						tok = consume() :: TokenKind<"istring_simple">,
					},
				}
			elseif current_kind == "istring_first" then
				local first = consume() :: TokenKind<"istring_first">
				local middle: AstSeparated<AstExpr, TokenKind<"istring_middle">> = {}

				while true do
					local expr = parse_expr()

					if current_kind == "istring_middle" then
						table.insert(middle, {
							node = expr,
							sep = consume() :: TokenKind<"istring_middle">,
						})
					else
						table.insert(middle, {
							node = expr,
							sep = nil,
						})

						break
					end
				end

				local last = expect("istring_last")

				return {
					kind = "istring",
					istring = {
						kind = "complex",
						first = first,
						middle = middle,
						last = last,
					}
				}
			elseif current_kind == "{" then
				return { kind = "table", table = parse_table() }
			elseif current_kind == "function" or current_kind == "attribute" then
				local attributes: { TokenKind<"attribute"> } = {}

				while current_kind == "attribute" do
					table.insert(attributes, consume() :: TokenKind<"attribute">)
				end

				local function_tok = expect("function")
				local body = parse_function_body()

				return {
					kind = "function",
					attributes = attributes,
					function_tok = function_tok,
					body = body,
				}
			elseif current_kind == "if" then
				local if_tok = consume() :: TokenKind<"if">
				local branches: AstSeparated<AstIfElseExprBranch, TokenKind<"elseif">> = {}
			
				while true do
					local condition = parse_expr()
					local then_tok = expect("then")
					local body = parse_expr()

					if current_kind == "elseif" then
						table.insert(branches, {
							node = {
								condition = condition,
								then_tok = then_tok,
								body = body,
							},
							sep = consume() :: TokenKind<"elseif">,
						})
					else
						table.insert(branches, {
							node = {
								condition = condition,
								then_tok = then_tok,
								body = body,
							},
							sep = nil,
						})

						break
					end
				end

				local else_tok = expect("else")
				local else_body = parse_expr()

				return {
					kind = "ifelse",
					if_tok = if_tok,
					branches = branches,
					else_tok = else_tok,
					else_body = else_body,
				}
			else
				return { kind = "var", var = parse_var() }
			end
		end

		local function parse_unary_operator(): AstUnaryOperator?
			if
				current_kind == "+"
				or current_kind == "-"
				or current_kind == "#"
				or current_kind == "not"
			then
				return consume() :: AstUnaryOperator
			else
				return nil
			end
		end

		local function current_binary_operator(): AstBinaryOperator?
			if
				current_kind == "+"
				or current_kind == "-"
				or current_kind == "*"
				or current_kind == "/"
				or current_kind == "//"
				or current_kind == "%"
				or current_kind == "^"
				or current_kind == ".."
				or current_kind == "<"
				or current_kind == "<="
				or current_kind == ">"
				or current_kind == ">="
				or current_kind == "=="
				or current_kind == "~="
				or current_kind == "and"
				or current_kind == "or"
			then
				return current_token :: AstBinaryOperator
			else
				return nil
			end
		end

		local function binary_operator_priority(op: AstBinaryOperator): (number, number)
			local kind = op.kind

			if kind == "+" or kind == "-" then
				return 6, 6
			elseif kind == "*" or kind == "/" or kind == "//" or kind == "&" or kind == "%" then
				return 7, 7
			elseif kind == "^" then
				return 10, 9
			elseif kind == ".." then
				return 5, 4
			elseif kind == "==" or kind == "~=" then
				return 3, 3
			elseif kind == "<" or kind == "<=" or kind == ">" or kind == ">=" then
				return 3, 3
			elseif kind == "and" then
				return 2, 2
			elseif kind == "or" then
				return 1, 1
			else
				error("unreachable")
			end
		end

		local function parse_expr_with_limit(limit: number?): AstExpr
			limit = limit or 0

			local expr: AstExpr

			local unop = parse_unary_operator()

			if unop then
				local rhs = parse_expr_with_limit(8)

				expr = {
					kind = "unary",
					operator = unop,
					expr = rhs,
				}
			else
				expr = parse_simple_expr()

				if current_kind == "::" then
					local colon = consume() :: TokenKind<"::">
					local type = parse_type()

					expr = {
						kind = "assertion",
						expr = expr,
						colon = colon,
						type = type,
					}
				end
			end

			while true do
				local binop = current_binary_operator()

				if binop == nil then
					break
				end

				local left_priority, right_priority = binary_operator_priority(binop)

				if left_priority < limit then
					break
				end

				consume()

				local rhs = parse_expr_with_limit(right_priority)

				expr = {
					kind = "binary",
					left = expr,
					operator = binop,
					right = rhs,
				}
			end

			return expr
		end

		parse_expr = parse_expr_with_limit :: () -> AstExpr
	end

	function parse_table(): AstTable
		local open = consume() :: TokenKind<"{">
		local fields: AstSeparated<AstTableField, TokenKind<","> | TokenKind<";">> = {}

		while current_kind ~= "}" do
			local field: AstTableField

			if current_kind == "[" then
				local open = consume() :: TokenKind<"[">
				local key = parse_expr()
				local close = expect("]")
				local equals = expect("=")
				local value = parse_expr()

				field = {
					kind = "exprkey",
					bracks = { open = open, close = close },
					key = key,
					equals = equals,
					value = value,
				}
			elseif current_kind == "ident" and lookahead_kind == "=" then
				local name = consume() :: TokenKind<"ident">
				local equals = consume() :: TokenKind<"=">
				local value = parse_expr()

				field = {
					kind = "namekey",
					name = name,
					equals = equals,
					value = value,
				}
			else
				local value = parse_expr()

				field = {
					kind = "nokey",
					value = value,
				}
			end

			if current_kind == "," or current_kind == ";" then
				table.insert(fields, {
					node = field,
					sep = consume() :: TokenKind<","> | TokenKind<";">,
				})
			else
				table.insert(fields, {
					node = field,
					sep = nil,
				})

				break
			end
		end

		local close = expect("}")

		return {
			braces = { open = open, close = close },
			fields = fields,
		}
	end

	function parse_var(): AstVar
		local root: AstVarRoot

		if current_kind == "ident" then
			root = {
				kind = "name",
				tok = consume() :: TokenKind<"ident">,
			}
		elseif current_kind == "(" then
			local open = consume() :: TokenKind<"(">
			local expr = parse_expr()
			local close = expect(")")

			root = {
				kind = "paren",
				parens = { open = open, close = close },
				expr = expr,
			}
		else
			return report(`expected variable or expression, but got {display(current_token)}`)
		end

		local suffixes: { AstVarSuffix } = {}
		local last_line = line

		while true do
			if current_kind == "." then
				local dot = consume() :: TokenKind<".">
				local name = expect("ident")

				table.insert(suffixes, {
					kind = "nameindex",
					dot = dot,
					name = name,
				})
			elseif current_kind == "[" then
				local open = consume() :: TokenKind<"[">
				local expr = parse_expr()
				local close = expect("]")

				table.insert(suffixes, {
					kind = "exprindex",
					bracks = { open = open, close = close },
					expr = expr,
				})
			elseif current_kind == "(" and line ~= last_line then
				local message = "ambiguous syntax: this looks like an argument \z
					list for a function call, but could also be the start \z
					of a new statement; use ';' to separate statements"
				
				report(message)
			elseif
				current_kind == "("
				or current_kind == ":"
				or current_kind == "{"
				or current_kind == "string"
			then
				local method: {
					read colon: TokenKind<":">,
					read name: TokenKind<"ident">,
				}? = nil

				if current_kind == ":" then
					method = {
						colon = consume() :: TokenKind<":">,
						name = expect("ident"),
					}
				end

				local arg: AstFunctionArg

				if current_kind == "(" then
					local open = consume() :: TokenKind<"(">
					local exprs: AstSeparated<AstExpr, TokenKind<",">> = {}

					if current_kind ~= ")" then
						while true do
							local expr = parse_expr()

							if current_kind == "," then
								table.insert(exprs, {
									node = expr,
									sep = consume() :: TokenKind<",">,
								})
							else
								table.insert(exprs, {
									node = expr,
									sep = nil,
								})

								break
							end
						end
					end

					local close = expect(")")

					arg = {
						kind = "pack",
						parens = { open = open, close = close },
						exprs = exprs,
					}
				elseif current_kind == "{" then
					local table = parse_table()

					arg = {
						kind = "table",
						table = table,
					}
				elseif current_kind == "string" then
					arg = {
						kind = "string",
						tok = consume() :: TokenKind<"string">,
					}
				else
					report(`expected function argument, but got {display(current_token)}`)
				end

				table.insert(suffixes, {
					kind = "call",
					method = method,
					arg = arg,
				})
			else
				break
			end

			last_line = line
		end

		return {
			root = root,
			suffixes = suffixes,
		}
	end

	do
		local function parse_stat_if(): AstStat_If
			local if_tok = consume() :: TokenKind<"if">
			local branches: AstSeparated<AstIfStatBranch, TokenKind<"elseif">> = {}
		
			while true do
				local condition = parse_expr()
				local then_tok = expect("then")
				local block = parse_block()

				if current_kind == "elseif" then
					table.insert(branches, {
						node = {
							condition = condition,
							then_tok = then_tok,
							block = block,
						},
						sep = consume() :: TokenKind<"elseif">,
					})
				else
					table.insert(branches, {
						node = {
							condition = condition,
							then_tok = then_tok,
							block = block,
						},
						sep = nil,
					})

					break
				end
			end

			local else_branch: {
				read else_tok: TokenKind<"else">,
				read block: AstBlock,
			}? = nil
			
			if current_kind == "else" then
				else_branch = {
					else_tok = consume() :: TokenKind<"else">,
					block = parse_block(),
				}
			end

			local end_tok = expect("end")

			return {
				kind = "if",
				if_tok = if_tok,
				branches = branches,
				else_branch = else_branch,
				end_tok = end_tok,
			}
		end

		local function parse_stat_while(): AstStat_While
			local while_tok = consume() :: TokenKind<"while">
			local condition = parse_expr()
			local do_tok = expect("do")
			local block = parse_block()
			local end_tok = expect("end")

			return {
				kind = "while",
				while_tok = while_tok,
				condition = condition,
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		end

		local function parse_stat_do(): AstStat_Do
			local do_tok = consume() :: TokenKind<"do">
			local block = parse_block()
			local end_tok = expect("end")

			return {
				kind = "do",
				do_tok = do_tok,
				block = block,
				end_tok = end_tok,
			}
		end

		local function parse_stat_for(): AstStat_NumericFor | AstStat_ForIn
			local for_tok = consume() :: TokenKind<"for">
			local binding = parse_binding()

			if current_kind == "=" then
				local equals = consume() :: TokenKind<"=">
				local start_expr = parse_expr()
				local comma = expect(",")
				local end_expr = parse_expr()

				local step: {
					read comma: TokenKind<",">,
					read expr: AstExpr,
				}? = nil
				

				if current_kind == "," then
					local comma = consume() :: TokenKind<",">
					local expr = parse_expr()

					step = { comma = comma, expr = expr }
				end

				local do_tok = expect("do")
				local block = parse_block()
				local end_tok = expect("end")

				return {
					kind = "numericfor",
					for_tok = for_tok,
					binding = binding,
					equals = equals,
					start_expr = start_expr,
					comma = comma,
					end_expr = end_expr,
					step = step,
					do_tok = do_tok,
					block = block,
					end_tok = end_tok,
				}
			else
				local bindings: AstSeparated<AstBinding, TokenKind<",">> = {}

				while true do
					if current_kind == "," then
						table.insert(bindings, {
							node = binding,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(bindings, {
							node = binding,
							sep = nil,
						})

						break
					end

					binding = parse_binding()
				end

				local in_tok = expect("in")
				local exprs: AstSeparated<AstExpr, TokenKind<",">> = {}

				while true do
					local expr = parse_expr()

					if current_kind == "," then
						table.insert(exprs, {
							node = expr,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(exprs, {
							node = expr,
							sep = nil,
						})

						break
					end
				end

				local do_tok = expect("do")
				local block = parse_block()
				local end_tok = expect("end")

				return {
					kind = "forin",
					for_tok = for_tok,
					bindings = bindings,
					in_tok = in_tok,
					exprs = exprs,
					do_tok = do_tok,
					block = block,
					end_tok = end_tok,
				}
			end
		end

		local function parse_stat_repeat(): AstStat_Repeat
			local repeat_tok = consume() :: TokenKind<"repeat">
			local block = parse_block()
			local until_tok = expect("until")
			local condition = parse_expr()

			return {
				kind = "repeat",
				repeat_tok = repeat_tok,
				block = block,
				until_tok = until_tok,
				condition = condition,
			}
		end

		local function parse_stat_function(attributes: { TokenKind<"attribute"> }): AstStat_Function
			local function_tok = consume() :: TokenKind<"function">
			local names: AstSeparated<TokenKind<"ident">, TokenKind<".">> = {}

			while true do
				local name = expect("ident")

				if current_kind == "." then
					table.insert(names, {
						node = name,
						sep = consume() :: TokenKind<".">,
					})
				else
					table.insert(names, {
						node = name,
						sep = nil,
					})

					break
				end
			end

			local method: {
				read colon: TokenKind<":">,
				read name: TokenKind<"ident">,
			}? = nil
			
			if current_kind == ":" then
				method = {
					colon = consume() :: TokenKind<":">,
					name = expect("ident"),
				}
			end

			local body = parse_function_body()

			return {
				kind = "function",
				attributes = attributes,
				function_tok = function_tok,
				names = names,
				method = method,
				body = body,
			}
		end

		local function parse_stat_local(attributes: { TokenKind<"attribute"> }): AstStat_LocalFunction | AstStat_LocalVariable
			local local_tok = consume() :: TokenKind<"local">

			if current_kind == "function" then
				local function_tok = consume() :: TokenKind<"function">
				local name = expect("ident")
				local body = parse_function_body()

				return {
					kind = "localfunction",
					attributes = attributes,
					local_tok = local_tok,
					function_tok = function_tok,
					name = name,
					body = body,
				}
			elseif #attributes ~= 0 then
				return report(`expected 'function' after local declaration \z
					with attribute{if #attributes == 1 then "" else "s"}, but \z
					got {display(current_token)}`)
			else
				local bindings: AstSeparated<AstBinding, TokenKind<",">> = {}

				while true do
					local binding = parse_binding()

					if current_kind == "," then
						table.insert(bindings, {
							node = binding,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(bindings, {
							node = binding,
							sep = nil,
						})

						break
					end
				end

				if current_kind == "=" then
					local equals = consume() :: TokenKind<"=">
					local exprs: AstSeparated<AstExpr, TokenKind<",">> = {}

					while true do
						local expr = parse_expr()

						if current_kind == "," then
							table.insert(exprs, {
								node = expr,
								sep = consume() :: TokenKind<",">,
							})
						else
							table.insert(exprs, {
								node = expr,
								sep = nil,
							})

							break
						end
					end

					return {
						kind = "localvariable",
						local_tok = local_tok,
						bindings = bindings,
						values = {
							equals = equals,
							exprs = exprs,
						},
					}
				else
					return {
						kind = "localvariable",
						local_tok = local_tok,
						bindings = bindings,
						values = nil,
					}
				end
			end
		end

		local function is_block_end(): boolean
			return current_kind == "end" or current_kind == "else" or current_kind == "elseif" or current_kind == "until" or current_kind == "eof"
		end

		local function parse_laststat_return(): AstLastStat_Return
			local return_tok = consume() :: TokenKind<"return">
			local exprs: AstSeparated<AstExpr, TokenKind<",">> = {}

			if current_kind ~= ";" and not is_block_end() then
				while true do
					local expr = parse_expr()

					if current_kind == "," then
						table.insert(exprs, {
							node = expr,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(exprs, {
							node = expr,
							sep = nil,
						})

						break
					end
				end
			end

			return {
				kind = "return",
				return_tok = return_tok,
				exprs = exprs,
			}
		end

		local function parse_compound_operator(): AstCompoundOperator?
			if
				current_kind == "+="
				or current_kind == "-="
				or current_kind == "*="
				or current_kind == "/="
				or current_kind == "//="
				or current_kind == "%="
				or current_kind == "^="
				or current_kind == "..="
			then
				return consume() :: AstCompoundOperator
			else
				return nil
			end
		end

		local function parse_stat(): AstStat | AstLastStat
			if current_kind == "if" then
				return parse_stat_if()
			elseif current_kind == "while" then
				return parse_stat_while()
			elseif current_kind == "do" then
				return parse_stat_do()
			elseif current_kind == "for" then
				return parse_stat_for()
			elseif current_kind == "repeat" then
				return parse_stat_repeat()
			elseif current_kind == "function" then
				return parse_stat_function({})
			elseif current_kind == "local" then
				return parse_stat_local({})
			elseif current_kind == "return" then
				return parse_laststat_return()
			elseif current_kind == "break" then
				return { kind = "break", tok = consume() :: TokenKind<"break"> }
			elseif current_kind == "attribute" then
				local attributes: { TokenKind<"attribute"> } = {}

				while current_kind == "attribute" do
					table.insert(attributes, consume() :: TokenKind<"attribute">)
				end

				if current_kind == "function" then
					return parse_stat_function(attributes)
				elseif current_kind == "local" then
					return parse_stat_local(attributes)
				else
					return report(`expected 'function' or 'local function' after \z
						attribute{if #attributes == 1 then "" else "s"}, but got \z
						{display(current_token)} instead`)
				end
			end

			local var = parse_var()
			local operator = parse_compound_operator()
			local last_suffix: AstVarSuffix? = var.suffixes[(#var.suffixes :: any) :: number]

			if operator then
				return {
					kind = "compoundassign",
					left = var,
					operator = operator,
					right = parse_expr(),
				}
			elseif last_suffix and last_suffix.kind == "call" then
				return {
					kind = "call",
					call = var,
				}
			elseif current_kind == "," or current_kind == "=" then
				local left: AstSeparated<AstVar, TokenKind<",">> = {}

				while true do
					if current_kind == "," then
						table.insert(left, {
							node = var,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(left, {
							node = var,
							sep = nil,
						})

						break
					end

					var = parse_var()
				end

				local equals = expect("=")
				local right: AstSeparated<AstExpr, TokenKind<",">> = {}

				while true do
					local expr = parse_expr()

					if current_kind == "," then
						table.insert(right, {
							node = expr,
							sep = consume() :: TokenKind<",">,
						})
					else
						table.insert(right, {
							node = expr,
							sep = nil,
						})

						break
					end
				end

				return {
					kind = "assign",
					left = left,
					equals = equals,
					right = right,
				}
			elseif last_suffix == nil and var.root.kind == "name" then
				local tok = var.root.tok

				if tok.text == "export" or tok.text == "type" then
					local export_tok: TokenKind<"ident">? = if tok.text == "export" then tok else nil
					local type_tok: TokenKind<"ident">

					if export_tok then
						if current_token.kind == "ident" and current_token.text == "type" then
							type_tok = consume() :: TokenKind<"ident">
						else
							report(`expected 'type' after 'export' but got {display(current_token)}`)
						end
					else
						type_tok = tok
					end

					local name = expect("ident")
					local generics: AstGenericDeclarationWithDefaults? = nil

					if current_kind == "<" then
						generics = parse_generic_declaration_with_defaults()
					end

					local equals = expect("=")
					local type = parse_type()

					return {
						kind = "type",
						export_tok = export_tok,
						type_tok = type_tok,
						name = name,
						generics = generics,
						equals = equals,
						type = type,
					}
				elseif tok.text == "continue" then
					return {
						kind = "continue",
						tok = tok,
					}
				end
			end

			return report("incomplete statement: expected assignment or function call")
		end

		function parse_block(): AstBlock
			local stats: AstSeparated<AstStat, TokenKind<";">> = {}

			while not is_block_end() do
				local stat = parse_stat()
				local semicolon = if current_kind == ";" then consume() :: TokenKind<";"> else nil

				if stat.kind == "return" or stat.kind == "break" or stat.kind == "continue" then
					return {
						stats = stats,
						laststat = { stat = stat, semicolon = semicolon },
					}
				else
					table.insert(stats, {
						node = stat,
						sep = semicolon,
					})
				end
			end

			return {
				stats = stats,
				laststat = nil,
			}
		end
	end

	local function parse_ast(): Ast
		local block = parse_block()
		local eof = expect("eof")

		return {
			block = block,
			eof = eof,
		}
	end

	function ast.parse(input: string): { success: true, ast: Ast } | { success: false, error: ParseError }
		load(input)

		local success, result = pcall(parse_ast)

		if success then
			return { success = true, ast = result }
		else
			return { success = false, error = (result :: any) :: ParseError }
		end
	end
end

do
	local buf = buffer.create(1024)
	local pos = 0

	local function write(str: string)
		local bytes = #str

		if pos + bytes > buffer.len(buf) then
			local new_len = buffer.len(buf)

			while pos + bytes > new_len do
				new_len += new_len / 2
			end

			local new_buf = buffer.create(new_len)
			buffer.copy(new_buf, 0, buf, 0, pos)
			buf = new_buf
		end

		buffer.writestring(buf, pos, str, bytes)
		pos += bytes
	end

	local printer = visitor()

	function printer.visit_token(self, token: Token)
		for _, trivia in token.trivia do
			write(trivia.text)
		end

		local kind = token.kind

		if
			kind == "ident"
			or kind == "number"
			or kind == "string"
			or kind == "istring_simple"
			or kind == "istring_first"
			or kind == "istring_middle"
			or kind == "istring_last"
			or kind == "attribute"
		then
			write((token :: any).text)
		elseif kind ~= "eof" then
			write(token.kind)
		end
	end

	local visit = ast.visit

	function ast.print(ast: Ast): string
		pos = 0
		visit(nil, printer, ast)
		return buffer.readstring(buf, 0, pos)
	end
end

return {
	ast = ast,
	tokens = tokens,

	visitor = visitor,
}
