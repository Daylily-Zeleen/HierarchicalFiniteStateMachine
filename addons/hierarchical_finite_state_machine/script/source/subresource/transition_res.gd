tool
extends Resource

const HfsmConstant = preload("../../../script/source/hfsm_constant.gd")
const StateRes = preload("state_res.gd")
const AutoConditionRes  = preload("transition_subresource/auto_condition_res.gd")
const ExpressionConditionRes = preload("transition_subresource/expression_condition_res.gd")
const VariableConditionRes = preload("transition_subresource/variable_condition_res.gd")

var from_res :StateRes = StateRes.new()
var to_res :StateRes = StateRes.new()
var transition_type :int = HfsmConstant.TRANSITION_TYPE_AUTO

var auto_condition_res :AutoConditionRes =null
var expression_condition_res :ExpressionConditionRes = null 
var variable_condition_res :VariableConditionRes = null 

func _get_property_list():
	var properties :Array
#		properties.push_back({name = "TransitionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "from_res" , type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource" })
	properties.push_back({name = "to_res",type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "transition_type",type = TYPE_INT  })
	properties.push_back({name = "auto_condition_res",type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "expression_condition_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "variable_condition_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	
	return properties
func _init(
		_from_res :StateRes = null ,
		_to_res:StateRes  = null, 
		_transition_type :int = HfsmConstant.TRANSITION_TYPE_AUTO ,
		_auto_condition_res :AutoConditionRes = AutoConditionRes.new() , 
		_expression_condition_res :ExpressionConditionRes = ExpressionConditionRes.new() ,
		_variable_condition_res :VariableConditionRes = VariableConditionRes.new() 
		):
	from_res = _from_res
	to_res = _to_res
	transition_type = _transition_type
	auto_condition_res = _auto_condition_res
	expression_condition_res = _expression_condition_res
	variable_condition_res = _variable_condition_res


func duplicate_self():
	var d := self.duplicate()
	d.auto_condition_res = auto_condition_res.duplicate()
	d.expression_condition_res = expression_condition_res.duplicate()
	d.variable_condition_res = variable_condition_res.duplicate()
	d.variable_condition_res.variable_expression_res_list = variable_condition_res.variable_expression_res_list.duplicate()
	d.variable_condition_res.variable_expression_res_list.clear()
	for v in variable_condition_res.variable_expression_res_list :
		d.variable_condition_res.variable_expression_res_list.append(v.duplicate())
	return d
