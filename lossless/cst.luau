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
	--- The `+=` symbol.
	| { read kind: "+=", read span: Span, read trivia: { Trivia } }
	--- The `-=` symbol.
	| { read kind: "-=", read span: Span, read trivia: { Trivia } }
	--- The `*=` symbol.
	| { read kind: "*=", read span: Span, read trivia: { Trivia } }
	--- The `/=` symbol.
	| { read kind: "/=", read span: Span, read trivia: { Trivia } }
	--- The `//=` symbol.
	| { read kind: "//=", read span: Span, read trivia: { Trivia } }
	--- The `%=` symbol.
	| { read kind: "%=", read span: Span, read trivia: { Trivia } }
	--- The `^=` symbol.
	| { read kind: "^=", read span: Span, read trivia: { Trivia } }
	--- The `..=` symbol.
	| { read kind: "..=", read span: Span, read trivia: { Trivia } }
	--- The `+` symbol.
	| { read kind: "+", read span: Span, read trivia: { Trivia } }
	--- The `-` symbol.
	| { read kind: "-", read span: Span, read trivia: { Trivia } }
	--- The `*` symbol.
	| { read kind: "*", read span: Span, read trivia: { Trivia } }
	--- The `/` symbol.
	| { read kind: "/", read span: Span, read trivia: { Trivia } }
	--- The `//` symbol.
	| { read kind: "//", read span: Span, read trivia: { Trivia } }
	--- The `%` symbol.
	| { read kind: "%", read span: Span, read trivia: { Trivia } }
	--- The `^` symbol.
	| { read kind: "^", read span: Span, read trivia: { Trivia } }
	--- The `..` symbol.
	| { read kind: "..", read span: Span, read trivia: { Trivia } }
	--- The `<` symbol.
	| { read kind: "<", read span: Span, read trivia: { Trivia } }
	--- The `<=` symbol.
	| { read kind: "<=", read span: Span, read trivia: { Trivia } }
	--- The `>` symbol.
	| { read kind: ">", read span: Span, read trivia: { Trivia } }
	--- The `>=` symbol.
	| { read kind: ">=", read span: Span, read trivia: { Trivia } }
	--- The `==` symbol.
	| { read kind: "==", read span: Span, read trivia: { Trivia } }
	--- The `~=` symbol.
	| { read kind: "~=", read span: Span, read trivia: { Trivia } }
	--- The `#` symbol.
	| { read kind: "#", read span: Span, read trivia: { Trivia } }
	--- The `...` symbol.
	| { read kind: "...", read span: Span, read trivia: { Trivia } }
	--- The `&` symbol.
	| { read kind: "&", read span: Span, read trivia: { Trivia } }
	--- The `|` symbol.
	| { read kind: "|", read span: Span, read trivia: { Trivia } }
	--- The `?` symbol.
	| { read kind: "?", read span: Span, read trivia: { Trivia } }
	--- The `:` symbol.
	| { read kind: ":", read span: Span, read trivia: { Trivia } }
	--- The `::` symbol.
	| { read kind: "::", read span: Span, read trivia: { Trivia } }
	--- The `->` symbol.
	| { read kind: "->", read span: Span, read trivia: { Trivia } }
	--- The `=` symbol.
	| { read kind: "=", read span: Span, read trivia: { Trivia } }
	--- The `,` symbol.
	| { read kind: ",", read span: Span, read trivia: { Trivia } }
	--- The `;` symbol.
	| { read kind: ";", read span: Span, read trivia: { Trivia } }
	--- The `.` symbol.
	| { read kind: ".", read span: Span, read trivia: { Trivia } }
	--- The `(` symbol.
	| { read kind: "(", read span: Span, read trivia: { Trivia } }
	--- The `)` symbol.
	| { read kind: ")", read span: Span, read trivia: { Trivia } }
	--- The `{` symbol.
	| { read kind: "{", read span: Span, read trivia: { Trivia } }
	--- The `}` symbol.
	| { read kind: "}", read span: Span, read trivia: { Trivia } }
	--- The `[` symbol.
	| { read kind: "[", read span: Span, read trivia: { Trivia } }
	--- The `]` symbol.
	| { read kind: "]", read span: Span, read trivia: { Trivia } }

