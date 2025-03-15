--!optimize 2
--!nolint LocalShadow
local cst = require("./cst")

local function unreachable(_: never): never
	error("unreachable")
end

export type Visitor<State> = {
	visit_token: (state: State, token: cst.Token) -> (),

	visit_generic_declaration: (state: State, node: cst.GenericDeclaration) -> (),
	visit_generic_declaration_end: (state: State, node: cst.GenericDeclaration) -> (),

	visit_generic_declaration_with_defaults: (state: State, node: cst.GenericDeclarationWithDefaults) -> (),
	visit_generic_declaration_with_defaults_end: (state: State, node: cst.GenericDeclarationWithDefaults) -> (),

	visit_type_arg: (state: State, node: cst.TypeArg) -> (),
	visit_type_arg_end: (state: State, node: cst.TypeArg) -> (),

	visit_table_type_field_name_prop: (state: State, node: cst.TableTypeField_NameProp) -> (),
	visit_table_type_field_name_prop_end: (state: State, node: cst.TableTypeField_NameProp) -> (),
	visit_table_type_field_string_prop: (state: State, node: cst.TableTypeField_StringProp) -> (),
	visit_table_type_field_string_prop_end: (state: State, node: cst.TableTypeField_StringProp) -> (),
	visit_table_type_field_indexer: (state: State, node: cst.TableTypeField_Indexer) -> (),
	visit_table_type_field_indexer_end: (state: State, node: cst.TableTypeField_Indexer) -> (),
	visit_table_type_field: (state: State, node: cst.TableTypeField) -> (),
	visit_table_type_field_end: (state: State, node: cst.TableTypeField) -> (),

	visit_type_nil: (state: State, node: cst.Type_Nil) -> (),
	visit_type_nil_end: (state: State, node: cst.Type_Nil) -> (),
	visit_type_boolean: (state: State, node: cst.Type_Boolean) -> (),
	visit_type_boolean_end: (state: State, node: cst.Type_Boolean) -> (),
	visit_type_string: (state: State, node: cst.Type_String) -> (),
	visit_type_string_end: (state: State, node: cst.Type_String) -> (),
	visit_type_reference: (state: State, node: cst.Type_Reference) -> (),
	visit_type_reference_end: (state: State, node: cst.Type_Reference) -> (),
	visit_type_typeof: (state: State, node: cst.Type_Typeof) -> (),
	visit_type_typeof_end: (state: State, node: cst.Type_Typeof) -> (),
	visit_type_array: (state: State, node: cst.Type_Array) -> (),
	visit_type_array_end: (state: State, node: cst.Type_Array) -> (),
	visit_type_table: (state: State, node: cst.Type_Table) -> (),
	visit_type_table_end: (state: State, node: cst.Type_Table) -> (),
	visit_type_function: (state: State, node: cst.Type_Function) -> (),
	visit_type_function_end: (state: State, node: cst.Type_Function) -> (),
	visit_type_paren: (state: State, node: cst.Type_Paren) -> (),
	visit_type_paren_end: (state: State, node: cst.Type_Paren) -> (),
	visit_type_optional: (state: State, node: cst.Type_Optional) -> (),
	visit_type_optional_end: (state: State, node: cst.Type_Optional) -> (),
	visit_type_union: (state: State, node: cst.Type_Union) -> (),
	visit_type_union_end: (state: State, node: cst.Type_Union) -> (),
	visit_type_intersection: (state: State, node: cst.Type_Intersection) -> (),
	visit_type_intersection_end: (state: State, node: cst.Type_Intersection) -> (),
	visit_type: (state: State, node: cst.Type) -> (),
	visit_type_end: (state: State, node: cst.Type) -> (),

	visit_variadic_type_pack: (state: State, node: cst.VariadicTypePack) -> (),
	visit_variadic_type_pack_end: (state: State, node: cst.VariadicTypePack) -> (),

	visit_generic_type_pack: (state: State, node: cst.GenericTypePack) -> (),
	visit_generic_type_pack_end: (state: State, node: cst.GenericTypePack) -> (),

	visit_type_list: (state: State, node: cst.TypeList) -> (),
	visit_type_list_end: (state: State, node: cst.TypeList) -> (),

	visit_tail_type: (state: State, node: cst.TailType) -> (),
	visit_tail_type_end: (state: State, node: cst.TailType) -> (),

	visit_type_pack: (state: State, node: cst.TypePack) -> (),
	visit_type_pack_end: (state: State, node: cst.TypePack) -> (),

	visit_return_type: (state: State, node: cst.ReturnType) -> (),
	visit_return_type_end: (state: State, node: cst.ReturnType) -> (),

	visit_binding: (state: State, node: cst.Binding) -> (),
	visit_binding_end: (state: State, node: cst.Binding) -> (),

	visit_istring_simple: (state: State, node: cst.IString_Simple) -> (),
	visit_istring_simple_end: (state: State, node: cst.IString_Simple) -> (),
	visit_istring_complex: (state: State, node: cst.IString_Complex) -> (),
	visit_istring_complex_end: (state: State, node: cst.IString_Complex) -> (),
	visit_istring: (state: State, node: cst.IString) -> (),
	visit_istring_end: (state: State, node: cst.IString) -> (),

	visit_if_else_expr_branch: (state: State, node: cst.IfElseExprBranch) -> (),
	visit_if_else_expr_branch_end: (state: State, node: cst.IfElseExprBranch) -> (),

	visit_expr_nil: (state: State, node: cst.Expr_Nil) -> (),
	visit_expr_nil_end: (state: State, node: cst.Expr_Nil) -> (),
	visit_expr_boolean: (state: State, node: cst.Expr_Boolean) -> (),
	visit_expr_boolean_end: (state: State, node: cst.Expr_Boolean) -> (),
	visit_expr_number: (state: State, node: cst.Expr_Number) -> (),
	visit_expr_number_end: (state: State, node: cst.Expr_Number) -> (),
	visit_expr_string: (state: State, node: cst.Expr_String) -> (),
	visit_expr_string_end: (state: State, node: cst.Expr_String) -> (),
	visit_expr_varargs: (state: State, node: cst.Expr_Varargs) -> (),
	visit_expr_varargs_end: (state: State, node: cst.Expr_Varargs) -> (),
	visit_expr_istring: (state: State, node: cst.Expr_IString) -> (),
	visit_expr_istring_end: (state: State, node: cst.Expr_IString) -> (),
	visit_expr_table: (state: State, node: cst.Expr_Table) -> (),
	visit_expr_table_end: (state: State, node: cst.Expr_Table) -> (),
	visit_expr_function: (state: State, node: cst.Expr_Function) -> (),
	visit_expr_function_end: (state: State, node: cst.Expr_Function) -> (),
	visit_expr_if_else: (state: State, node: cst.Expr_IfElse) -> (),
	visit_expr_if_else_end: (state: State, node: cst.Expr_IfElse) -> (),
	visit_expr_var: (state: State, node: cst.Expr_Var) -> (),
	visit_expr_var_end: (state: State, node: cst.Expr_Var) -> (),
	visit_expr_assertion: (state: State, node: cst.Expr_Assertion) -> (),
	visit_expr_assertion_end: (state: State, node: cst.Expr_Assertion) -> (),
	visit_expr_unary: (state: State, node: cst.Expr_Unary) -> (),
	visit_expr_unary_end: (state: State, node: cst.Expr_Unary) -> (),
	visit_expr_binary: (state: State, node: cst.Expr_Binary) -> (),
	visit_expr_binary_end: (state: State, node: cst.Expr_Binary) -> (),
	visit_expr: (state: State, node: cst.Expr) -> (),
	visit_expr_end: (state: State, node: cst.Expr) -> (),

	visit_function_arg_pack: (state: State, node: cst.FunctionArg_Pack) -> (),
	visit_function_arg_pack_end: (state: State, node: cst.FunctionArg_Pack) -> (),
	visit_function_arg_table: (state: State, node: cst.FunctionArg_Table) -> (),
	visit_function_arg_table_end: (state: State, node: cst.FunctionArg_Table) -> (),
	visit_function_arg_string: (state: State, node: cst.FunctionArg_String) -> (),
	visit_function_arg_string_end: (state: State, node: cst.FunctionArg_String) -> (),
	visit_function_arg: (state: State, node: cst.FunctionArg) -> (),
	visit_function_arg_end: (state: State, node: cst.FunctionArg) -> (),

	visit_var_root_name: (state: State, node: cst.VarRoot_Name) -> (),
	visit_var_root_name_end: (state: State, node: cst.VarRoot_Name) -> (),
	visit_var_root_paren: (state: State, node: cst.VarRoot_Paren) -> (),
	visit_var_root_paren_end: (state: State, node: cst.VarRoot_Paren) -> (),
	visit_var_root: (state: State, node: cst.VarRoot) -> (),
	visit_var_root_end: (state: State, node: cst.VarRoot) -> (),

	visit_var_suffix_name_index: (state: State, node: cst.VarSuffix_NameIndex) -> (),
	visit_var_suffix_name_index_end: (state: State, node: cst.VarSuffix_NameIndex) -> (),
	visit_var_suffix_expr_index: (state: State, node: cst.VarSuffix_ExprIndex) -> (),
	visit_var_suffix_expr_index_end: (state: State, node: cst.VarSuffix_ExprIndex) -> (),
	visit_var_suffix_call: (state: State, node: cst.VarSuffix_Call) -> (),
	visit_var_suffix_call_end: (state: State, node: cst.VarSuffix_Call) -> (),
	visit_var_suffix: (state: State, node: cst.VarSuffix) -> (),
	visit_var_suffix_end: (state: State, node: cst.VarSuffix) -> (),

	visit_var: (state: State, node: cst.Var) -> (),
	visit_var_end: (state: State, node: cst.Var) -> (),

	visit_table_field_name_key: (state: State, node: cst.TableField_NameKey) -> (),
	visit_table_field_name_key_end: (state: State, node: cst.TableField_NameKey) -> (),
	visit_table_field_expr_key: (state: State, node: cst.TableField_ExprKey) -> (),
	visit_table_field_expr_key_end: (state: State, node: cst.TableField_ExprKey) -> (),
	visit_table_field_no_key: (state: State, node: cst.TableField_NoKey) -> (),
	visit_table_field_no_key_end: (state: State, node: cst.TableField_NoKey) -> (),
	visit_table_field: (state: State, node: cst.TableField) -> (),
	visit_table_field_end: (state: State, node: cst.TableField) -> (),

	visit_table: (state: State, node: cst.Table) -> (),
	visit_table_end: (state: State, node: cst.Table) -> (),

	visit_function_body: (state: State, node: cst.FunctionBody) -> (),
	visit_function_body_end: (state: State, node: cst.FunctionBody) -> (),

	visit_if_stat_branch: (state: State, node: cst.IfStatBranch) -> (),
	visit_if_stat_branch_end: (state: State, node: cst.IfStatBranch) -> (),

	visit_stat_assign: (state: State, node: cst.Stat_Assign) -> (),
	visit_stat_assign_end: (state: State, node: cst.Stat_Assign) -> (),
	visit_stat_compound_assign: (state: State, node: cst.Stat_CompoundAssign) -> (),
	visit_stat_compound_assign_end: (state: State, node: cst.Stat_CompoundAssign) -> (),
	visit_stat_call: (state: State, node: cst.Stat_Call) -> (),
	visit_stat_call_end: (state: State, node: cst.Stat_Call) -> (),
	visit_stat_do: (state: State, node: cst.Stat_Do) -> (),
	visit_stat_do_end: (state: State, node: cst.Stat_Do) -> (),
	visit_stat_while: (state: State, node: cst.Stat_While) -> (),
	visit_stat_while_end: (state: State, node: cst.Stat_While) -> (),
	visit_stat_repeat: (state: State, node: cst.Stat_Repeat) -> (),
	visit_stat_repeat_end: (state: State, node: cst.Stat_Repeat) -> (),
	visit_stat_if: (state: State, node: cst.Stat_If) -> (),
	visit_stat_if_end: (state: State, node: cst.Stat_If) -> (),
	visit_stat_numeric_for: (state: State, node: cst.Stat_NumericFor) -> (),
	visit_stat_numeric_for_end: (state: State, node: cst.Stat_NumericFor) -> (),
	visit_stat_for_in: (state: State, node: cst.Stat_ForIn) -> (),
	visit_stat_for_in_end: (state: State, node: cst.Stat_ForIn) -> (),
	visit_stat_function: (state: State, node: cst.Stat_Function) -> (),
	visit_stat_function_end: (state: State, node: cst.Stat_Function) -> (),
	visit_stat_local_function: (state: State, node: cst.Stat_LocalFunction) -> (),
	visit_stat_local_function_end: (state: State, node: cst.Stat_LocalFunction) -> (),
	visit_stat_type_function: (state: State, node: cst.Stat_TypeFunction) -> (),
	visit_stat_type_function_end: (state: State, node: cst.Stat_TypeFunction) -> (),
	visit_stat_local_variable: (state: State, node: cst.Stat_LocalVariable) -> (),
	visit_stat_local_variable_end: (state: State, node: cst.Stat_LocalVariable) -> (),
	visit_stat_type: (state: State, node: cst.Stat_Type) -> (),
	visit_stat_type_end: (state: State, node: cst.Stat_Type) -> (),
	visit_stat: (state: State, node: cst.Stat) -> (),
	visit_stat_end: (state: State, node: cst.Stat) -> (),

	visit_last_stat_return: (state: State, node: cst.LastStat_Return) -> (),
	visit_last_stat_return_end: (state: State, node: cst.LastStat_Return) -> (),
	visit_last_stat_break: (state: State, node: cst.LastStat_Break) -> (),
	visit_last_stat_break_end: (state: State, node: cst.LastStat_Break) -> (),
	visit_last_stat_continue: (state: State, node: cst.LastStat) -> (),
	visit_last_stat_continue_end: (state: State, node: cst.LastStat) -> (),
	visit_last_stat: (state: State, node: cst.LastStat) -> (),
	visit_last_stat_end: (state: State, node: cst.LastStat) -> (),

	visit_block: (state: State, node: cst.Block) -> (),
	visit_block_end: (state: State, node: cst.Block) -> (),

	visit_cst: (state: State, node: cst.Cst) -> (),
	visit_cst_end: (state: State, node: cst.Cst) -> (),
}

