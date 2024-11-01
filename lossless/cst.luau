--- Stores the locational information of a token or CST node.
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
	| { kind: "whitespace", text: string, span: Span }
	--- Holds a comment. Note that the comment header (`--` or `--[[]]`) is
	--- included in the text field.
	| { kind: "comment", text: string, span: Span }

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
	| { kind: "eof", span: Span, trivia: { Trivia } }
	--- An error token, emitted when the lexer encounters an unknown character
	--- or a broken string or number.
	| { kind: "error", text: string, span: Span, trivia: { Trivia } }
	--- An identifier, such as `foo` or `bar`.
	| { kind: "ident", text: string, span: Span, trivia: { Trivia } }
	--- A number, such as `123.456` or `0xABCD`.
	| { kind: "number", text: string, span: Span, trivia: { Trivia } }
	--- A string, such as `"foo"` or `'bar'` or `[[baz]]`.
	| { kind: "string", text: string, span: Span, trivia: { Trivia } }
	--- An interpolated string with no expr segments, such as `'simple'`.
	| { kind: "istring_simple", text: string, span: Span, trivia: { Trivia } }
	--- The first segment of an interpolated string, such as `'start{`
	| { kind: "istring_first", text: string, span: Span, trivia: { Trivia } }
	--- A middle segment of an interpolated string, such as `}middle{`.
	| { kind: "istring_middle", text: string, span: Span, trivia: { Trivia } }
	--- The last segment of an interpolated string, such as `}last'`.
	| { kind: "istring_last", text: string, span: Span, trivia: { Trivia } }
	--- A function attribute, such as `@native`.
	| { kind: "attribute", text: string, span: Span, trivia: { Trivia } }
	--- The `and` keyword.
	| { kind: "and", span: Span, trivia: { Trivia } }
	--- The `break` keyword.
	| { kind: "break", span: Span, trivia: { Trivia } }
	--- The `do` keyword.
	| { kind: "do", span: Span, trivia: { Trivia } }
	--- The `else` keyword.
	| { kind: "else", span: Span, trivia: { Trivia } }
	--- The `elseif` keyword.
	| { kind: "elseif", span: Span, trivia: { Trivia } }
	--- The `end` keyword.
	| { kind: "end", span: Span, trivia: { Trivia } }
	--- The `false` keyword.
	| { kind: "false", span: Span, trivia: { Trivia } }
	--- The `for` keyword.
	| { kind: "for", span: Span, trivia: { Trivia } }
	--- The `function` keyword.
	| { kind: "function", span: Span, trivia: { Trivia } }
	--- The `if` keyword.
	| { kind: "if", span: Span, trivia: { Trivia } }
	--- The `in` keyword.
	| { kind: "in", span: Span, trivia: { Trivia } }
	--- The `local` keyword.
	| { kind: "local", span: Span, trivia: { Trivia } }
	--- The `nil` keyword.
	| { kind: "nil", span: Span, trivia: { Trivia } }
	--- The `not` keyword.
	| { kind: "not", span: Span, trivia: { Trivia } }
	--- The `or` keyword.
	| { kind: "or", span: Span, trivia: { Trivia } }
	--- The `repeat` keyword.
	| { kind: "repeat", span: Span, trivia: { Trivia } }
	--- The `return` keyword.
	| { kind: "return", span: Span, trivia: { Trivia } }
	--- The `then` keyword.
	| { kind: "then", span: Span, trivia: { Trivia } }
	--- The `true` keyword.
	| { kind: "true", span: Span, trivia: { Trivia } }
	--- The `until` keyword.
	| { kind: "until", span: Span, trivia: { Trivia } }
	--- The `while` keyword.
	| { kind: "while", span: Span, trivia: { Trivia } }
	--- The `+=` symbol.
	| { kind: "+=", span: Span, trivia: { Trivia } }
	--- The `-=` symbol.
	| { kind: "-=", span: Span, trivia: { Trivia } }
	--- The `*=` symbol.
	| { kind: "*=", span: Span, trivia: { Trivia } }
	--- The `/=` symbol.
	| { kind: "/=", span: Span, trivia: { Trivia } }
	--- The `//=` symbol.
	| { kind: "//=", span: Span, trivia: { Trivia } }
	--- The `%=` symbol.
	| { kind: "%=", span: Span, trivia: { Trivia } }
	--- The `^=` symbol.
	| { kind: "^=", span: Span, trivia: { Trivia } }
	--- The `..=` symbol.
	| { kind: "..=", span: Span, trivia: { Trivia } }
	--- The `+` symbol.
	| { kind: "+", span: Span, trivia: { Trivia } }
	--- The `-` symbol.
	| { kind: "-", span: Span, trivia: { Trivia } }
	--- The `*` symbol.
	| { kind: "*", span: Span, trivia: { Trivia } }
	--- The `/` symbol.
	| { kind: "/", span: Span, trivia: { Trivia } }
	--- The `//` symbol.
	| { kind: "//", span: Span, trivia: { Trivia } }
	--- The `%` symbol.
	| { kind: "%", span: Span, trivia: { Trivia } }
	--- The `^` symbol.
	| { kind: "^", span: Span, trivia: { Trivia } }
	--- The `..` symbol.
	| { kind: "..", span: Span, trivia: { Trivia } }
	--- The `<` symbol.
	| { kind: "<", span: Span, trivia: { Trivia } }
	--- The `<=` symbol.
	| { kind: "<=", span: Span, trivia: { Trivia } }
	--- The `>` symbol.
	| { kind: ">", span: Span, trivia: { Trivia } }
	--- The `>=` symbol.
	| { kind: ">=", span: Span, trivia: { Trivia } }
	--- The `==` symbol.
	| { kind: "==", span: Span, trivia: { Trivia } }
	--- The `~=` symbol.
	| { kind: "~=", span: Span, trivia: { Trivia } }
	--- The `#` symbol.
	| { kind: "#", span: Span, trivia: { Trivia } }
	--- The `...` symbol.
	| { kind: "...", span: Span, trivia: { Trivia } }
	--- The `&` symbol.
	| { kind: "&", span: Span, trivia: { Trivia } }
	--- The `|` symbol.
	| { kind: "|", span: Span, trivia: { Trivia } }
	--- The `?` symbol.
	| { kind: "?", span: Span, trivia: { Trivia } }
	--- The `:` symbol.
	| { kind: ":", span: Span, trivia: { Trivia } }
	--- The `::` symbol.
	| { kind: "::", span: Span, trivia: { Trivia } }
	--- The `->` symbol.
	| { kind: "->", span: Span, trivia: { Trivia } }
	--- The `=` symbol.
	| { kind: "=", span: Span, trivia: { Trivia } }
	--- The `,` symbol.
	| { kind: ",", span: Span, trivia: { Trivia } }
	--- The `;` symbol.
	| { kind: ";", span: Span, trivia: { Trivia } }
	--- The `.` symbol.
	| { kind: ".", span: Span, trivia: { Trivia } }
	--- The `(` symbol.
	| { kind: "(", span: Span, trivia: { Trivia } }
	--- The `)` symbol.
	| { kind: ")", span: Span, trivia: { Trivia } }
	--- The `{` symbol.
	| { kind: "{", span: Span, trivia: { Trivia } }
	--- The `}` symbol.
	| { kind: "}", span: Span, trivia: { Trivia } }
	--- The `[` symbol.
	| { kind: "[", span: Span, trivia: { Trivia } }
	--- The `]` symbol.
	| { kind: "]", span: Span, trivia: { Trivia } }