--- A token with a specific kind, such as `TokenKind<"+">` or `TokenKind<"string">`.
export type TokenKind<Kind> = { read kind: Kind, read text: string, read span: Span, read trivia: { Trivia } } -- Token & { read kind: Kind }

--- A pair of a node and optional separator, such as `node,` or `node`.
--- 
--- This is used within `Separated` to represent nodes like the arguments
--- passed to a function, which would be `Separated<Expr>`.
export type Pair<Node, Sep> = { read node: Node, read sep: (Sep & Token)? }

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
export type GenericDeclaration = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A, B, C...>`.
	read angles: Delim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A, B,` in `A, B, C...`.
	read names: Separated<TokenKind<"ident">, TokenKind<",">>,

	--- The generic type packs; the `C...` in `A, B, C...`.
	read packs: Separated<{
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
--- In addition to the rules of `GenericDeclaration`, this node also requires
--- that any declarations after a declaration with a default type also have a
--- default type. For example, `<A = number, B>` is invalid because `B` doesn't
--- have a default type, but comes after a type with a default type.
export type GenericDeclarationWithDefaults = {
	--- The angles surrounding the generic declaration; the `<>` in
	--- `<A = number, B... = (number, ...string)>`.
	read angles: Delim<TokenKind<"<">, TokenKind<">">>,

	--- The generic types; the `A = number,` in
	--- `<A = number, B... = (number, ...string)>`.
	read names: Separated<{
		--- The name; the `A` in `A = number`.
		read name: TokenKind<"ident">,

		--- The default type; the `= number` in `A = number`.
		read default: {
			--- The equals sign; the `=` in `= number`.
			read equals: TokenKind<"=">,

			--- The type; the `number` in `= number`.
			read type: Type,
		}?,
	}, TokenKind<",">>,

	--- The generic type packs; the `B... = (number, ...string)` in
	--- `<A = number, B... = (number, ...string)>`.
	read packs: Separated<{
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
			read pack: TypePack,
		}?,
	}, TokenKind<",">>,
}

--- An argument to a type, such as `foo` or `...bar` or `bar...`.
--- 
--- This is used in reference types for arguments to types. As an example:
--- `foo<bar, baz...>` would have two `TypeArg`s: `bar` and `baz...`.
export type TypeArg = Type | TypePack

--- A table type field with a name key, such as `read foo: bar` or
--- `bar: number`.
export type TableTypeField_NameProp = {
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
	read type: Type,
}

--- A table type field with a string key, such as `read ["foo"]: bar` or
--- `['bar']: number`.
export type TableTypeField_StringProp = {
	read kind: "stringprop",

	--- The access modifier; the `read` in `read ["foo"]: bar`.
	--- 
	--- This token should only have values of `read` or `write`.
	read access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `read ["foo"]: bar`.
	read bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `"foo"` in `read ["foo"]: bar`.
	read key: TokenKind<"string">,

	--- The colon; the `:` in `read ["foo"]: bar`.
	read colon: TokenKind<":">,

	--- The type; the `bar` in `read ["foo"]: bar`.
	read type: Type,
}

--- A table type indexer field, such as `read [number]: string` or
--- `[string]: number`.
export type TableTypeField_Indexer = {
	read kind: "indexer",

	--- The access modifier; the `read` in `read [number]: string`.
	--- 
	--- This token should only have values of `read` or `write`.
	read access: TokenKind<"ident">?,

	--- The brackets surrounding the key; the `[]` in `read [number]: string`.
	read bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `number` in `read [number]: string`.
	read key: Type,

	--- The colon; the `:` in `read [number]: string`.
	read colon: TokenKind<":">,

	--- The type; the `string` in `read [number]: string`.
	read type: Type,
}