local function visitor<State>(): Visitor<State>
	local noop: any = function() end

	return {
		visit_token = noop,

		visit_generic_declaration = noop,
		visit_generic_declaration_end = noop,

		visit_generic_declaration_with_defaults = noop,
		visit_generic_declaration_with_defaults_end = noop,

		visit_type_arg = noop,
		visit_type_arg_end = noop,

		visit_table_type_field_name_prop = noop,
		visit_table_type_field_name_prop_end = noop,
		visit_table_type_field_string_prop = noop,
		visit_table_type_field_string_prop_end = noop,
		visit_table_type_field_indexer = noop,
		visit_table_type_field_indexer_end = noop,
		visit_table_type_field = noop,
		visit_table_type_field_end = noop,

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

		visit_variadic_type_pack = noop,
		visit_variadic_type_pack_end = noop,

		visit_generic_type_pack = noop,
		visit_generic_type_pack_end = noop,

		visit_type_list = noop,
		visit_type_list_end = noop,

		visit_tail_type = noop,
		visit_tail_type_end = noop,

		visit_type_pack = noop,
		visit_type_pack_end = noop,

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

		visit_if_else_expr_branch = noop,
		visit_if_else_expr_branch_end = noop,

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
		visit_expr_if_else = noop,
		visit_expr_if_else_end = noop,
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

		visit_var_suffix_name_index = noop,
		visit_var_suffix_name_index_end = noop,
		visit_var_suffix_expr_index = noop,
		visit_var_suffix_expr_index_end = noop,
		visit_var_suffix_call = noop,
		visit_var_suffix_call_end = noop,
		visit_var_suffix = noop,
		visit_var_suffix_end = noop,

		visit_var = noop,
		visit_var_end = noop,

		visit_table_field_name_key = noop,
		visit_table_field_name_key_end = noop,
		visit_table_field_expr_key = noop,
		visit_table_field_expr_key_end = noop,
		visit_table_field_no_key = noop,
		visit_table_field_no_key_end = noop,
		visit_table_field = noop,
		visit_table_field_end = noop,

		visit_table = noop,
		visit_table_end = noop,

		visit_function_body = noop,
		visit_function_body_end = noop,

		visit_if_stat_branch = noop,
		visit_if_stat_branch_end = noop,

		visit_stat_assign = noop,
		visit_stat_assign_end = noop,
		visit_stat_compound_assign = noop,
		visit_stat_compound_assign_end = noop,
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
		visit_stat_numeric_for = noop,
		visit_stat_numeric_for_end = noop,
		visit_stat_for_in = noop,
		visit_stat_for_in_end = noop,
		visit_stat_function = noop,
		visit_stat_function_end = noop,
		visit_stat_local_function = noop,
		visit_stat_local_function_end = noop,
		visit_stat_type_function = noop,
		visit_stat_type_function_end = noop,
		visit_stat_local_variable = noop,
		visit_stat_local_variable_end = noop,
		visit_stat_type = noop,
		visit_stat_type_end = noop,
		visit_stat = noop,
		visit_stat_end = noop,

		visit_last_stat_return = noop,
		visit_last_stat_return_end = noop,
		visit_last_stat_break = noop,
		visit_last_stat_break_end = noop,
		visit_last_stat_continue = noop,
		visit_last_stat_continue_end = noop,
		visit_last_stat = noop,
		visit_last_stat_end = noop,

		visit_block = noop,
		visit_block_end = noop,

		visit_cst = noop,
		visit_cst_end = noop,
	}
