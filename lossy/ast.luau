--- Stores the locational information of a token or AST node.
--- 
--- Components:
--- * x: The start index.
--- * y: The end index.
--- * z: Unused.
export type Span = { read x: number, read y: number, read z: number }

--- An identifier or name; such as `foo` or `bar`.
export type AstIdentifier = {
	--- The span of the node.
	read span: Span,

	--- The name of the identifier.
	read name: string,
}

--- A number literal; such as `123` or `0xABCD`.
export type AstNumber = {
	--- The span of the node.
	read span: Span,

	--- The text of the number.
	read text: string,
}

--- A string literal; such as `"foo"` or `'bar'`.
export type AstString = {
	--- The span of the node.
	read span: Span,

	--- The string value of the literal, including the quotes.
	read value: string,
}

--- An attribute, such as `@native`.
export type AstAttribute = {
	--- The span of the node.
	read span: Span,

	--- The name of the attribute, not including the `@`.
	read name: string,
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

--- A reference type, such as `foo` or `foo<bar>` or `foo.bar<baz, quz...>`.
export type AstType_Reference = {
	read kind: "reference",

	--- The span of the node.
	read span: Span,

	--- The optional prefix; the `foo` in `foo.bar<baz, quz...>`.
	read prefix: AstIdentifier?,

	--- The name; the `bar` in `foo.bar<baz, quz...>`.
	read name: AstIdentifier,

	--- The generics; the `<baz, quz...>` in `foo.bar<baz, quz...>`.
	read generics: { AstTypeArg },
}

--- A typeof type, such as `typeof(foo)` or `typeof(10)`.
export type AstType_Typeof = {
	read kind: "typeof",

	--- The span of the node.
	read span: Span,

	--- The expr; the `foo` in `typeof(foo)`.
	read expr: AstExpr,
}

--- An array type, such as `{ foo }` or `{ number }`.
export type AstType_Array = {
	read kind: "array",

	--- The span of the node.
	read span: Span,

	--- The type; the `number` in `{ number }`.
	read type: AstType,
}

--- A table type, such as `{ foo: bar, ["baz"]: number, [number]: string }`.
export type AstType_Table = {
	read kind: "table",

	--- The span of the node.
	read span: Span,

	--- The fields; the `foo: bar` in `{ foo: bar }`.
	read fields: { AstTableTypeField },
}

--- A function type, such as `<T>(foo: T, ...bar) -> baz`.
export type AstType_Function = {
	read kind: "function",

	--- The span of the node.
	read span: Span,

	--- The generics; the `<T>` in `<T>(foo: T, ...bar) -> baz`.
	read generics: AstGenericDeclaration?,

	--- The parameters; the `foo: T` in `<T>(foo: T, ...bar) -> baz`.
	read params: { {
		--- The span of the node.
		read span: Span,

		--- The optional name of the parameter; the `foo` in `foo: T`.
		read name: AstIdentifier?,

		--- The type of the parameter; the `T` in `foo: T`.
		read type: AstType,
	} },

	--- The optional varargs; the `...bar` in `<T>(foo: T, ...bar) -> baz`.
	read varargs: AstTailType?,

	--- The return type; the `baz` in `<T>(foo: T, ...bar) -> baz`.
	read ret: AstReturnType?,
}

--- A parenthesized type, such as `(foo)` or `(bar)`.
export type AstType_Paren = {
	read kind: "paren",

	--- The span of the node.
	read span: Span,

	--- The type; the `foo` in `(foo)`.
	read type: AstType,
}

--- An optional type, such as `foo?` or `bar?`.
export type AstType_Optional = {
	read kind: "optional",

	--- The span of the node.
	read span: Span,

	--- The type; the `foo` in `foo?`.
	read type: AstType,
}

--- A union type, such as `| foo | bar` or `foo | bar`.
export type AstType_Union = {
	read kind: "union",

	--- The span of the node.
	read span: Span,

	--- The types; the `foo` and `bar` in `foo | bar`.
	read types: { AstType },
}

--- An intersection type, such as `& foo & bar` or `foo & bar`.
export type AstType_Intersection = {
	read kind: "intersection",

	--- The span of the node.
	read span: Span,

	--- The types; the `foo` and `bar` in `foo & bar`.
	read types: { AstType },
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

	--- The span of the node.
	read span: Span,

	--- The type; the `foo` in `...foo`.
	read type: AstType,
}

--- A generic type pack, such as `foo...` or `T...`.
export type AstTypePack_Generic = {
	read kind: "generic",

	--- The span of the node.
	read span: Span,

	--- The name; the `foo` in `foo...`.
	read name: AstIdentifier,
}

--- A list type pack, such as `(foo, bar, baz...)` or `(number...)`.
export type AstTypePack_List = {
	read kind: "list",

	--- The span of the node.
	read span: Span,

	--- The types; the `foo`, `bar`, and `baz` in `(foo, bar, baz...)`.
	read types: { AstType },

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
--- declaration.
export type AstBinding = {
	--- The span of the node.
	read span: Span,

	--- The name; the `foo` in `foo: bar`.
	read name: AstIdentifier,

	--- The optional type; the `bar` in `foo: bar`.
	read type: AstType?,
}

--- An interpolated string with no exprs, such as `'simple'`.
export type AstIString_Simple = {
	read kind: "simple",

	--- The span of the node.
	read span: Span,

	--- The string value of the literal, including the quotes.
	read value: string,
}

--- An interpolated string with exprs, such as `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type AstIString_Complex = {
	read kind: "complex",

	--- The span of the node.
	read span: Span,

	--- The first segment; the `'foo {'` in `'foo {1} bar {2} baz'`.
	--- 
	--- This includes the leading quote and trailing brace
	read first: string,

	--- The middle segments; the `1} bar {2` in `'foo {1} bar {2} baz'`.
	read middle: { {
		--- The span of the node.
		read span: Span,

		--- The expr; the `1` or `2` in `1} bar {2`.
		read expr: AstExpr,

		--- The string after the expr; the `} bar {` in `1} bar {2`.
		--- 
		--- This includes the leading and trailing braces. For the last segment,
		--- this will be nil.
		read after: string?,
	} },

	--- The last segment; the `} baz'` in `'foo {1} bar {2} baz'`.
	--- 
	--- This includes the leading brace and trailing quote.
	read last: string,
}