--- A token with a specific kind, such as `TokenKind<"+">` or `TokenKind<"string">`.
export type TokenKind<Kind> = { kind: Kind, text: string, span: Span, trivia: { Trivia } } -- Token & { kind: Kind }

--- A pair of a node and optional separator, such as `node,` or `node`.
--- 
--- This is used within `Separated` to represent nodes like the arguments
--- passed to a function, which would be `Separated<Expr>`.
export type Pair<Node, Sep> = { node: Node, sep: (Sep & Token)? }

--- A list of nodes separated by tokens, such as `foo, bar, baz`.
--- 
--- This is used in many places, notably function arguments, table fields, and
--- stats in blocks.
export type Separated<Node, Sep> = { Pair<Node, Sep> }

--- Delimiters that surround something, such as `(foo)` or `{bar}`.
--- 
--- Note that this node does not store the node within the delimiters, it only
--- stores the delimiters themselves.
export type Delim<Open, Close> = {
	--- The opening delimiter; the `(` in `(foo)`.
	open: Open & Token,

	--- The closing delimiter; the `)` in `(foo)`.
	close: Close & Token,
}

--- A generic declaration without default types; the `<A, B, C...>` in
--- `<A, B, C...>() -> ()`.
--- 
--- This is used in function declarations, local function declarations, and
--- function types.
--- 
--- All names must come before all packs. For example, `<A, B..., C>` is invalid
--- because `C` comes after `B...`.
export type GenericDeclaration = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A, B, C...>`.
	angles: Delim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A, B,` in `A, B, C...`.
	names: Separated<TokenKind<"ident">, TokenKind<",">>,

	--- The generic type packs; the `C...` in `A, B, C...`.
	packs: Separated<{
		--- The name; the `C` in `C...`.
		name: TokenKind<"ident">,

		--- The dots; the `...` in `C...`.
		dots: TokenKind<"...">,
	}, TokenKind<",">>,
}

--- A generic declaration with optional default types; the
--- `<A = number, B... = (number, ...string)>` in
--- `type T<A = number, B... = (number, ...string)> = {}`.
--- 
--- This is used in type declarations.
--- 
--- In addition to the rules of `GenericDeclaration`, this node also requires
--- that any declarations after a declaration with a default type also have a
--- default type. For example, `<A = number, B>` is invalid because `B` doesn't
--- have a default type, but comes after a type with a default type.
export type GenericDeclarationWithDefaults = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A = number, B... = (number, ...string)>`.
	angles: Delim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A = number,` in
	--- `<A = number, B... = (number, ...string)>`.
	names: Separated<{
		--- The name; the `A` in `A = number`.
		name: TokenKind<"ident">,

		--- The default type; the `= number` in `A = number`.
		default: {
			--- The equals sign; the `=` in `= number`.
			equals: TokenKind<"=">,

			--- The type; the `number` in `= number`.
			type: Type,
		}?,
	}, TokenKind<",">>,

	--- The generic type packs; the `B... = (number, ...string)` in
	--- `<A = number, B... = (number, ...string)>`.
	packs: Separated<{
		--- The name; the `B` in `B... = (number, ...string)`.
		name: TokenKind<"ident">,

		--- The dots; the first `...` in `B... = (number, ...string)`.
		dots: TokenKind<"...">,

		--- The default type; the `= (number, ...string)` in
		--- `B... = (number, ...string)`.
		default: {
			--- The equals sign; the `=` in `= (number, ...string)`.
			equals: TokenKind<"=">,

			--- The type; the `(number, ...string)` in `= (number, ...string)`.
			pack: TypePack,
		}?,
	}, TokenKind<",">>,
}