end

local visit_generic_declaration: <State>(visitor: Visitor<State>, state: State, node: cst.GenericDeclaration) -> ()
local visit_generic_declaration_with_defaults: <State>(visitor: Visitor<State>, state: State, node: cst.GenericDeclarationWithDefaults) -> ()
local visit_type: <State>(visitor: Visitor<State>, state: State, node: cst.Type) -> ()
local visit_tail_type: <State>(visitor: Visitor<State>, state: State, node: cst.TailType) -> ()
local visit_type_pack: <State>(visitor: Visitor<State>, state: State, node: cst.TypePack) -> ()
local visit_return_type: <State>(visitor: Visitor<State>, state: State, node: cst.ReturnType) -> ()
local visit_expr: <State>(visitor: Visitor<State>, state: State, node: cst.Expr) -> ()
local visit_var: <State>(visitor: Visitor<State>, state: State, node: cst.Var) -> ()
local visit_table: <State>(visitor: Visitor<State>, state: State, node: cst.Table) -> ()
local visit_function_body: <State>(visitor: Visitor<State>, state: State, node: cst.FunctionBody) -> ()
local visit_stat: <State>(visitor: Visitor<State>, state: State, node: cst.Stat) -> ()
local visit_last_stat: <State>(visitor: Visitor<State>, state: State, node: cst.LastStat) -> ()
local visit_block: <State>(visitor: Visitor<State>, state: State, node: cst.Block) -> ()