--- A table type field, such as `read foo: bar` or `["foo"]: bar` or
--- `write [number]: string`.
export type TableTypeField =
	| TableTypeField_NameProp
	| TableTypeField_StringProp
	| TableTypeField_Indexer

--- The literal type `nil`.
export type Type_Nil = {
	read kind: "nil",

	--- The `nil` token.
	read tok: TokenKind<"nil">,
}

--- The literal types `true` and `false`.
export type Type_Boolean = {
	read kind: "boolean",

	--- The `true` or `false` token.
	read tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A string literal type, such as `"foo"` or `'bar'` or `[[baz]]`.
export type Type_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- A reference type, such as `foo` or `foo<bar>` or `foo.bar<baz>`.
export type Type_Reference = {
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
		read angles: Delim<TokenKind<"<">, TokenKind<">">>,

		--- The generic types; the `baz` in `<baz>`.
		read types: Separated<TypeArg, TokenKind<",">>,
	}?,
}

--- A typeof type, such as `typeof(foo)` or `typeof(10)`.
export type Type_Typeof = {
	read kind: "typeof",

	--- The `typeof` token.
	read typeof_tok: TokenKind<"ident">,

	--- The parentheses surrounding the expr; the `()` in `typeof(foo)`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `typeof(foo)`.
	read expr: Expr,
}

--- An array type, such as `{ foo }` or `{ number }`.
export type Type_Array = {
	read kind: "array",

	--- The braces surrounding the type; the `{}` in `{ number }`.
	read braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The type; the `number` in `{ number }`.
	read type: Type,
}

--- A table type, such as `{ foo: bar, ["baz"]: number, [number]: string }`.
export type Type_Table = {
	read kind: "table",

	--- The braces surrounding the type; the `{}` in `{ foo: bar }`.
	read braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo: bar` in `{ foo: bar }`.
	read fields: Separated<TableTypeField, TokenKind<","> | TokenKind<";">>,
}

--- A function type, such as `<T>(foo: T, ...bar) -> baz`.
export type Type_Function = {
	read kind: "function",

	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...bar) -> baz`.
	read generics: GenericDeclaration?,

	--- The parentheses surrounding the arguments; the `()` in
	--- `<T>(foo: T, ...bar) -> baz`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in `<T>(foo: T, ...bar) -> baz`.
	read params: Separated<{
		--- The optional name of the parameter; the `foo:` in `foo: T`.
		read name: {
			--- The name; the `foo` in `foo:`.
			read name: TokenKind<"ident">,

			--- The colon; the `:` in `foo:`.
			read colon: TokenKind<":">,
		}?,

		--- The type of the parameter; the `T` in `foo: T`.
		read type: Type,
	}, TokenKind<",">>,

	--- The optional varargs; the `...bar` in `<T>(foo: T, ...bar) -> baz`.
	read varargs: TailType?,

	--- The arrow; the `->` in `<T>(foo: T, ...bar) -> baz`.
	read arrow: TokenKind<"->">,

	--- The return type; the `baz` in `<T>(foo: T, ...bar) -> baz`.
	read ret: ReturnType,
}

--- A parenthesized type, such as `(foo)` or `(bar)`.
export type Type_Paren = {
	read kind: "paren",

	--- The parentheses surrounding the type; the `()` in `(foo)`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The type; the `foo` in `(foo)`.
	read type: Type,
}

--- An optional type, such as `foo?` or `bar?`.
export type Type_Optional = {
	read kind: "optional",

	--- The type; the `foo` in `foo?`.
	read type: Type,

	--- The question mark; the `?` in `foo?`.
	read question: TokenKind<"?">,
}

--- A union type, such as `| foo | bar` or `foo | bar`.
export type Type_Union = {
	read kind: "union",

	--- The optional leading pipe; the `|` in `| foo | bar`.
	read leading: TokenKind<"|">?,

	--- The types; the `foo | bar` in `| foo | bar`.
	read types: Separated<Type, TokenKind<"|">>,
}