--- An interpolated string, such as `'simple'` or `'foo {1} bar {2} baz'` or
--- `'hello {"world"}'`.
export type AstIString = AstIString_Simple | AstIString_Complex

--- A branch of an if-else expr, such as `foo then bar`.
export type AstIfElseExprBranch = {
	--- The span of the node.
	read span: Span,

	--- The condition; the `foo` in `foo then bar`.
	read condition: AstExpr,

	--- The body; the `bar` in `foo then bar`.
	read body: AstExpr,
}

--- An unary operator.
export type AstUnaryOperator = 
	| "+"
	| "-"
	| "not"
	| "#"

--- A binary operator.
export type AstBinaryOperator = 
	| "+"
	| "-"
	| "*"
	| "/"
	| "//"
	| "%"
	| "^"
	| ".."
	| "<"
	| "<="
	| ">"
	| ">="
	| "=="
	| "~="
	| "and"
	| "or"

--- The literal expr `nil`.
export type AstExpr_Nil = {
	read kind: "nil",

	--- The span of the node.
	read span: Span,
}

--- The literal exprs `true` and `false`.
export type AstExpr_Boolean = {
	read kind: "boolean",

	--- The span of the node.
	read span: Span,

	--- The value of the boolean.
	read value: boolean,
}

--- A number literal expr, such as `123` or `0xABCD`.
export type AstExpr_Number = {
	read kind: "number",

	--- The number literal.
	read value: AstNumber,
}

--- A string literal expr, such as `"foo"` or `'bar'`.
export type AstExpr_String = {
	read kind: "string",

	--- The string literal.
	read value: AstString,
}

--- The literal expr `...`.
export type AstExpr_Varargs = {
	read kind: "varargs",

	--- The span of the node.
	read span: Span,
}

--- An interpolated string expr, such as `'simple'` or
--- `foo {1} bar {2} baz` or `hello {"world"}`.
export type AstExpr_IString = {
	read kind: "istring",

	--- The interpolated string.
	read value: AstIString,
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

	--- The span of the node.
	read span: Span,

	--- The function attributes; the `@native` in
	--- `@native function(foo, bar) return foo + bar end`.
	read attributes: { AstAttribute },

	--- The function body; the `(foo, bar) return foo + bar end` in
	--- `@native function(foo, bar) return foo + bar end`.
	read body: AstFunctionBody,
}

