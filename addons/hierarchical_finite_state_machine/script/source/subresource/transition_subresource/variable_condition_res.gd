tool
extends Resource

const VariableExpressionRes = preload("variable_expression_res.gd")

const HfsmConstant = preload("../../../../script/source/hfsm_constant.gd")
		
var variable_op_mode :int =HfsmConstant.VARIABLE_CONDITION_OP_MODE_AND
var variable_expression_res_list :Array = []

func _get_property_list():
	var properties :Array
#			properties.push_back({name = "VariableConditionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "variable_op_mode" , type = TYPE_INT })
	properties.push_back({name = "variable_expression_res_list",type = TYPE_ARRAY })
	
	return properties
func add_variable_expression_res(variable_variable_expression_res :VariableExpressionRes , pos :int = -1):
	if variable_variable_expression_res and not variable_variable_expression_res in variable_expression_res_list :
		if pos == -1 :
			variable_expression_res_list.append(variable_variable_expression_res)
		else :
			variable_expression_res_list.insert(pos,variable_variable_expression_res)
			

func _on_variable_expression_res_deleted(deleted_variable_expression_res :VariableExpressionRes) :
	if deleted_variable_expression_res and deleted_variable_expression_res in variable_expression_res_list :
		variable_expression_res_list.erase(deleted_variable_expression_res)
		


func move_variable_expression_res(variable_expression_res:VariableExpressionRes, is_forward:bool):
	if variable_expression_res in variable_expression_res_list :
		var index := variable_expression_res_list.find(variable_expression_res)
		var target_index := index-1 if is_forward else index+1
		variable_expression_res_list[index] = variable_expression_res_list[target_index]
		variable_expression_res_list[target_index] = variable_expression_res