--- An intersection type, such as `& foo & bar` or `foo & bar`.
export type Type_Intersection = {
	read kind: "intersection",

	--- The optional leading ampersand; the `&` in `& foo & bar`.
	read leading: TokenKind<"&">?,

	--- The types; the `foo & bar` in `& foo & bar`.
	read types: Separated<Type, TokenKind<"&">>,
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
	read kind: "variadic",

	--- The dots; the `...` in `...foo`.
	read dots: TokenKind<"...">,

	--- The type; the `foo` in `...foo`.
	read type: Type,
}

--- A generic type pack, such as `foo...` or `T...`.
export type GenericTypePack = {
	read kind: "generic",

	--- The name; the `foo` in `foo...`.
	read name: TokenKind<"ident">,

	--- The dots; the `...` in `foo...`.
	read dots: TokenKind<"...">,
}

--- A type list, such as `(foo, bar, baz...)` or `(number...)`.
export type TypeList = {
	read kind: "list",

	--- The parentheses surrounding the type pack; the `()` in
	--- `(foo, bar, baz...)`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The types; the `foo, bar,` in `(foo, bar, baz...)`.
	read types: Separated<Type, TokenKind<",">>,

	--- The optional tail type pack; the `baz...` in `(foo, bar, baz...)`.
	read tail: TailType?,
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
	read name: TokenKind<"ident">,

	--- The optional type; the `: bar` in `foo: bar`.
	read type: {
		--- The colon; the `:` in `: bar`.
		read colon: TokenKind<":">,

		--- The type; the `bar` in `: bar`.
		read type: Type,
	}?,
}

--- An interpolated string with no exprs, such as `'simple'`.
export type IString_Simple = {
	read kind: "simple",

	--- The string token.
	read tok: TokenKind<"istring_simple">,
}

--- An interpolated string with exprs, such as `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type IString_Complex = {
	read kind: "complex",

	--- The first segment; the `'foo {'` in `'foo {1} bar {2} baz'`.
	read first: TokenKind<"istring_first">,

	--- The middle segments; the `1} bar {2` in `'foo {1} bar {2} baz'`.
	--- 
	--- This needs better documentation. Someone please remind me to do this.
	read middle: Separated<Expr, TokenKind<"istring_middle">>,

	--- The last segment; the `} baz'` in `'foo {1} bar {2} baz'`.
	read last: TokenKind<"istring_last">,
}

--- An interpolated string, such as `'simple'` or `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type IString = IString_Simple | IString_Complex

--- A branch of an if-else expr, such as `foo then bar`.
export type IfElseExprBranch = {
	--- The condition; the `foo` in `foo then bar`.
	read condition: Expr,

	--- The `then` token; the `then` in `foo then bar`.
	read then_tok: TokenKind<"then">,

	--- The body; the `bar` in `foo then bar`.
	read body: Expr,
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
	read kind: "nil",

	--- The `nil` token.
	read tok: TokenKind<"nil">,
}

--- The literal expr `true` and `false`.
export type Expr_Boolean = {
	read kind: "boolean",

	--- The `true` or `false` token.
	read tok: TokenKind<"true"> | TokenKind<"false">,
}

--- A number literal expr, such as `123` or `0xABCD`.
export type Expr_Number = {
	read kind: "number",

	--- The number token.
	read tok: TokenKind<"number">,
}

--- A string literal expr, such as `"foo"` or `'bar'` or `[[baz]]`.
export type Expr_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- The literal expr `...`.
export type Expr_Varargs = {
	read kind: "varargs",

	--- The `...` token.
	read tok: TokenKind<"...">,
}

--- An interpolated string expr, such as `'simple'` or
--- `'foo {1} bar {2} baz'` or `'hello {"world"}'`.
export type Expr_IString = {
	read kind: "istring",

	--- The interpolated string; the `'simple'` in `'simple'`.
	read istring: IString,
}

--- A table literal expr, such as `{ foo = bar }` or `{ 1, 2, 3 }`.
export type Expr_Table = {
	read kind: "table",

	--- The table literal.
	read table: Table,
}

--- An anonymous function expr, such as
--- `@native function(foo, bar) return foo + bar end` or `function() end`.
export type Expr_Function = {
	read kind: "function",
	
	--- The function attributes; the `@native` in
	--- `@native function(foo, bar) return foo + bar end`.
	read attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	read function_tok: TokenKind<"function">,
	
	--- The function body; the `(foo, bar) return foo + bar end` in
	--- `@native function(foo, bar) return foo + bar end`.
	read body: FunctionBody,
}

--- An if-else expr, such as `if foo then bar elseif baz then qux else quux`.
export type Expr_IfElse = {
	read kind: "ifelse",

	--- The `if` token; the `if` in
	--- `if foo then bar elseif baz then qux else quux`.
	read if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar elseif baz then qux` in
	--- `if foo then bar elseif baz then qux else quux`.
	read branches: Separated<IfElseExprBranch, TokenKind<"elseif">>,

	--- The `else` token; the `else` in
	--- `if foo then bar elseif baz then qux else quux`.
	read else_tok: TokenKind<"else">,

	--- The else body; the `quux` in
	--- `if foo then bar elseif baz then qux else quux`.
	read else_body: Expr,
}