local function visit_token<State>(visitor: Visitor<State>, state: State, token: cst.Token)
	visitor.visit_token(state, token)
end

function visit_generic_declaration<State>(visitor: Visitor<State>, state: State, node: cst.GenericDeclaration)
	visitor.visit_generic_declaration(state, node)
	visit_token(visitor, state, node.angles.open)

	for _, pair in node.names do
		local node, sep = pair.node, pair.sep

		visit_token(visitor, state, node)

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	for _, pair in node.packs do
		local node, sep = pair.node, pair.sep

		visit_token(visitor, state, node.name)
		visit_token(visitor, state, node.dots)

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	visit_token(visitor, state, node.angles.close)
	visitor.visit_generic_declaration_end(state, node)
end

function visit_generic_declaration_with_defaults<State>(visitor: Visitor<State>, state: State, node: cst.GenericDeclarationWithDefaults)
	visitor.visit_generic_declaration_with_defaults(state, node)
	visit_token(visitor, state, node.angles.open)

	for _, pair in node.names do
		local node, sep = pair.node, pair.sep

		visit_token(visitor, state, node.name)

		local default = node.default
		if default then
			visit_token(visitor, state, default.equals)
			visit_type(visitor, state, default.type)
		end

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	for _, pair in node.packs do
		local node, sep = pair.node, pair.sep

		visit_token(visitor, state, node.name)
		visit_token(visitor, state, node.dots)

		local default = node.default
		if default then
			visit_token(visitor, state, default.equals)
			visit_type_pack(visitor, state, default.pack)
		end

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	visit_token(visitor, state, node.angles.close)
	visitor.visit_generic_declaration_with_defaults_end(state, node)
end

