--- This is a lossy luau parser implemented in luau. When parsing it discards
--- unimportant information like whitespace. However, it still tracks comments
--- and span information.

--- Stores the locational information of a token or AST node.
--- 
--- Components:
--- * x: The start index.
--- * y: The end index.
--- * z: Unused.
export type Span = { read x: number, read y: number, read z: number }

--- An identifier or name; such as `foo` or `bar`.
--- 
--- This is used everywhere throughout the AST and stores both the identifier's
--- name and its span.
export type AstIdentifier = {
	--- The span of the node.
	read span: Span,

	--- The name of the identifier.
	read name: string,
}

--- A string literal; such as `"foo"` or `'bar'`.
export type AstString = {
	--- The span of the node.
	read span: Span,

	--- The string value of the literal, including the quotes.
	read value: string,
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
	--- The span of the node.
	read span: Span,

	--- The generic types; the `A, B,` in `<A, B, C...>`
	read names: { AstIdentifier },

	--- The generic type packs; the `C...` in `<A, B, C...>`
	read packs: { AstIdentifier },
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
	--- The span of the node.
	read span: Span,

	--- The generic types; the `A = number,` in
	--- `<A = number, B... = (number, ...string)>`.
	read names: { {
		--- The span of the node.
		read span: Span,

		--- The name; the `A` in `A = number`.
		read name: AstIdentifier,

		--- The optional default type; the `number` in `A = number`.
		read default: AstType?,
	} },

	--- The generic type packs; the `B... = (number, ...string)` in
	--- `<A = number, B... = (number, ...string)>`.
	read packs: { {
		--- The span of the node.
		read span: Span,

		--- The name; the `B` in `B... = (number, ...string)`.
		read name: AstIdentifier,

		--- The optional default type; the `(number, ...string)` in
		--- `B... = (number, ...string)`.
		read default: AstTypePack?,
	} },
}

--- An argument to a type, such as `foo` or `...bar` or `baz...`.
--- 
--- This is used in reference types for arguments to types. As an example:
--- `foo<bar, baz...>` would have two `AstTypeArg`s: `bar` and `baz...`.
export type AstTypeArg = AstType | AstTypePack

--- A table type field with a name key, such as `read foo: bar` or
--- `bar: number`.
export type AstTableTypeField_NameProp = {
	read kind: "nameprop",

	--- The span of the node.
	read span: Span,

	--- The optional access modifier; the `read` in `read foo: bar`.
	--- 
	--- This identifier should only have values of `read` or `write`.
	read access: AstIdentifier?,

	--- The name; the `foo` in `read foo: bar`.
	read name: AstIdentifier,

	--- The type; the `bar` in `read foo: bar`.
	read type: AstType,
}

--- A table type field with a string key, such as `read ["foo"]: bar` or
--- `["bar"]: number`.
export type AstTableTypeField_StringProp = {
	read kind: "stringprop",

	--- The span of the node.
	read span: Span,

	--- The access modifier; the `read` in `read ["foo"]: bar`.
	--- 
	--- This identifier should only have values of `read` or `write`.
	read access: AstIdentifier?,

	--- The string key; the `"foo"` in `read ["foo"]: bar`.
	read key: AstString,

	--- The type; the `bar` in `read ["foo"]: bar`.
	read type: AstType,
}

--- A table type indexer field, such as `read [number]: string` or
--- `[string]: number`.
export type AstTableTypeField_Indexer = {
	read kind: "indexer",

	--- The span of the node.
	read span: Span,

	--- The access modifier; the `read` in `read [number]: string`.
	--- 
	--- This identifier should only have values of `read` or `write`.
	read access: AstIdentifier?,

	--- The key; the `number` in `read [number]: string`.
	read key: AstType,

	--- The type; the `string` in `read [number]: string`.
	read type: AstType,
}

--- A table type field, such as `read foo: bar`, `["foo"]: bar`, or
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

	--- The span of the node.
	read span: Span,
}

--- The literal types `true` and `false`.
export type AstType_Boolean = {
	read kind: "boolean",

	--- The span of the node.
	read span: Span,

	--- The value of the boolean.
	read value: boolean,
}

--- A string literal type; `"foo"` or `'bar'`.
export type AstType_String = {
	read kind: "string",

	--- The string literal.
	read value: AstString,
}