--- A var expr, such as `foo.bar[baz]()` or `foo`.
export type Expr_Var = {
	read kind: "var",

	--- The var.
	read var: Var,
}

--- A type assertion expr, such as `foo :: bar` or `{} :: { number }`.
export type Expr_Assertion = {
	read kind: "assertion",

	--- The expr; the `foo` in `foo :: bar`.
	read expr: Expr,

	--- The double colon; the `::` in `foo :: bar`.
	read colon: TokenKind<"::">,

	--- The type; the `bar` in `foo :: bar`.
	read type: Type,
}

--- An unary expr, such as `-foo` or `not bar`.
export type Expr_Unary = {
	read kind: "unary",

	--- The operator; the `-` in `-foo`.
	read operator: UnaryOperator,

	--- The expr; the `foo` in `-foo`.
	read expr: Expr,
}

--- A binary expr, such as `foo + bar` or `baz and qux`.
export type Expr_Binary = {
	read kind: "binary",

	--- The left expr; the `foo` in `foo + bar`.
	read left: Expr,

	--- The operator; the `+` in `foo + bar`.
	read operator: BinaryOperator,

	--- The right expr; the `bar` in `foo + bar`.
	read right: Expr,
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
	read kind: "pack",

	--- The parens surrounding the pack; the `()` in `()`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The exprs; the `foo, bar` in `(foo, bar)`.
	read exprs: Separated<Expr, TokenKind<",">>,
}

--- Table argument to a call, such as `{ foo = bar }` or `{}`.
export type FunctionArg_Table = {
	read kind: "table",

	--- The table literal.
	read table: Table,
}

--- String argument to a call, such as `"foo"` or `'bar'`.
export type FunctionArg_String = {
	read kind: "string",

	--- The string token.
	read tok: TokenKind<"string">,
}

--- An argument to a call, such as `(foo, bar)` or `()` or `"baz"`.
export type FunctionArg =
	| FunctionArg_Pack
	| FunctionArg_Table
	| FunctionArg_String

--- A name as a variable, such as `foo`.
export type VarRoot_Name = {
	read kind: "name",

	--- The name token.
	read tok: TokenKind<"ident">,
}

--- A parenthesized expr, such as `(foo)` or `(1 + 1)`.
export type VarRoot_Paren = {
	read kind: "paren",

	--- The parentheses surrounding the expr; the `()` in `(foo)`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The expr; the `foo` in `(foo)`.
	read expr: Expr,
}

--- The root of a variable, such as `foo` or `(foo)`.
export type VarRoot = VarRoot_Name | VarRoot_Paren

