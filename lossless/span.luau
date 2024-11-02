local cst = require("./cst")

local function unreachable(_: never): never
	error("unreachable")
end

local span_generic_declaration: (cst.GenericDeclaration) -> cst.Span
local span_generic_declaration_with_defaults: (cst.GenericDeclarationWithDefaults) -> cst.Span
local span_type_arg: (cst.TypeArg) -> cst.Span
local span_table_type_field: (cst.TableTypeField) -> cst.Span
local span_tail_type: (cst.TailType) -> cst.Span
local span_type: (cst.Type) -> cst.Span
local span_type_pack: (cst.TypePack) -> cst.Span
local span_return_type: (cst.ReturnType) -> cst.Span
local span_binding: (cst.Binding) -> cst.Span
local span_istring: (cst.IString) -> cst.Span
local span_if_else_expr_branch: (cst.IfElseExprBranch) -> cst.Span
local span_expr: (cst.Expr) -> cst.Span
local span_function_arg: (cst.FunctionArg) -> cst.Span
local span_var_root: (cst.VarRoot) -> cst.Span
local span_var_suffix: (cst.VarSuffix) -> cst.Span
local span_var: (cst.Var) -> cst.Span
local span_table_field: (cst.TableField) -> cst.Span
local span_table: (cst.Table) -> cst.Span
local span_function_body: (cst.FunctionBody) -> cst.Span
local span_if_stat_branch: (cst.IfStatBranch) -> cst.Span
local span_stat: (cst.Stat) -> cst.Span
local span_last_stat: (cst.LastStat) -> cst.Span
local span_block: (cst.Block) -> cst.Span

local function merge(left: cst.Span, right: cst.Span): cst.Span
	return {
		x = left.x,
		y = right.y,
		z = 0,
	}
end

function span_generic_declaration(node: cst.GenericDeclaration): cst.Span
	local angles = node.angles
	return merge(angles.open.span, angles.close.span)
end

function span_generic_declaration_with_defaults(node: cst.GenericDeclarationWithDefaults): cst.Span
	local angles = node.angles
	return merge(angles.open.span, angles.close.span)
end

function span_type_arg(node: cst.TypeArg): cst.Span
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

function span_table_type_field(node: cst.TableTypeField): cst.Span
	local access = node.access

	if access == nil then
		local span: cst.Span

		if node.kind == "nameprop" then
			span = node.name.span
		elseif node.kind == "stringprop" or node.kind == "indexer" then
			span = node.bracks.open.span
		else
			unreachable(node.kind)
		end

		return merge(span, span_type(node.type))
	else
		return merge(access.span, span_type(node.type))
	end
end

function span_tail_type(node: cst.TailType): cst.Span
	return span_type_pack(node)
end

function span_type(node: cst.Type): cst.Span
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
		node = node :: cst.Type_Paren -- Luau Bug
		local parens = node.parens

		return merge(
			parens.open.span,
			parens.close.span
		)
	elseif node.kind == "optional" then
		return merge(
			span_type(node.type),
			node.question.span
		)
	elseif node.kind == "union" or node.kind == "intersection" then
		node = node :: cst.Type_Union | cst.Type_Intersection -- Luau Bug

		local leading = node.leading
		local last = node.types[(#node.types :: any) :: number]

		return merge(
			if leading then leading.span else span_type(node.types[1].node),
			span_type(last.node)
		) :: cst.Span
	else
		return unreachable(node.kind)
	end
end

function span_type_pack(node: cst.TypePack): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_return_type(node: cst.ReturnType): cst.Span
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

function span_binding(node: cst.Binding): cst.Span
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

function span_istring(node: cst.IString): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_if_else_expr_branch(node: cst.IfElseExprBranch): cst.Span
	return merge(
		span_expr(node.condition),
		span_expr(node.body)
	)
end

function span_expr(node: cst.Expr): cst.Span
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
		node = node :: cst.Expr_IfElse -- Luau Bug

		return merge(
			node.if_tok.span,
			span_expr(node.else_body)
		)
	elseif node.kind == "var" then
		return span_var(node.var)
	elseif node.kind == "assertion" then
		node = node :: cst.Expr_Assertion -- Luau Bug

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
		node = node :: cst.Expr_Binary -- Luau Bug

		return merge(
			span_expr(node.left),
			span_expr(node.right)
		)
	else
		return unreachable(node.kind)
	end
end

function span_function_arg(node: cst.FunctionArg): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_var_root(node: cst.VarRoot): cst.Span
	if node.kind == "name" then
		return node.tok.span
	elseif node.kind == "paren" then
		return merge(
			node.parens.open.span,
			node.parens.close.span
		)
	else
		return unreachable(node.kind)
	end
end

function span_var_suffix(node: cst.VarSuffix): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_var(node: cst.Var): cst.Span
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

function span_table_field(node: cst.TableField): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_table(node: cst.Table): cst.Span
	local braces = node.braces
	return merge(
		braces.open.span,
		braces.close.span
	)
end

function span_function_body(node: cst.FunctionBody): cst.Span
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

function span_if_stat_branch(node: cst.IfStatBranch): cst.Span
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

function span_stat(node: cst.Stat): cst.Span
	if node.kind == "assign" then
		local first = node.left[1]
		local last = node.right[(#node.right :: any) :: number]

		return merge(
			span_var(first.node),
			span_expr(last.node)
		)
	elseif node.kind == "compoundassign" then
		node = node :: cst.Stat_CompoundAssign -- Luau Bug

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
		node = node :: cst.Stat_LocalFunction -- Luau Bug

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
		node = node :: cst.Stat_Type -- Luau Bug

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
		return unreachable(node.kind)
	end
end

function span_last_stat(node: cst.LastStat): cst.Span
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
		return unreachable(node.kind)
	end
end

function span_block(node: cst.Block): cst.Span
	local stats = node.stats
	local first = stats[1]
	local last_stat = node.last_stat

	if first == nil and last_stat == nil then
		error("attempt to get the span of an empty block")
	end

	if first == nil and last_stat ~= nil then
		local semicolon = last_stat.semicolon

		if semicolon then
			return merge(
				span_last_stat(last_stat.stat),
				semicolon.span
			)
		else
			return span_last_stat(last_stat.stat)
		end
	elseif last_stat ~= nil then
		local semicolon = last_stat.semicolon

		if semicolon then
			return merge(
				span_stat(first.node),
				semicolon.span
			)
		else
			return merge(
				span_stat(first.node),
				span_last_stat(last_stat.stat)
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

return {
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
	last_stat = span_last_stat,
	block = span_block,
}