--- An if-else expr, such as `if foo then bar elseif baz then qux else quux`.
export type AstExpr_IfElse = {
	read kind: "ifelse",

	--- The span of the node.
	read span: Span,

	--- The branches; the `foo then bar elseif baz then qux` in
	--- `if foo then bar elseif baz then qux else quux`.
	read branches: { AstIfElseExprBranch },

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

	--- The span of the node.
	read span: Span,

	--- The expr; the `foo` in `foo :: bar`.
	read expr: AstExpr,

	--- The type; the `bar` in `foo :: bar`.
	read type: AstType,
}

--- A unary expr, such as `-foo` or `not bar`.
export type AstExpr_Unary = {
	read kind: "unary",

	--- The span of the node.
	read span: Span,

	--- The operator; the `-` in `-foo`.
	read operator: AstUnaryOperator,

	--- The expr; the `foo` in `-foo`.
	read expr: AstExpr,
}

--- A binary expr, such as `foo + bar` or `baz and qux`.
export type AstExpr_Binary = {
	read kind: "binary",

	--- The span of the node.
	read span: Span,

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

--- A pack argument to a call, such as `(foo, bar)` or `()`.
export type AstFunctionArg_Pack = {
	read kind: "pack",

	--- The span of the node.
	read span: Span,

	--- The exprs; the `foo, bar` in `(foo, bar)`.
	read exprs: { AstExpr },
}

--- A table argument to a call, such as `{ foo = bar }` or `{}`.
export type AstFunctionArg_Table = {
	read kind: "table",

	--- The table literal.
	read table: AstTable,
}

--- A string argument to a call, such as `"foo"` or `'bar'`.
export type AstFunctionArg_String = {
	read kind: "string",

	--- The string literal.
	read value: AstString,
}

--- An argument to a call, such as `(foo, bar)` or `()` or `"baz"`.
export type AstFunctionArg =
	| AstFunctionArg_Pack
	| AstFunctionArg_Table
	| AstFunctionArg_String

--- A name as a variable, such as `foo`.
export type AstVarRoot_Name = {
	read kind: "name",

	--- The name of the variable.
	read name: AstIdentifier,
}

--- A parenthesized expr, such as `(foo)` or `(1 + 2)`.
export type AstVarRoot_Paren = {
	read kind: "paren",

	--- The span of the node.
	read span: Span,

	--- The expr; the `foo` in `(foo)`.
	read expr: AstExpr,
}

--- The root of a variable, such as `foo` or `(foo)`.
export type AstVarRoot = AstVarRoot_Name | AstVarRoot_Paren

--- A named index, such as `root.foo` or `root.bar`.
export type AstVarSuffix_ExprIndex = {
	read kind: "nameindex",

	--- The span of the node.
	read span: Span,

	--- The name; the `foo` in `root.foo`.
	read name: AstIdentifier,
}

--- An expr index, such as `root[foo]` or `root[1 + 1]`.
export type AstVarSuffix_NameIndex = {
	read kind: "exprindex",

	--- The span of the node.
	read span: Span,

	--- The expr; the `foo` in `root[foo]`.
	read expr: AstExpr,
}

--- A call, such as `root:method(foo)` or `root()`.
export type AstVarSuffix_Call = {
	read kind: "call",

	--- The span of the node.
	read span: Span,

	--- The optional method; the `method` in `root:method(foo)`.
	read method: AstIdentifier?,

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
export type AstVar = {
	--- The root of the variable; the `foo` in `foo.bar()[baz]`.
	read root: AstVarRoot,

	--- The suffixes of the variable; the `.bar()[baz]` in `foo.bar()[baz]`.
	read suffixes: { AstVarSuffix },
}

--- A table field with a name key, such as `foo = bar` or `bar = 1`.
export type AstTableField_NameKey = {
	read kind: "namekey",

	--- The span of the node.
	read span: Span,

	--- The name; the `foo` in `foo = bar`.
	read name: AstIdentifier,

	--- The value; the `bar` in `foo = bar`.
	read value: AstExpr,
}

--- A table field with an expr key, such as `[foo] = bar` or `[1] = 2`.
export type AstTableField_ExprKey = {
	read kind: "exprkey",

	--- The span of the node.
	read span: Span,

	--- The key; the `foo` in `[foo] = bar`.
	read key: AstExpr,

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
	--- The span of the node.
	read span: Span,

	--- The fields; the `foo = bar` in `{ foo = bar }`.
	read fields: { AstTableField },
}

--- A function body, such as `<T>(foo: T, ...: bar): baz return 10 end`.
--- 
--- This is used in anonymous functions, function declarations, and local
--- function declarations.
export type AstFunctionBody = {
	--- The span of the node.
	read span: Span,

	--- The optional generic declaration; the `<T>` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read generics: AstGenericDeclaration?,

	--- The parameters; the `foo: T` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read params: { AstBinding },

	--- The optional varargs; the `...: bar` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read varargs: {
		--- The span of the node.
		read span: Span,

		--- The optional type; the `bar` in `...: bar`.
		read type: AstType?,
	}?,

	--- The return type; the `baz` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read ret: AstReturnType?,

	--- The block; the `return 10` in
	--- `<T>(foo: T, ...: bar): baz return 10 end`.
	read block: AstBlock,
}

--- A branch in an if stat, such as `foo then bar()`.
export type AstIfStatBranch = {
	--- The span of the node.
	read span: Span,

	--- The condition; the `foo` in `foo then bar()`.
	read condition: AstExpr,

	--- The block; the `bar()` in `foo then bar()`.
	read block: AstBlock,
}

--- A compound operator.
export type AstCompoundOperator = 
	| "+="
	| "-="
	| "*="
	| "/="
	| "//="
	| "%="
	| "^="
	| "..="

--- An assignment stat, such as `foo, bar = baz, qux` or `foo = bar`.
export type AstStat_Assign = {
	read kind: "assign",

	--- The left side of the assignment; the `foo, bar` in
	--- `foo, bar = baz, qux`.
	read left: { AstVar },

	--- The right side of the assignment; the `baz, qux` in
	--- `foo, bar = baz, qux`.
	read right: { AstExpr },
}

--- A compound assignment stat, such as `foo += bar`.
export type AstStat_CompoundAssign = {
	read kind: "compoundassign",

	--- The left side of the assignment; the `foo` in `foo += bar`.
	read left: AstVar,

	--- The operator; the `+=` in `foo += bar`.
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

	--- The span of the node.
	read span: Span,

	--- The block within the do; the `foo()` in `do foo() end`.
	read block: AstBlock,
}

--- A while stat, such as `while foo do bar() end`.
export type AstStat_While = {
	read kind: "while",

	--- The span of the node.
	read span: Span,

	--- The condition; the `foo` in `while foo do bar() end`.
	read condition: AstExpr,

	--- The block; the `bar()` in `while foo do bar() end`.
	read block: AstBlock,
}

--- A repeat stat, such as `repeat foo() until bar`.
export type AstStat_Repeat = {
	read kind: "repeat",

	--- The span of the node.
	read span: Span,

	--- The block; the `foo()` in `repeat foo() until bar`.
	read block: AstBlock,

	--- The condition; the `bar` in `repeat foo() until bar`.
	read condition: AstExpr,
}

--- An if stat, such as
--- `if foo then bar() elseif baz then qux() else quux() end`.
export type AstStat_If = {
	read kind: "if",

	--- The span of the node.
	read span: Span,

	--- The branches; the `foo then bar() elseif baz then qux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read branches: { AstIfStatBranch },

	--- The optional else block; the `quux()` in
	--- `if foo then bar() elseif baz then qux() else quux() end`.
	read else_block: AstBlock?,
}

--- A numeric for loop stat, such as `for foo = 1, 2, 3 do bar() end`.
export type AstStat_NumericFor = {
	read kind: "numericfor",

	--- The span of the node.
	read span: Span,

	--- The binding; the `foo` in `for foo = 1, 2, 3 do bar() end`.
	read binding: AstBinding,

	--- The start expr; the `1` in `for foo = 1, 2, 3 do bar() end`.
	read start_expr: AstExpr,

	--- The end expr; the `2` in `for foo = 1, 2, 3 do bar() end`.
	read end_expr: AstExpr,
	
	--- The optional step expr; the `3` in `for foo = 1, 2, 3 do bar() end`.
	read step_expr: AstExpr?,

	--- The block; the `bar()` in `for foo = 1, 2, 3 do bar() end`.
	read block: AstBlock,
}

--- A for-in loop stat, such as `for foo: bar, baz in qux, quux do quuz() end`.
export type AstStat_ForIn = {
	read kind: "forin",

	--- The span of the node.
	read span: Span,

	--- The bindings; the `foo: bar, baz` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read bindings: { AstBinding },

	--- The exprs; the `qux, quux` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read exprs: { AstExpr },

	--- The block; the `quuz()` in
	--- `for foo: bar, baz in qux, quux do quuz() end`.
	read block: AstBlock,
}

--- A function declaration stat, such as
--- `@native function foo.bar:baz() return 1 end`.
export type AstStat_Function = {
	read kind: "function",

	--- The span of the node.
	read span: Span,

	--- The function attributes; the `@native` in
	--- `@native function foo.bar:baz() return 1 end`.
	read attributes: { AstAttribute },

	--- The name; the `foo.bar` in
	--- `@native function foo.bar:baz() return 1 end`.
	read names: { AstIdentifier },

	--- The optional method; the `baz` in
	--- `@native function foo.bar:baz() return 1 end`.
	read method: AstIdentifier?,

	--- The function body; the `() return 1 end` in
	--- `@native function foo.bar:baz() return 1 end`.
	read body: AstFunctionBody,
}

--- A local function declaration stat, such as
--- `@native local function foo() return 1 end`.
export type AstStat_LocalFunction = {
	read kind: "localfunction",

	--- The span of the node.
	read span: Span,

	--- The function attributes; the `@native` in
	--- `@native local function foo() return 1 end`.
	read attributes: { AstAttribute },

	--- The name; the `foo` in
	--- `@native local function foo() return 1 end`.
	read name: AstIdentifier,

	--- The function body; the `() return 1 end` in
	--- `@native local function foo() return 1 end`.
	read body: AstFunctionBody,
}

--- A local variable stat, such as `local foo: bar, baz = qux, quux, quuz`.
export type AstStat_LocalVariable = {
	read kind: "localvariable",

	--- The span of the node.
	read span: Span,

	--- The bindings; the `foo: bar, baz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read bindings: { AstBinding },

	--- The exprs; the `qux, quux, quuz` in
	--- `local foo: bar, baz = qux, quux, quuz`.
	read exprs: { AstExpr },
}

--- A type declaration stat, such as `export type foo<bar> = baz`.
export type AstStat_Type = {
	read kind: "type",

	--- The span of the node.
	read span: Span,

	--- If the type is exported.
	read export: boolean,

	--- The name; the `foo` in `export type foo<bar> = baz`.
	read name: AstIdentifier,

	--- The optional generic declaration; the `<bar>` in `export type foo<bar> = baz`.
	read generics: AstGenericDeclarationWithDefaults?,

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

--- A return laststat, such as `return foo, bar` or `return`.
export type AstLastStat_Return = {
	read kind: "return",

	--- The span of the node.
	read span: Span,

	--- The optional exprs; the `foo, bar` in `return foo, bar`.
	read exprs: { AstExpr },
}

--- A `break` laststat.
export type AstLastStat_Break = {
	read kind: "break",

	--- The span of the node.
	read span: Span,
}

--- A `continue` laststat.
export type AstLastStat_Continue = {
	read kind: "continue",

	--- The span of the node.
	read span: Span,
}

--- The last statement in a block, such as `return`, `break`, or `continue`.
export type AstLastStat =
	| AstLastStat_Return
	| AstLastStat_Break
	| AstLastStat_Continue

--- A block of stats, ending with an optional laststat, such as
--- `foo(); bar(); return baz;`.
export type AstBlock = {
	--- The span of the node.
	read span: Span,

	--- The stats; the `foo(); bar();` in `foo(); bar(); return baz;`.
	read stats: { AstStat },

	--- The optional laststat; the `return baz;` in
	--- `foo(); bar(); return baz;`.
	read last: AstLastStat?,
}

--- A full AST; a block ending with an eof.
export type Ast = {
	--- The block; the `foo(); bar(); return baz;` in
	--- `foo(); bar(); return baz;`.
	read block: AstBlock,

	--- This field is always `true` and exists to ensure that the AST is a
	--- unique type.
	read eof: true,
}

return {}