--- A named index, such as `root.foo` or `root.bar`.
export type VarSuffix_NameIndex = {
	read kind: "nameindex",

	--- The dot; the `.` in `.foo`.
	read dot: TokenKind<".">,

	--- The name; the `foo` in `.foo`.
	read name: TokenKind<"ident">,
}

--- An expr index, such as `root[foo]` or `root[1 + 1]`.
export type VarSuffix_ExprIndex = {
	read kind: "exprindex",

	--- The brackets surrounding the expr; the `[]` in `[foo]`.
	read bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The expr; the `foo` in `[foo]`.
	read expr: Expr,
}

--- A call, such as `root:method(foo)` or `root()`.
export type VarSuffix_Call = {
	read kind: "call",

	--- The optional method; the `:method` in `root:method(foo)`.
	read method: {
		--- The colon; the `:` in `:method`.
		read colon: TokenKind<":">,

		--- The name; the `method` in `:method`.
		read name: TokenKind<"ident">,
	}?,
	
	--- The argument; the `(foo)` in `root:method(foo)`.
	read arg: FunctionArg,
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
	read root: VarRoot,

	--- The suffixes of the variable; the `.bar()[baz]` in `foo.bar()[baz]`.
	read suffixes: { VarSuffix },
}

--- A table field with a name key, such as `foo = bar` or `bar = 1`.
export type TableField_NameKey = {
	read kind: "namekey",

	--- The name; the `foo` in `foo = bar`.
	read name: TokenKind<"ident">,

	--- The equals sign; the `=` in `foo = bar`.
	read equals: TokenKind<"=">,

	--- The value; the `bar` in `foo = bar`.
	read value: Expr,
}

--- A table field with an expr key, such as `[foo] = bar` or `[1] = 2`.
export type TableField_ExprKey = {
	read kind: "exprkey",

	--- The brackets surrounding the key; the `[]` in `[foo] = bar`.
	read bracks: Delim<TokenKind<"[">, TokenKind<"]">>,

	--- The key; the `foo` in `[foo] = bar`.
	read key: Expr,

	--- The equals sign; the `=` in `[foo] = bar`.
	read equals: TokenKind<"=">,

	--- The value; the `bar` in `[foo] = bar`.
	read value: Expr,
}

--- A table field with no key, such as `foo` or `1`.
export type TableField_NoKey = {
	read kind: "nokey",

	--- The value; the `foo` in `foo`.
	read value: Expr,
}

--- A table field, such as `foo = bar` or `[baz] = qux` or `quux`.
export type TableField =
	| TableField_NameKey
	| TableField_ExprKey
	| TableField_NoKey

--- A table literal, such as `{ foo = bar, [baz] = qux, quux }`.
export type Table = {
	--- The braces surrounding the table; the `{}` in `{ foo = bar }`.
	read braces: Delim<TokenKind<"{">, TokenKind<"}">>,

	--- The fields; the `foo = bar` in `{ foo = bar }`.
	read fields: Separated<TableField, TokenKind<","> | TokenKind<";">>,
}

--- A function body, such as `<T>(foo: T, ...: bar): baz return 10 end`.
--- 
--- This is used in anonymous functions, function declarations, and local
--- function declarations.
export type FunctionBody = {
	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read generics: GenericDeclaration?,

	--- The parentheses surrounding the parameters; the `()` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read parens: Delim<TokenKind<"(">, TokenKind<")">>,

	--- The parameters; the `foo: T,` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read params: Separated<Binding, TokenKind<",">>,

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
			read type: Type | GenericTypePack,
		}?,
	}?,

	--- The return type; the `: baz` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read ret: {
		--- The colon; the `:` in `: baz`.
		read colon: TokenKind<":">,

		--- The type; the `baz` in `: baz`.
		read type: ReturnType,
	}?,

	--- The block; the `return 10` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read block: Block,

	--- The `end` token; the `end` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read end_tok: TokenKind<"end">,
}