--- An argument to a type, such as `foo` or `...bar` or `bar...`.
--- 
--- This is used in reference types for arguments to types. As an example:
--- `foo<bar, baz...>` would have two `TypeArg`s: `bar` and `baz...`.
export type TypeArg = Type | TypePack

--- A table type field with a name key, such as `foo: bar` or
--- `bar: number`.
export type TableTypeField_NameProp = {
	kind: "nameprop",

	--- The access modifier; the `read` in `foo: bar`.
	--- 
	--- This token should only have values of `read` or `write`.
	access: TokenKind<"ident">?,

	--- The name; the `foo` in `foo: bar`.
	name: TokenKind<"ident">,

	--- The colon; the `:` in `foo: bar`.
	colon: TokenKind<":">,

	--- The type; the `bar` in `foo: bar`.
	type: Type,
}

--- A table type field with a string key, such as `["foo"]: bar` or
--- `['bar']: number`.
export type TableTypeField_StringProp = {
	kind: "stringprop",

	--- The access modifier; the `read` in `["foo"]: bar`.
	--- 
	--- This token should only have values of `read` or `write`.
	access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `["foo"]: bar`.
	bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `"foo"` in `["foo"]: bar`.
	key: TokenKind<"string">,

	--- The colon; the `:` in `["foo"]: bar`.
	colon: TokenKind<":">,

	--- The type; the `bar` in `["foo"]: bar`.
	type: Type,
}

--- A table type indexer field, such as `[number]: string` or
--- `[string]: number`.
export type TableTypeField_Indexer = {
	kind: "indexer",

	--- The access modifier; the `read` in `[number]: string`.
	--- 
	--- This token should only have values of `read` or `write`.
	access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `[number]: string`.
	bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `number` in `[number]: string`.
	key: Type,

	--- The colon; the `:` in `[number]: string`.
	colon: TokenKind<":">,

	--- The type; the `string` in `[number]: string`.
	type: Type,
}

--- A table type field, such as `foo: bar` or `["foo"]: bar` or
--- `write [number]: string`.
export type TableTypeField =
	| TableTypeField_NameProp
	| TableTypeField_StringProp
	| TableTypeField_Indexer

--- The literal type `nil`.
export type Type_Nil = {
	kind: "nil",

	--- The `nil` token.
	tok: TokenKind<"nil">,
}