function visit_type<State>(visitor: Visitor<State>, state: State, node: cst.Type)
	visitor.visit_type(state, node)

	if node.kind == "nil" then
		visitor.visit_type_nil(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_type_nil_end(state, node)
	elseif node.kind == "boolean" then
		visitor.visit_type_boolean(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_type_boolean_end(state, node)
	elseif node.kind == "string" then
		visitor.visit_type_string(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_type_string_end(state, node)
	elseif node.kind == "reference" then
		node = node :: cst.Type_Reference
		visitor.visit_type_reference(state, node)

		local prefix = node.prefix
		if prefix then
			visit_token(visitor, state, prefix.name)
			visit_token(visitor, state, prefix.dot)
		end

		visit_token(visitor, state, node.name)

		local generics = node.generics
		if generics then
			visit_token(visitor, state, generics.angles.open)

			for _, pair in generics.types do
				local node, sep = pair.node, pair.sep

				visitor.visit_type_arg(state, node)

				if
					node.kind == "variadic"
					or node.kind == "generic"
					or node.kind == "list"
				then
					visit_type_pack(visitor, state, node)
				else
					visit_type(visitor, state, node)
				end

				visitor.visit_type_arg_end(state, node)

				if sep then
					visit_token(visitor, state, sep)
				end
			end

			visit_token(visitor, state, generics.angles.close)
		end

		visitor.visit_type_reference_end(state, node)
	elseif node.kind == "typeof" then
		visitor.visit_type_typeof(state, node)
		visit_token(visitor, state, node.typeof_tok)
		visit_token(visitor, state, node.parens.open)
		visit_expr(visitor, state, node.expr)
		visit_token(visitor, state, node.parens.close)
		visitor.visit_type_typeof_end(state, node)
	elseif node.kind == "array" then
		visitor.visit_type_array(state, node)
		visit_token(visitor, state, node.braces.open)
		visit_type(visitor, state, node.type)
		visit_token(visitor, state, node.braces.close)
		visitor.visit_type_array_end(state, node)
	elseif node.kind == "table" then
		visitor.visit_type_table(state, node)
		visit_token(visitor, state, node.braces.open)

		for _, pair in node.fields do
			local node, sep = pair.node, pair.sep

			visitor.visit_table_type_field(state, node)

			if node.kind == "nameprop" then
				visitor.visit_table_type_field_name_prop(state, node)

				local access = node.access
				if access then
					visit_token(visitor, state, access)
				end

				visit_token(visitor, state, node.name)
				visit_token(visitor, state, node.colon)
				visit_type(visitor, state, node.type)
				visitor.visit_table_type_field_name_prop_end(state, node)
			elseif node.kind == "stringprop" then
				visitor.visit_table_type_field_string_prop(state, node)

				local access = node.access
				if access then
					visit_token(visitor, state, access)
				end
				
				visit_token(visitor, state, node.bracks.open)
				visit_token(visitor, state, node.key)
				visit_token(visitor, state, node.bracks.close)
				visit_token(visitor, state, node.colon)
				visit_type(visitor, state, node.type)
				visitor.visit_table_type_field_string_prop_end(state, node)
			elseif node.kind == "indexer" then
				visitor.visit_table_type_field_indexer(state, node)

				local access = node.access
				if access then
					visit_token(visitor, state, access)
				end

				visit_token(visitor, state, node.bracks.open)
				visit_type(visitor, state, node.key)
				visit_token(visitor, state, node.bracks.close)
				visit_token(visitor, state, node.colon)
				visit_type(visitor, state, node.type)
				visitor.visit_table_type_field_indexer_end(state, node)
			else
				unreachable(node.kind)
			end

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visit_token(visitor, state, node.braces.close)
		visitor.visit_type_table_end(state, node)
	elseif node.kind == "function" then
		node = (node :: any) :: cst.Type_Function
		visitor.visit_type_function(state, node)
		
		local generics = node.generics
		if generics then
			visit_generic_declaration(visitor, state, generics)
		end

		visit_token(visitor, state, node.parens.open)

		for _, pair in node.params do
			local node, sep = pair.node, pair.sep

			local name = node.name
			if name then
				visit_token(visitor, state, name.name)
				visit_token(visitor, state, name.colon)
			end

			visit_type(visitor, state, node.type)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		local varargs = node.varargs
		if varargs then
			visit_tail_type(visitor, state, varargs)
		end

		visit_token(visitor, state, node.parens.close)
		visit_token(visitor, state, node.arrow)
		visit_return_type(visitor, state, node.ret)

		visitor.visit_type_function_end(state, node)
	elseif node.kind == "paren" then
		node = node :: cst.Type_Paren
		visitor.visit_type_paren(state, node)
		visit_token(visitor, state, node.parens.open)
		visit_type(visitor, state, node.type)
		visit_token(visitor, state, node.parens.close)
		visitor.visit_type_paren_end(state, node)
	elseif node.kind == "optional" then
		visitor.visit_type_optional(state, node)
		visit_type(visitor, state, node.type)
		visit_token(visitor, state, node.question)
		visitor.visit_type_optional_end(state, node)
	elseif node.kind == "union" then
		node = node :: cst.Type_Union
		visitor.visit_type_union(state, node)

		local leading = node.leading
		if leading then
			visit_token(visitor, state, leading)
		end

		for _, pair in node.types do
			local node, sep = pair.node, pair.sep

			visit_type(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visitor.visit_type_union_end(state, node)
	elseif node.kind == "intersection" then
		node = node :: cst.Type_Intersection
		visitor.visit_type_intersection(state, node)

		local leading = node.leading
		if leading then
			visit_token(visitor, state, leading)
		end

		for _, pair in node.types do
			local node, sep = pair.node, pair.sep

			visit_type(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visitor.visit_type_intersection_end(state, node)
	else
		unreachable(node.kind)
	end

	visitor.visit_type_end(state, node)
end

do
	local function visit_any_pack<State>(visitor: Visitor<State>, state: State, node: cst.TypePack)
		if node.kind == "variadic" then
			visitor.visit_variadic_type_pack(state, node)
			visit_token(visitor, state, node.dots)
			visit_type(visitor, state, node.type)
			visitor.visit_variadic_type_pack_end(state, node)
		elseif node.kind == "generic" then
			visitor.visit_generic_type_pack(state, node)
			visit_token(visitor, state, node.name)
			visit_token(visitor, state, node.dots)
			visitor.visit_generic_type_pack_end(state, node)
		elseif node.kind == "list" then
			visitor.visit_type_list(state, node)
			visit_token(visitor, state, node.parens.open)

			for _, pair in node.types do
				local node, sep = pair.node, pair.sep

				visit_type(visitor, state, node)

				if sep then
					visit_token(visitor, state, sep)
				end
			end

			local tail = node.tail
			if tail then
				visit_tail_type(visitor, state, tail)
			end

			visit_token(visitor, state, node.parens.close)
			visitor.visit_type_list_end(state, node)
		else
			unreachable(node.kind)
		end
	end

	function visit_tail_type<State>(visitor: Visitor<State>, state: State, node: cst.TailType)
		visitor.visit_tail_type(state, node)
		visit_any_pack(visitor, state, node)
		visitor.visit_tail_type_end(state, node)
	end

	function visit_type_pack<State>(visitor: Visitor<State>, state: State, node: cst.TypePack)
		visitor.visit_type_pack(state, node)
		visit_any_pack(visitor, state, node)
		visitor.visit_type_pack_end(state, node)
	end

	function visit_return_type<State>(visitor: Visitor<State>, state: State, node: cst.ReturnType)
		visitor.visit_return_type(state, node)

		if
			node.kind == "variadic"
			or node.kind == "generic"
			or node.kind == "list"
		then
			visit_type_pack(visitor, state, node)
		else
			visit_type(visitor, state, node)
		end

		visitor.visit_return_type_end(state, node)
	end
end

function visit_expr<State>(visitor: Visitor<State>, state: State, node: cst.Expr)
	visitor.visit_expr(state, node)

	if node.kind == "nil" then
		visitor.visit_expr_nil(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_expr_nil_end(state, node)
	elseif node.kind == "boolean" then
		visitor.visit_expr_boolean(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_expr_boolean_end(state, node)
	elseif node.kind == "number" then
		visitor.visit_expr_number(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_expr_number_end(state, node)
	elseif node.kind == "string" then
		visitor.visit_expr_string(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_expr_string_end(state, node)
	elseif node.kind == "varargs" then
		visitor.visit_expr_varargs(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_expr_varargs_end(state, node)
	elseif node.kind == "istring" then
		visitor.visit_expr_istring(state, node)
		
		local istring = node.istring
		visitor.visit_istring(state, istring)

		if istring.kind == "simple" then
			visitor.visit_istring_simple(state, istring)
			visit_token(visitor, state, istring.tok)
			visitor.visit_istring_simple_end(state, istring)
		elseif istring.kind == "complex" then
			visitor.visit_istring_complex(state, istring)
			visit_token(visitor, state, istring.first)

			for _, pair in istring.middle do
				local node, sep = pair.node, pair.sep

				visit_expr(visitor, state, node)

				if sep then
					visit_token(visitor, state, sep)
				end
			end

			visit_token(visitor, state, istring.last)
			visitor.visit_istring_complex_end(state, istring)
		else
			unreachable(istring.kind)
		end

		visitor.visit_istring_end(state, istring)
		visitor.visit_expr_istring_end(state, node)
	elseif node.kind == "table" then
		visitor.visit_expr_table(state, node)
		visit_table(visitor, state, node.table)
		visitor.visit_expr_table_end(state, node)
	elseif node.kind == "function" then
		visitor.visit_expr_function(state, node)

		for _, attribute in node.attributes do
			visit_token(visitor, state, attribute)
		end

		visit_token(visitor, state, node.function_tok)
		visit_function_body(visitor, state, node.body)
		visitor.visit_expr_function_end(state, node)
	elseif node.kind == "ifelse" then
		node = node :: cst.Expr_IfElse
		visitor.visit_expr_if_else(state, node)
		visit_token(visitor, state, node.if_tok)

		for _, pair in node.branches do
			local node, sep = pair.node, pair.sep

			visitor.visit_if_else_expr_branch(state, node)

			visit_expr(visitor, state, node.condition)
			visit_token(visitor, state, node.then_tok)
			visit_expr(visitor, state, node.body)

			visitor.visit_if_else_expr_branch_end(state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visit_token(visitor, state, node.else_tok)
		visit_expr(visitor, state, node.else_body)
		visitor.visit_expr_if_else_end(state, node)
	elseif node.kind == "var" then
		visitor.visit_expr_var(state, node)
		visit_var(visitor, state, node.var)
		visitor.visit_expr_var_end(state, node)
	elseif node.kind == "assertion" then
		node = node :: cst.Expr_Assertion
		visitor.visit_expr_assertion(state, node)
		visit_expr(visitor, state, node.expr)
		visit_token(visitor, state, node.colon)
		visit_type(visitor, state, node.type)
		visitor.visit_expr_assertion_end(state, node)
	elseif node.kind == "unary" then
		visitor.visit_expr_unary(state, node)
		visit_token(visitor, state, node.operator)
		visit_expr(visitor, state, node.expr)
		visitor.visit_expr_unary_end(state, node)
	elseif node.kind == "binary" then
		node = node :: cst.Expr_Binary
		visitor.visit_expr_binary(state, node)
		visit_expr(visitor, state, node.left)
		visit_token(visitor, state, node.operator)
		visit_expr(visitor, state, node.right)
		visitor.visit_expr_binary_end(state, node)
	else
		unreachable(node.kind)
	end

	visitor.visit_expr_end(state, node)
end

function visit_var<State>(visitor: Visitor<State>, state: State, node: cst.Var)
	visitor.visit_var(state, node)

	local root = node.root
	visitor.visit_var_root(state, root)

	if root.kind == "name" then
		visitor.visit_var_root_name(state, root)
		visit_token(visitor, state, root.tok)
		visitor.visit_var_root_name_end(state, root)
	elseif root.kind == "paren" then
		visitor.visit_var_root_paren(state, root)
		visit_token(visitor, state, root.parens.open)
		visit_expr(visitor, state, root.expr)
		visit_token(visitor, state, root.parens.close)
		visitor.visit_var_root_paren_end(state, root)
	else
		unreachable(root.kind)
	end

	visitor.visit_var_root_end(state, root)

	for _, suffix in node.suffixes do
		visitor.visit_var_suffix(state, suffix)

		if suffix.kind == "nameindex" then
			visitor.visit_var_suffix_name_index(state, suffix)
			visit_token(visitor, state, suffix.dot)
			visit_token(visitor, state, suffix.name)
			visitor.visit_var_suffix_name_index_end(state, suffix)
		elseif suffix.kind == "exprindex" then
			visitor.visit_var_suffix_expr_index(state, suffix)
			visit_token(visitor, state, suffix.bracks.open)
			visit_expr(visitor, state, suffix.expr)
			visit_token(visitor, state, suffix.bracks.close)
			visitor.visit_var_suffix_expr_index_end(state, suffix)
		elseif suffix.kind == "call" then
			visitor.visit_var_suffix_call(state, suffix)

			local method = suffix.method
			if method then
				visit_token(visitor, state, method.colon)
				visit_token(visitor, state, method.name)
			end

			local arg = suffix.arg
			visitor.visit_function_arg(state, arg)

			if arg.kind == "pack" then
				visitor.visit_function_arg_pack(state, arg)
				visit_token(visitor, state, arg.parens.open)

				for _, pair in arg.exprs do
					local node, sep = pair.node, pair.sep

					visit_expr(visitor, state, node)

					if sep then
						visit_token(visitor, state, sep)
					end
				end

				visit_token(visitor, state, arg.parens.close)
				visitor.visit_function_arg_pack_end(state, arg)
			elseif arg.kind == "table" then
				visitor.visit_function_arg_table(state, arg)
				visit_table(visitor, state, arg.table)
				visitor.visit_function_arg_table_end(state, arg)
			elseif arg.kind == "string" then
				visitor.visit_function_arg_string(state, arg)
				visit_token(visitor, state, arg.tok)
				visitor.visit_function_arg_string_end(state, arg)
			else
				unreachable(arg.kind)
			end
		else
			unreachable(suffix.kind)
		end

		visitor.visit_var_suffix_end(state, suffix)
	end

	visitor.visit_var_end(state, node)
end

function visit_table<State>(visitor: Visitor<State>, state: State, node: cst.Table)
	visitor.visit_table(state, node)
	visit_token(visitor, state, node.braces.open)

	for _, pair in node.fields do
		local node, sep = pair.node, pair.sep

		visitor.visit_table_field(state, node)

		if node.kind == "namekey" then
			visitor.visit_table_field_name_key(state, node)
			visit_token(visitor, state, node.name)
			visit_token(visitor, state, node.equals)
			visit_expr(visitor, state, node.value)
			visitor.visit_table_field_name_key_end(state, node)
		elseif node.kind == "exprkey" then
			visitor.visit_table_field_expr_key(state, node)
			visit_token(visitor, state, node.bracks.open)
			visit_expr(visitor, state, node.key)
			visit_token(visitor, state, node.bracks.close)
			visit_token(visitor, state, node.equals)
			visit_expr(visitor, state, node.value)
			visitor.visit_table_field_expr_key_end(state, node)
		elseif node.kind == "nokey" then
			visitor.visit_table_field_no_key(state, node)
			visit_expr(visitor, state, node.value)
			visitor.visit_table_field_no_key_end(state, node)
		else
			unreachable(node.kind)
		end

		visitor.visit_table_field_end(state, node)

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	visit_token(visitor, state, node.braces.close)
	visitor.visit_table_end(state, node)
end

function visit_function_body<State>(visitor: Visitor<State>, state: State, node: cst.FunctionBody)
	visitor.visit_function_body(state, node)
	
	local generics = node.generics
	if generics then
		visit_generic_declaration(visitor, state, generics)
	end

	visit_token(visitor, state, node.parens.open)

	for _, pair in node.params do
		local node, sep = pair.node, pair.sep

		visitor.visit_binding(state, node)
		visit_token(visitor, state, node.name)

		local type = node.type
		if type then
			visit_token(visitor, state, type.colon)
			visit_type(visitor, state, type.type)
		end

		visitor.visit_binding_end(state, node)

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	visit_token(visitor, state, node.parens.close)

	local varargs = node.varargs
	if varargs then
		visit_token(visitor, state, varargs.dots)

		local type = varargs.type
		if type then
			visit_token(visitor, state, type.colon)

			local type = type.type
			if type.kind == "generic" then
				visitor.visit_generic_type_pack(state, type)
				visit_token(visitor, state, type.name)
				visit_token(visitor, state, type.dots)
				visitor.visit_generic_type_pack_end(state, type)
			else
				visit_type(visitor, state, type)
			end
		end
	end

	local ret = node.ret
	if ret then
		visit_token(visitor, state, ret.colon)
		visit_return_type(visitor, state, ret.type)
	end

	visit_block(visitor, state, node.block)
	visit_token(visitor, state, node.end_tok)
	visitor.visit_function_body_end(state, node)
end

function visit_stat<State>(visitor: Visitor<State>, state: State, node: cst.Stat)
	visitor.visit_stat(state, node)

	if node.kind == "assign" then
		node = node :: cst.Stat_Assign
		visitor.visit_stat_assign(state, node)

		for _, pair in node.left do
			local node, sep = pair.node, pair.sep

			visit_var(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visit_token(visitor, state, node.equals)

		for _, pair in node.right do
			local node, sep = pair.node, pair.sep

			visit_expr(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visitor.visit_stat_assign_end(state, node)
	elseif node.kind == "compoundassign" then
		node = node :: cst.Stat_CompoundAssign
		visitor.visit_stat_compound_assign(state, node)
		visit_var(visitor, state, node.left)
		visit_token(visitor, state, node.operator)
		visit_expr(visitor, state, node.right)
		visitor.visit_stat_compound_assign_end(state, node)
	elseif node.kind == "call" then
		visitor.visit_stat_call(state, node)
		visit_var(visitor, state, node.call)
		visitor.visit_stat_call_end(state, node)
	elseif node.kind == "do" then
		visitor.visit_stat_do(state, node)
		visit_token(visitor, state, node.do_tok)
		visit_block(visitor, state, node.block)
		visit_token(visitor, state, node.end_tok)
		visitor.visit_stat_do_end(state, node)
	elseif node.kind == "while" then
		visitor.visit_stat_while(state, node)
		visit_token(visitor, state, node.while_tok)
		visit_expr(visitor, state, node.condition)
		visit_token(visitor, state, node.do_tok)
		visit_block(visitor, state, node.block)
		visit_token(visitor, state, node.end_tok)
		visitor.visit_stat_while_end(state, node)
	elseif node.kind == "repeat" then
		visitor.visit_stat_repeat(state, node)
		visit_token(visitor, state, node.repeat_tok)
		visit_block(visitor, state, node.block)
		visit_token(visitor, state, node.until_tok)
		visit_expr(visitor, state, node.condition)
		visitor.visit_stat_repeat_end(state, node)
	elseif node.kind == "if" then
		visitor.visit_stat_if(state, node)
		visit_token(visitor, state, node.if_tok)

		for _, pair in node.branches do
			local node, sep = pair.node, pair.sep

			visitor.visit_if_stat_branch(state, node)

			visit_expr(visitor, state, node.condition)
			visit_token(visitor, state, node.then_tok)
			visit_block(visitor, state, node.block)

			visitor.visit_if_stat_branch_end(state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		local else_branch = node.else_branch
		if else_branch then
			visit_token(visitor, state, else_branch.else_tok)
			visit_block(visitor, state, else_branch.block)
		end

		visit_token(visitor, state, node.end_tok)
		visitor.visit_stat_if_end(state, node)
	elseif node.kind == "numericfor" then
		visitor.visit_stat_numeric_for(state, node)
		visit_token(visitor, state, node.for_tok)

		local binding = node.binding
		visitor.visit_binding(state, binding)
		visit_token(visitor, state, binding.name)

		local type = binding.type
		if type then
			visit_token(visitor, state, type.colon)
			visit_type(visitor, state, type.type)
		end

		visitor.visit_binding_end(state, binding)

		visit_token(visitor, state, node.equals)
		visit_expr(visitor, state, node.start_expr)
		visit_token(visitor, state, node.comma)
		visit_expr(visitor, state, node.end_expr)

		local step = node.step
		if step then
			visit_token(visitor, state, step.comma)
			visit_expr(visitor, state, step.expr)
		end

		visit_token(visitor, state, node.do_tok)
		visit_block(visitor, state, node.block)
		visit_token(visitor, state, node.end_tok)
		visitor.visit_stat_numeric_for_end(state, node)
	elseif node.kind == "forin" then
		node = node :: cst.Stat_ForIn
		visitor.visit_stat_for_in(state, node)
		visit_token(visitor, state, node.for_tok)
		
		for _, pair in node.bindings do
			local node, sep = pair.node, pair.sep

			visitor.visit_binding(state, node)
			visit_token(visitor, state, node.name)

			local type = node.type
			if type then
				visit_token(visitor, state, type.colon)
				visit_type(visitor, state, type.type)
			end

			visitor.visit_binding_end(state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visit_token(visitor, state, node.in_tok)

		for _, pair in node.exprs do
			local node, sep = pair.node, pair.sep

			visit_expr(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visit_token(visitor, state, node.do_tok)
		visit_block(visitor, state, node.block)
		visit_token(visitor, state, node.end_tok)
		visitor.visit_stat_for_in_end(state, node)
	elseif node.kind == "function" then
		visitor.visit_stat_function(state, node)
		
		for _, tok in node.attributes do
			visit_token(visitor, state, tok)
		end

		visit_token(visitor, state, node.function_tok)

		for _, pair in node.names do
			local node, sep = pair.node, pair.sep

			visit_token(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		local method = node.method
		if method then
			visit_token(visitor, state, method.colon)
			visit_token(visitor, state, method.name)
		end

		visit_function_body(visitor, state, node.body)
		visitor.visit_stat_function_end(state, node)
	elseif node.kind == "localfunction" then
		node = node :: cst.Stat_LocalFunction
		visitor.visit_stat_local_function(state, node)
		
		for _, tok in node.attributes do
			visit_token(visitor, state, tok)
		end

		visit_token(visitor, state, node.local_tok)
		visit_token(visitor, state, node.function_tok)
		visit_token(visitor, state, node.name)
		visit_function_body(visitor, state, node.body)
		visitor.visit_stat_local_function_end(state, node)
	elseif node.kind == "typefunction" then
		node = node :: cst.Stat_TypeFunction

		--[[
		node = node :: cst.Stat_Type
		visitor.visit_stat_type(state, node)
		
		local export_tok = node.export_tok
		if export_tok then
			visit_token(visitor, state, export_tok)
		end

		visit_token(visitor, state, node.type_tok)
		visit_token(visitor, state, node.name)
		
		local generics = node.generics
		if generics then
			visit_generic_declaration_with_defaults(visitor, state, generics)
		end

		visit_token(visitor, state, node.equals)
		visit_type(visitor, state, node.type)
		visitor.visit_stat_type_end(state, node)
		]]

		visitor.visit_stat_type_function(state, node)

		local export_tok = node.export_tok
		if export_tok then
			visit_token(visitor, state, export_tok)
		end

		visit_token(visitor, state, node.type_tok)
		visit_token(visitor, state, node.function_tok)
		visit_token(visitor, state, node.name)
		
		visit_function_body(visitor, state, node.body)
		visitor.visit_stat_type_function_end(state, node)
	elseif node.kind == "localvariable" then
		node = node :: cst.Stat_LocalVariable
		visitor.visit_stat_local_variable(state, node)
		visit_token(visitor, state, node.local_tok)

		for _, pair in node.bindings do
			local node, sep = pair.node, pair.sep

			visit_token(visitor, state, node.name)

			local type = node.type
			if type then
				visit_token(visitor, state, type.colon)
				visit_type(visitor, state, type.type)
			end

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		local values = node.values
		if values then
			visit_token(visitor, state, values.equals)

			for _, pair in values.exprs do
				local node, sep = pair.node, pair.sep

				visit_expr(visitor, state, node)

				if sep then
					visit_token(visitor, state, sep)
				end
			end
		end

		visitor.visit_stat_local_variable_end(state, node)
	elseif node.kind == "type" then
		node = node :: cst.Stat_Type
		visitor.visit_stat_type(state, node)
		
		local export_tok = node.export_tok
		if export_tok then
			visit_token(visitor, state, export_tok)
		end

		visit_token(visitor, state, node.type_tok)
		visit_token(visitor, state, node.name)
		
		local generics = node.generics
		if generics then
			visit_generic_declaration_with_defaults(visitor, state, generics)
		end

		visit_token(visitor, state, node.equals)
		visit_type(visitor, state, node.type)
		visitor.visit_stat_type_end(state, node)
	end

	visitor.visit_stat_end(state, node)
end

function visit_last_stat<State>(visitor: Visitor<State>, state: State, node: cst.LastStat)
	visitor.visit_last_stat(state, node)

	if node.kind == "return" then
		visitor.visit_last_stat_return(state, node)
		visit_token(visitor, state, node.return_tok)

		for _, pair in node.exprs do
			local node, sep = pair.node, pair.sep

			visit_expr(visitor, state, node)

			if sep then
				visit_token(visitor, state, sep)
			end
		end

		visitor.visit_last_stat_return_end(state, node)
	elseif node.kind == "break" then
		visitor.visit_last_stat_break(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_last_stat_break_end(state, node)
	elseif node.kind == "continue" then
		visitor.visit_last_stat_continue(state, node)
		visit_token(visitor, state, node.tok)
		visitor.visit_last_stat_continue_end(state, node)
	else
		unreachable(node.kind)
	end

	visitor.visit_last_stat_end(state, node)
end

function visit_block<State>(visitor: Visitor<State>, state: State, block: cst.Block)
	visitor.visit_block(state, block)

	for _, pair in block.stats do
		local node, sep = pair.node, pair.sep

		visit_stat(visitor, state, node)

		if sep then
			visit_token(visitor, state, sep)
		end
	end

	local last_stat = block.last_stat
	if last_stat then
		visit_last_stat(visitor, state, last_stat.stat)

		local semicolon = last_stat.semicolon
		if semicolon then
			visit_token(visitor, state, semicolon)
		end
	end

	visitor.visit_block_end(state, block)
end

local function visit<State>(visitor: Visitor<State>, state: State, node: cst.Cst)
	visitor.visit_cst(state, node)
	visit_block(visitor, state, node.block)
	visit_token(visitor, state, node.eof)
	visitor.visit_cst_end(state, node)
end

return {
	visitor = visitor,
	visit = visit,
}