--- A branch in an if stat, such as `foo then bar()`
export type IfStatBranch = {
	--- The condition; the `foo` in `foo then bar()`.
	read condition: Expr,

	--- The `then` token.
	read then_tok: TokenKind<"then">,

	--- The block; the `bar()` in `foo then bar()`.
	read block: Block,
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
	read kind: "assign",

	--- The left side of the assignment; the `foo, bar` in
	--- `foo, bar = baz, qux`.
	read left: Separated<Var, TokenKind<",">>,

	--- The equals sign; the `=` in `foo, bar = baz, qux`.
	read equals: TokenKind<"=">,

	--- The right side of the assignment; the `baz, qux` in
	--- `foo, bar = baz, qux`.
	read right: Separated<Expr, TokenKind<",">>,
}

--- A compound assignment stat, such as `foo += bar`.
export type Stat_CompoundAssign = {
	read kind: "compoundassign",

	--- The left side of the assignment; the `foo` in `foo += bar`.
	read left: Var,

	--- The compound operator; the `+=` in `foo += bar`.
	read operator: CompoundOperator,

	--- The right side of the assignment; the `bar` in `foo += bar`.
	read right: Expr,
}

--- A function call stat, such as `foo.bar()` or `baz()`.
export type Stat_Call = {
	read kind: "call",

	--- A var ending with a call suffix.
	--- 
	--- This call not ending with a call suffix will result in a syntax error
	--- when emitted.
	read call: Var,
}