--- The literal types `true` and `false`.
export type Type_Boolean = {
	kind: "boolean",

	--- The `true` or `false` token.
	tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A string literal type, such as `"foo"` or `'bar'` or `[[baz]]`.
export type Type_String = {
	kind: "string",

	--- The string token.
	tok: TokenKind<"string">,
}

--- A reference type, such as `foo` or `foo<bar>` or `foo.bar<baz>`.
export type Type_Reference = {
	kind: "reference",

	--- The optional prefix; the `foo.` in `foo.bar<baz>`.
	prefix: {
		--- The name; the `foo` in `foo.`.
		name: TokenKind<"ident">,

		--- The dot; the `.` in `foo.`.
		dot: TokenKind<".">,
	}?,

	--- The name; the `bar` in `foo.bar<baz>`.
	name: TokenKind<"ident">,

	--- The optional generics; the `<baz>` in `foo.bar<baz>`.
	generics: {
		--- The angles surrounding the generic declaration; the `<>` in
		--- `<baz>`.
		angles: Delim<TokenKind<"<">, TokenKind<">">>,

		--- The generic types; the `baz` in `<baz>`.
		types: Separated<TypeArg, TokenKind<",">>,
	}?,
}

--- A typeof type, such as `typeof(foo)` or `typeof(10)`.
export type Type_Typeof = {
	kind: "typeof",

	--- The `typeof` token.
	typeof_tok: TokenKind<"ident">,

	--- The parentheses surrounding the expr; the `()` in `typeof(foo)`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `typeof(foo)`.
	expr: Expr,
}

--- An array type, such as `{ foo }` or `{ number }`.
export type Type_Array = {
	kind: "array",

	--- The braces surrounding the type; the `{}` in `{ number }`.
	braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The type; the `number` in `{ number }`.
	type: Type,
}

--- A table type, such as `{ foo: bar, ["baz"]: number, [number]: string }`.
export type Type_Table = {
	kind: "table",

	--- The braces surrounding the type; the `{}` in `{ foo: bar }`.
	braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo: bar` in `{ foo: bar }`.
	fields: Separated<TableTypeField, TokenKind<","> | TokenKind<";">>,
}

--- A function type, such as `<T>(foo: T, ...bar) -> baz`.
export type Type_Function = {
	kind: "function",

	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...bar) -> baz`.
	generics: GenericDeclaration?,

	--- The parentheses surrounding the arguments; the `()` in
	--- `<T>(foo: T, ...bar) -> baz`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in `<T>(foo: T, ...bar) -> baz`.
	params: Separated<{
		--- The optional name of the parameter; the `foo:` in `foo: T`.
		name: {
			--- The name; the `foo` in `foo:`.
			name: TokenKind<"ident">,

			--- The colon; the `:` in `foo:`.
			colon: TokenKind<":">,
		}?,

		--- The type of the parameter; the `T` in `foo: T`.
		type: Type,
	}, TokenKind<",">>,

	--- The optional varargs; the `...bar` in `<T>(foo: T, ...bar) -> baz`.
	varargs: TailType?,

	--- The arrow; the `->` in `<T>(foo: T, ...bar) -> baz`.
	arrow: TokenKind<"->">,

	--- The return type; the `baz` in `<T>(foo: T, ...bar) -> baz`.
	ret: ReturnType,
}

--- A parenthesized type, such as `(foo)` or `(bar)`.
export type Type_Paren = {
	kind: "paren",

	--- The parentheses surrounding the type; the `()` in `(foo)`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The type; the `foo` in `(foo)`.
	type: Type,
}

--- An optional type, such as `foo?` or `bar?`.
export type Type_Optional = {
	kind: "optional",

	--- The type; the `foo` in `foo?`.
	type: Type,

	--- The question mark; the `?` in `foo?`.
	question: TokenKind<"?">,
}

--- A union type, such as `| foo | bar` or `foo | bar`.
export type Type_Union = {
	kind: "union",

	--- The optional leading pipe; the `|` in `| foo | bar`.
	leading: TokenKind<"|">?,

	--- The types; the `foo | bar` in `| foo | bar`.
	types: Separated<Type, TokenKind<"|">>,
}

--- An intersection type, such as `& foo & bar` or `foo & bar`.
export type Type_Intersection = {
	kind: "intersection",

	--- The optional leading ampersand; the `&` in `& foo & bar`.
	leading: TokenKind<"&">?,

	--- The types; the `foo & bar` in `& foo & bar`.
	types: Separated<Type, TokenKind<"&">>,
}

--- A type, such as `number` or `foo` or `{}`.
--- 
--- This node is used in many places, such as variable declarations, function
--- parameters, and type declarations themselves.
export type Type =
	| Type_Nil
	| Type_Boolean
	| Type_String
	| Type_Reference
	| Type_Typeof
	| Type_Array
	| Type_Table
	| Type_Function
	| Type_Paren
	| Type_Optional
	| Type_Union
	| Type_Intersection

--- A variadic type pack, such as `...foo` or `...number`.
export type VariadicTypePack = {
	kind: "variadic",

	--- The dots; the `...` in `...foo`.
	dots: TokenKind<"...">,

	--- The type; the `foo` in `...foo`.
	type: Type,
}

--- A generic type pack, such as `foo...` or `T...`.
export type GenericTypePack = {
	kind: "generic",

	--- The name; the `foo` in `foo...`.
	name: TokenKind<"ident">,

	--- The dots; the `...` in `foo...`.
	dots: TokenKind<"...">,
}

--- A type list, such as `(foo, bar, baz...)` or `(number...)`.
export type TypeList = {
	kind: "list",

	--- The parentheses surrounding the type pack; the `()` in
	--- `(foo, bar, baz...)`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The types; the `foo, bar,` in `(foo, bar, baz...)`.
	types: Separated<Type, TokenKind<",">>,

	--- The optional tail type pack; the `baz...` in `(foo, bar, baz...)`.
	tail: TailType?,
}

--- A tail type in a type pack, such as `...foo` or `bar...`.
export type TailType = VariadicTypePack | GenericTypePack

--- A type pack, such as `...foo` or `foo...` or `(foo, bar, baz...)`.
export type TypePack =
	| VariadicTypePack
	| GenericTypePack
	| TypeList

--- A return type, such as `(foo, bar, baz...)` or `(foo | bar, baz)` or `foo`.
export type ReturnType = Type | TypePack

--- A binding, such as `foo: bar` or `foo`.
--- 
--- This is used in a few places, such as function parameters and local variable
--- declarations.
export type Binding = {
	--- The name; the `foo` in `foo: bar`.
	name: TokenKind<"ident">,

	--- The optional type; the `: bar` in `foo: bar`.
	type: {
		--- The colon; the `:` in `: bar`.
		colon: TokenKind<":">,

		--- The type; the `bar` in `: bar`.
		type: Type,
	}?,
}

--- An interpolated string with no exprs, such as `'simple'`.
export type IString_Simple = {
	kind: "simple",

	--- The string token.
	tok: TokenKind<"istring_simple">,
}

--- An interpolated string with exprs, such as `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type IString_Complex = {
	kind: "complex",

	--- The first segment; the `'foo {'` in `'foo {1} bar {2} baz'`.
	first: TokenKind<"istring_first">,

	--- The middle segments; the `1} bar {2` in `'foo {1} bar {2} baz'`.
	--- 
	--- This needs better documentation. Someone please remind me to do this.
	middle: Separated<Expr, TokenKind<"istring_middle">>,

	--- The last segment; the `} baz'` in `'foo {1} bar {2} baz'`.
	last: TokenKind<"istring_last">,
}

--- An interpolated string, such as `'simple'` or `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type IString = IString_Simple | IString_Complex

--- A branch of an if-else expr, such as `foo then bar`.
export type IfElseExprBranch = {
	--- The condition; the `foo` in `foo then bar`.
	condition: Expr,

	--- The `then` token; the `then` in `foo then bar`.
	then_tok: TokenKind<"then">,

	--- The body; the `bar` in `foo then bar`.
	body: Expr,
}

--- An unary operator: `+`, `-`, `not`, or `#`.
export type UnaryOperator =
	| TokenKind<"+">
	| TokenKind<"-">
	| TokenKind<"not">
	| TokenKind<"#">