--- A do stat, such as `do foo() end`.
export type Stat_Do = {
	read kind: "do",
	
	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block within the do; the `foo()` in `do foo() end`.
	read block: Block,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A while stat, such as `while foo do bar() end`.
export type Stat_While = {
	read kind: "while",

	--- The `while` token.
	read while_tok: TokenKind<"while">,

	--- The condition; the `foo` in `while foo do bar() end`.
	read condition: Expr,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `while foo do bar() end`.
	read block: Block,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A repeat stat, such as `repeat foo() until bar`.
export type Stat_Repeat = {
	read kind: "repeat",

	--- The `repeat` token.
	read repeat_tok: TokenKind<"repeat">,
	
	--- The block; the `foo()` in `repeat foo() until bar`.
	read block: Block,

	--- The `until` token.
	read until_tok: TokenKind<"until">,

	--- The condition; the `bar` in `repeat foo() until bar`.
	read condition: Expr,
}

--- An if stat, such as
--- `if foo then bar() elseif baz then qux() else quux() end`.
export type Stat_If = {
	read kind: "if",

	--- The `if` token.
	read if_tok: TokenKind<"if">,

	--- The branches; the `foo then bar() elseif baz then qux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read branches: Separated<IfStatBranch, TokenKind<"elseif">>,

	--- The optional else branch; the `else quux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read else_branch: {
		--- The `else` token.
		read else_tok: TokenKind<"else">,

		--- The else branch block; the `quux()` in `else quux()`.
		read block: Block,
	}?,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A numeric for loop stat, such as `for foo = 1, 2, 3 do bar() end`.
export type Stat_NumericFor = {
	read kind: "numericfor",

	--- The `for` token.
	read for_tok: TokenKind<"for">,

	--- The binding; the `foo` in `for foo = 1, 2, 3  do bar() end`.
	read binding: Binding,

	--- The equals token; the `=` in `for foo = 1, 2, 3 do bar() end`.
	read equals: TokenKind<"=">,

	--- The start expr; the `1` in `for foo = 1, 2, 3 do bar() end`.
	read start_expr: Expr,

	--- The comma between the start and end; the first comma in
	--- `for foo = 1, 2, 3 do bar() end`.
	read comma: TokenKind<",">,

	--- The end expr; the `2` in `for foo = 1, 2, 3 do bar() end`.
	read end_expr: Expr,

	--- The optional step; the `, 3` in `for foo = 1, 2, 3 do bar() end`.
	read step: {
		--- The comma between the end and step; the comma in `, 3` and the
		--- second comma in `for foo = 1, 2, 3 do bar() end`.
		read comma: TokenKind<",">,

		--- The step expr; the `3` in `, 3` and the `3` in
		--- `for foo = 1, 2, 3 do bar() end`.
		read expr: Expr,
	}?,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `bar()` in `for foo = 1, 2, 3 do bar() end`.
	read block: Block,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A for-in loop stat, such as `for foo: bar, baz in qux, quux do quuz() end`.
export type Stat_ForIn = {
	read kind: "forin",

	--- The `for` token.
	read for_tok: TokenKind<"for">,

	--- The bindings; the `foo: bar, baz` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read bindings: Separated<Binding, TokenKind<",">>,

	--- The `in` token.
	read in_tok: TokenKind<"in">,

	--- The exprs; the `qux, quux` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read exprs: Separated<Expr, TokenKind<",">>,

	--- The `do` token.
	read do_tok: TokenKind<"do">,

	--- The block; the `quuz()` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read block: Block,

	--- The `end` token.
	read end_tok: TokenKind<"end">,
}

--- A function declaration stat, such as
--- `@native function foo.bar:baz() return 1 end`.
export type Stat_Function = {
	read kind: "function",
	
	--- The attributes; the `@native` in
	--- `@native function foo.bar:baz() return 1 end`.
	read attributes: { TokenKind<"attribute"> },

	--- The `function` token.
	read function_tok: TokenKind<"function">,

	--- The name; the `foo.bar` in
	--- `@native function foo.bar:baz() return 1 end`.
	read names: Separated<TokenKind<"ident">, TokenKind<".">>,

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
	read body: FunctionBody,
}

--- A local function declaration stat, such as
--- `@native local function foo() return 1 end`.
export type Stat_LocalFunction = {
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
	read body: FunctionBody,
}

--- A local variable stat, such as `local foo: bar, baz = qux, quux, quuz`.
export type Stat_LocalVariable = {
	read kind: "localvariable",

	--- The `local` token.
	read local_tok: TokenKind<"local">,

	--- The bindings; the `foo: bar, baz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read bindings: Separated<Binding, TokenKind<",">>,

	--- The optional values; the `= qux, quux, quuz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read values: {
		--- The equals; the `=` in `= qux, quux, quuz`.
		read equals: TokenKind<"=">,

		--- The exprs; the `qux, quux, quuz` in `= qux, quux, quuz`.
		read exprs: Separated<Expr, TokenKind<",">>,
	}?,
}

--- A type declaration stat, such as `export type foo<bar> = baz`.
export type Stat_Type = {
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
	read generics: GenericDeclarationWithDefaults?,

	--- The equals token; the `=` in `export type foo<bar> = baz`.
	read equals: TokenKind<"=">,

	--- The type; the `baz` in `export type foo<bar> = baz`.
	read type: Type,
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
	read kind: "return",

	--- The `return` token.
	read return_tok: TokenKind<"return">,

	--- The returned exprs; the `foo, bar, baz` in `return foo, bar, baz`.
	read exprs: Separated<Expr, TokenKind<",">>,
}

--- A `break` laststat.
export type LastStat_Break = {
	read kind: "break",
	
	--- The `break` token.
	read tok: TokenKind<"break">,
}

--- A `continue` laststat.
export type LastStat_Continue = {
	read kind: "continue",

	--- The `continue` token.
	--- 
	--- Note that the value of this identifier must be `continue` otherwise this
	--- will result in a syntax error.
	read tok: TokenKind<"ident">,
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
	read stats: Separated<Stat, TokenKind<";">>,

	--- The optional laststat, the `return baz;` in `foo(); bar(); return baz;`.
	read last_stat: {
		--- The laststat; the `return baz` in `return baz;`.
		read stat: LastStat,

		--- The optional semicolon; the `;` in `return baz;`.
		read semicolon: TokenKind<";">?,
	}?,
}

--- A full CST with a block and eof.
export type Cst = {
	--- The block of stats.
	read block: Block,

	--- The eof token.
	read eof: TokenKind<"eof">,
}

return {}