--- A binary operator: `+`, `-`, `*`, `/`, `//`, `%`, `^`, `..`, `<`, `<=`, `>`,
--- `>=`, `==`, `~=`, `and`, or `or`.
export type BinaryOperator =
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
export type Expr_Nil = {
	kind: "nil",

	--- The `nil` token.
	tok: TokenKind<"nil">,
}

--- The literal expr `true` and `false`.
export type Expr_Boolean = {
	kind: "boolean",

	--- The `true` or `false` token.
	tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A number literal expr, such as `123` or `0xABCD`.
export type Expr_Number = {
	kind: "number",

	--- The number token.
	tok: TokenKind<"number">,
}

--- A string literal expr, such as `"foo"` or `'bar'` or `[[baz]]`.
export type Expr_String = {
	kind: "string",

	--- The string token.
	tok: TokenKind<"string">,
}

--- The literal expr `...`.
export type Expr_Varargs = {
	kind: "varargs",

	--- The `...` token.
	tok: TokenKind<"...">,
}

--- An interpolated string expr, such as `'simple'` or
--- `'foo {1} bar {2} baz'` or `'hello {"world"}'`.
export type Expr_IString = {
	kind: "istring",

	--- The interpolated string; the `'simple'` in `'simple'`.
	istring: IString,
}

--- A table literal expr, such as `{ foo = bar }` or `{ 1, 2, 3 }`.
export type Expr_Table = {
	kind: "table",

	--- The table literal.
	table: Table,
}

--- An anonymous function expr, such as
--- `@native function(foo, bar) return foo + bar end` or `function() end`.
export type Expr_Function = {
	kind: "function",
	
	--- The function attributes; the `@native` in
	--- `@native function(foo, bar) return foo + bar end`.
	attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	function_tok: TokenKind<"function">,
	
	--- The function body; the `(foo, bar) return foo + bar end` in
	--- `@native function(foo, bar) return foo + bar end`.
	body: FunctionBody,
}

--- An if-else expr, such as `if foo then bar elseif baz then qux else quux`.
export type Expr_IfElse = {
	kind: "ifelse",

	--- The `if` token; the `if` in
	--- `if foo then bar elseif baz then qux else quux`.
	if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar elseif baz then qux` in
	--- `if foo then bar elseif baz then qux else quux`.
	branches: Separated<IfElseExprBranch, TokenKind<"elseif">>,

	--- The `else` token; the `else` in
	--- `if foo then bar elseif baz then qux else quux`.
	else_tok: TokenKind<"else">,

	--- The else body; the `quux` in
	--- `if foo then bar elseif baz then qux else quux`.
	else_body: Expr,
}

--- A var expr, such as `foo.bar[baz]()` or `foo`.
export type Expr_Var = {
	kind: "var",

	--- The var.
	var: Var,
}

--- A type assertion expr, such as `foo :: bar` or `{} :: { number }`.
export type Expr_Assertion = {
	kind: "assertion",

	--- The expr; the `foo` in `foo :: bar`.
	expr: Expr,

	--- The double colon; the `::` in `foo :: bar`.
	colon: TokenKind<"::">,

	--- The type; the `bar` in `foo :: bar`.
	type: Type,
}

--- An unary expr, such as `-foo` or `not bar`.
export type Expr_Unary = {
	kind: "unary",

	--- The operator; the `-` in `-foo`.
	operator: UnaryOperator,

	--- The expr; the `foo` in `-foo`.
	expr: Expr,
}

--- A binary expr, such as `foo + bar` or `baz and qux`.
export type Expr_Binary = {
	kind: "binary",

	--- The left expr; the `foo` in `foo + bar`.
	left: Expr,

	--- The operator; the `+` in `foo + bar`.
	operator: BinaryOperator,

	--- The right expr; the `bar` in `foo + bar`.
	right: Expr,
}

--- An expression, such as `nil` or `foo` or `foo + bar`.
--- 
--- This node is used in many places, such as function arguments, table fields,
--- variable assignments, and return stats.
export type Expr =
	| Expr_Nil
	| Expr_Boolean
	| Expr_Number
	| Expr_String
	| Expr_Varargs
	| Expr_IString
	| Expr_Table
	| Expr_Function
	| Expr_IfElse
	| Expr_Var
	| Expr_Assertion
	| Expr_Unary
	| Expr_Binary

--- Pack argument to a call, such as `(foo, bar)` or `()`.
export type FunctionArg_Pack = {
	kind: "pack",

	--- The parens surrounding the pack; the `()` in `()`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The exprs; the `foo, bar` in `(foo, bar)`.
	exprs: Separated<Expr, TokenKind<",">>,
}

--- Table argument to a call, such as `{ foo = bar }` or `{}`.
export type FunctionArg_Table = {
	kind: "table",

	--- The table literal.
	table: Table,
}

--- String argument to a call, such as `"foo"` or `'bar'`.
export type FunctionArg_String = {
	kind: "string",

	--- The string token.
	tok: TokenKind<"string">,
}

--- An argument to a call, such as `(foo, bar)` or `()` or `"baz"`.
export type FunctionArg =
	| FunctionArg_Pack
	| FunctionArg_Table
	| FunctionArg_String

--- A name as a variable, such as `foo`.
export type VarRoot_Name = {
	kind: "name",

	--- The name token.
	tok: TokenKind<"ident">,
}

--- A parenthesized expr, such as `(foo)` or `(1 + 1)`.
export type VarRoot_Paren = {
	kind: "paren",

	--- The parentheses surrounding the expr; the `()` in `(foo)`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `(foo)`.
	expr: Expr,
}

--- The root of a variable, such as `foo` or `(foo)`.
export type VarRoot = VarRoot_Name | VarRoot_Paren

--- A named index, such as `root.foo` or `root.bar`.
export type VarSuffix_NameIndex = {
	kind: "nameindex",

	--- The dot; the `.` in `.foo`.
	dot: TokenKind<".">,

	--- The name; the `foo` in `.foo`.
	name: TokenKind<"ident">,
}

--- An expr index, such as `root[foo]` or `root[1 + 1]`.
export type VarSuffix_ExprIndex = {
	kind: "exprindex",

	--- The brackets surrounding the expr; the `[]` in `[foo]`.
	bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The expr; the `foo` in `[foo]`.
	expr: Expr,
}

--- A call, such as `root:method(foo)` or `root()`.
export type VarSuffix_Call = {
	kind: "call",

	--- The optional method; the `:method` in `root:method(foo)`.
	method: {
		--- The colon; the `:` in `:method`.
		colon: TokenKind<":">,

		--- The name; the `method` in `:method`.
		name: TokenKind<"ident">,
	}?,
	
	--- The argument; the `(foo)` in `root:method(foo)`.
	arg: FunctionArg,
}

--- A suffix of a variable, such as `.foo` or `[bar]` or `()`.
export type VarSuffix =
	| VarSuffix_NameIndex
	| VarSuffix_ExprIndex
	| VarSuffix_Call

--- A variable, such as `foo` or `foo.bar()[baz]`.
--- 
--- This node is used in exprs, assignments, and function calls. This is
--- essentially anything that can appear on the left side of an assignment stat
--- or before a function call.
--- 
--- As an example:
export type Var = {
	--- The root of the variable; the `foo` in `foo.bar()[baz]`.
	root: VarRoot,

	--- The suffixes of the variable; the `.bar()[baz]` in `foo.bar()[baz]`.
	suffixes: { VarSuffix },
}

--- A table field with a name key, such as `foo = bar` or `bar = 1`.
export type TableField_NameKey = {
	kind: "namekey",

	--- The name; the `foo` in `foo = bar`.
	name: TokenKind<"ident">,

	--- The equals sign; the `=` in `foo = bar`.
	equals: TokenKind<"=">,

	--- The value; the `bar` in `foo = bar`.
	value: Expr,
}

--- A table field with an expr key, such as `[foo] = bar` or `[1] = 2`.
export type TableField_ExprKey = {
	kind: "exprkey",

	--- The brackets surrounding the key; the `[]` in `[foo] = bar`.
	bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `foo` in `[foo] = bar`.
	key: Expr,

	--- The equals sign; the `=` in `[foo] = bar`.
	equals: TokenKind<"=">,

	--- The value; the `bar` in `[foo] = bar`.
	value: Expr,
}

--- A table field with no key, such as `foo` or `1`.
export type TableField_NoKey = {
	kind: "nokey",

	--- The value; the `foo` in `foo`.
	value: Expr,
}

--- A table field, such as `foo = bar` or `[baz] = qux` or `quux`.
export type TableField =
	| TableField_NameKey
	| TableField_ExprKey
	| TableField_NoKey

--- A table literal, such as `{ foo = bar, [baz] = qux, quux }`.
export type Table = {
	--- The braces surrounding the table; the `{}` in `{ foo = bar }`.
	braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo = bar` in `{ foo = bar }`.
	fields: Separated<TableField, TokenKind<","> | TokenKind<";">>,
}

--- A function body, such as `<T>(foo: T, ...: bar): baz return 10 end`.
--- 
--- This is used in anonymous functions, function declarations, and local
--- function declarations.
export type FunctionBody = {
	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	generics: GenericDeclaration?,

	--- The parentheses surrounding the parameters; the `()` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	params: Separated<Binding, TokenKind<",">>,

	--- The optional varargs; the `...: bar` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	varargs: {
		--- The dots; the `...` in `...: bar`.
		dots: TokenKind<"...">,

		--- The optional type; the `: bar` in `...: bar`.
		type: {
			--- The colon; the `:` in `: bar`.
			colon: TokenKind<":">,

			--- The type; the `bar` in `: bar`.
			type: Type | GenericTypePack,
		}?,
	}?,

	--- The return type; the `: baz` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	ret: {
		--- The colon; the `:` in `: baz`.
		colon: TokenKind<":">,

		--- The type; the `baz` in `: baz`.
		type: ReturnType,
	}?,

	--- The block; the `return 10` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	block: Block,

	--- The `end` token; the `end` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	end_tok: TokenKind<"end">,
}

--- A branch in an if stat, such as `foo then bar()`
export type IfStatBranch = {
	--- The condition; the `foo` in `foo then bar()`.
	condition: Expr,

	--- The `then` token.
	then_tok: TokenKind<"then">,

	--- The block; the `bar()` in `foo then bar()`.
	block: Block,
}

--- A compound operator: `+=`, `-=`, `*=`, `/=`, `//=`, `%=`, `*=`, `or `..=`.
export type CompoundOperator = 
	| TokenKind<"+=">
	| TokenKind<"-=">
	| TokenKind<"*=">
	| TokenKind<"/=">
	| TokenKind<"//=">
	| TokenKind<"%=">
	| TokenKind<"^=">
	| TokenKind<"..=">

--- An assignment stat, such as `foo, bar = baz, qux` or `foo = bar`.
export type Stat_Assign = {
	kind: "assign",

	--- The left side of the assignment; the `foo, bar` in
	--- `foo, bar = baz, qux`.
	left: Separated<Var, TokenKind<",">>,

	--- The equals sign; the `=` in `foo, bar = baz, qux`.
	equals: TokenKind<"=">,

	--- The right side of the assignment; the `baz, qux` in
	--- `foo, bar = baz, qux`.
	right: Separated<Expr, TokenKind<",">>,
}

--- A compound assignment stat, such as `foo += bar`.
export type Stat_CompoundAssign = {
	kind: "compoundassign",

	--- The left side of the assignment; the `foo` in `foo += bar`.
	left: Var,

	--- The compound operator; the `+=` in `foo += bar`.
	operator: CompoundOperator,

	--- The right side of the assignment; the `bar` in `foo += bar`.
	right: Expr,
}

--- A function call stat, such as `foo.bar()` or `baz()`.
export type Stat_Call = {
	kind: "call",

	--- A var ending with a call suffix.
	--- 
	--- This call not ending with a call suffix will result in a syntax error
	--- when emitted.
	call: Var,
}

--- A do stat, such as `do foo() end`.
export type Stat_Do = {
	kind: "do",
	
	--- The `do` token.
	do_tok: TokenKind<"do">,

	--- The block within the do; the `foo()` in `do foo() end`.
	block: Block,

	--- The `end` token.
	end_tok: TokenKind<"end">,
}

--- A while stat, such as `while foo do bar() end`.
export type Stat_While = {
	kind: "while",

	--- The `while` token.
	while_tok: TokenKind<"while">,

	--- The condition; the `foo` in `while foo do bar() end`.
	condition: Expr,

	--- The `do` token.
	do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `while foo do bar() end`.
	block: Block,

	--- The `end` token.
	end_tok: TokenKind<"end">,
}

--- A repeat stat, such as `repeat foo() until bar`.
export type Stat_Repeat = {
	kind: "repeat",

	--- The `repeat` token.
	repeat_tok: TokenKind<"repeat">,
	
	--- The block; the `foo()` in `repeat foo() until bar`.
	block: Block,

	--- The `until` token.
	until_tok: TokenKind<"until">,

	--- The condition; the `bar` in `repeat foo() until bar`.
	condition: Expr,
}

--- An if stat, such as
--- `if foo then bar() elseif baz then qux() else quux() end`.
export type Stat_If = {
	kind: "if",

	--- The `if` token.
	if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar() elseif baz then qux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	branches: Separated<IfStatBranch, TokenKind<"elseif">>,

	--- The optional else branch; the `else quux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	else_branch: {
		--- The `else` token.
		else_tok: TokenKind<"else">,

		--- The else branch block; the `quux()` in `else quux()`.
		block: Block,
	}?,

	--- The `end` token.
	end_tok: TokenKind<"end">,
}

--- A numeric for loop stat, such as `for foo = 1, 2, 3 do bar() end`.
export type Stat_NumericFor = {
	kind: "numericfor",

	--- The `for` token.
	for_tok: TokenKind<"for">,

	--- The binding; the `foo` in `for foo = 1, 2, 3  do bar() end`.
	binding: Binding,

	--- The equals token; the `=` in `for foo = 1, 2, 3 do bar() end`.
	equals: TokenKind<"=">,

	--- The start expr; the `1` in `for foo = 1, 2, 3 do bar() end`.
	start_expr: Expr,

	--- The comma between the start and end; the first comma in
	--- `for foo = 1, 2, 3 do bar() end`.
	comma: TokenKind<",">,

	--- The end expr; the `2` in `for foo = 1, 2, 3 do bar() end`.
	end_expr: Expr,

	--- The optional step; the `, 3` in `for foo = 1, 2, 3 do bar() end`.
	step: {
		--- The comma between the end and step; the comma in `, 3` and the
		--- second comma in `for foo = 1, 2, 3 do bar() end`.
		comma: TokenKind<",">,

		--- The step expr; the `3` in `, 3` and the `3` in
		--- `for foo = 1, 2, 3 do bar() end`.
		expr: Expr,
	}?,

	--- The `do` token.
	do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `for foo = 1, 2, 3 do bar() end`.
	block: Block,

	--- The `end` token.
	end_tok: TokenKind<"end">,
}

--- A for-in loop stat, such as `for foo: bar, baz in qux, quux do quuz() end`.
export type Stat_ForIn = {
	kind: "forin",

	--- The `for` token.
	for_tok: TokenKind<"for">,

	--- The bindings; the `foo: bar, baz` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	bindings: Separated<Binding, TokenKind<",">>,

	--- The `in` token.
	in_tok: TokenKind<"in">,

	--- The exprs; the `qux, quux` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	exprs: Separated<Expr, TokenKind<",">>,

	--- The `do` token.
	do_tok: TokenKind<"do">,

	--- The block; the `quuz()` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	block: Block,

	--- The `end` token.
	end_tok: TokenKind<"end">,
}

--- A function declaration stat, such as
--- `@native function foo.bar:baz() return 1 end`.
export type Stat_Function = {
	kind: "function",
	
	--- The attributes; the `@native` in
	--- `@native function foo.bar:baz() return 1 end`.
	attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	function_tok: TokenKind<"function">,

	--- The name; the `foo.bar` in
	--- `@native function foo.bar:baz() return 1 end`.
	names: Separated<TokenKind<"ident">, TokenKind<".">>,

	--- The optional method; the `:baz` in
	--- `@native function foo.bar:baz() return 1 end`.
	method: {
		--- The colon; the `:` in `:baz`.
		colon: TokenKind<":">,
		
		--- The method name; the `baz` in `:baz`.
		name: TokenKind<"ident">,
	}?,

	--- The function body; the `() return 1 end` in
	--- `@native function foo.bar:baz() return 1 end`.
	body: FunctionBody,
}

--- A local function declaration stat, such as
--- `@native local function foo() return 1 end`.
export type Stat_LocalFunction = {
	kind: "localfunction",
	
	--- The attributes; the `@native` in
	--- `@native local function foo() return 1 end`.
	attributes: { TokenKind<"attribute"> },

	--- The `local` token.
	local_tok: TokenKind<"local">,

	--- The `function` token.
	function_tok: TokenKind<"function">,

	--- The name; the `foo` in `@native local function foo() return 1 end`.
	name: TokenKind<"ident">,

	--- The function body; the `() return 1 end` in
	--- `@native local function foo() return 1 end`.
	body: FunctionBody,
}

--- A local variable stat, such as `local foo: bar, baz = qux, quux, quuz`.
export type Stat_LocalVariable = {
	kind: "localvariable",

	--- The `local` token.
	local_tok: TokenKind<"local">,

	--- The bindings; the `foo: bar, baz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	bindings: Separated<Binding, TokenKind<",">>,

	--- The optional values; the `= qux, quux, quuz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	values: {
		--- The equals; the `=` in `= qux, quux, quuz`.
		equals: TokenKind<"=">,

		--- The exprs; the `qux, quux, quuz` in `= qux, quux, quuz`.
		exprs: Separated<Expr, TokenKind<",">>,
	}?,
}

--- A type declaration stat, such as `export type foo<bar> = baz`.
export type Stat_Type = {
	kind: "type",

	--- The optional `export` token.
	--- 
	--- Note that the value of this identifier must be `export` otherwise this
	--- will result in a syntax error.
	export_tok: TokenKind<"ident">?,

	--- The `type` token.
	---
	--- Note that the value of this identifier must be `type` otherwise this
	--- will result in a syntax error.
	type_tok: TokenKind<"ident">,

	--- The name of the type; the `foo` in `export type foo<bar> = baz`.
	name: TokenKind<"ident">,

	--- The optional generic declarations; the `<bar>` in `export type foo<bar> = baz`.
	generics: GenericDeclarationWithDefaults?,

	--- The equals token; the `=` in `export type foo<bar> = baz`.
	equals: TokenKind<"=">,

	--- The type; the `baz` in `export type foo<bar> = baz`.
	type: Type,
}

--- A statement in a block, such as `foo()` or `local foo = bar` or `foo = bar`.
export type Stat =
	| Stat_Assign
	| Stat_CompoundAssign
	| Stat_Call
	| Stat_Do
	| Stat_While
	| Stat_Repeat
	| Stat_If
	| Stat_NumericFor
	| Stat_ForIn
	| Stat_Function
	| Stat_LocalFunction
	| Stat_LocalVariable
	| Stat_Type

--- A return laststat, such as `return foo, bar, baz` or `return`.
export type LastStat_Return = {
	kind: "return",

	--- The `return` token.
	return_tok: TokenKind<"return">,

	--- The returned exprs; the `foo, bar, baz` in `return foo, bar, baz`.
	exprs: Separated<Expr, TokenKind<",">>,
}

--- A `break` laststat.
export type LastStat_Break = {
	kind: "break",
	
	--- The `break` token.
	tok: TokenKind<"break">,
}

--- A `continue` laststat.
export type LastStat_Continue = {
	kind: "continue",

	--- The `continue` token.
	--- 
	--- Note that the value of this identifier must be `continue` otherwise this
	--- will result in a syntax error.
	tok: TokenKind<"ident">,
}

--- The last statement in a block, such as `return`, `break`, or `continue`.
export type LastStat =
	| LastStat_Return
	| LastStat_Break
	| LastStat_Continue

--- A block of stats, ending with an optional laststat, such as
--- `foo(); bar(); return baz;`.
export type Block = {
	--- The stats, the `foo(); bar();` in `foo(); bar(); return baz;`.
	stats: Separated<Stat, TokenKind<";">>,

	--- The optional laststat, the `return baz;` in `foo(); bar(); return baz;`.
	last_stat: {
		--- The laststat; the `return baz` in `return baz;`.
		stat: LastStat,

		--- The optional semicolon; the `;` in `return baz;`.
		semicolon: TokenKind<";">?,
	}?,
}

--- A full CST with a block and eof.
export type Cst = {
	--- The block of stats.
	block: Block,

	--- The eof token.
	eof: TokenKind<"eof">,
}

return {}