extends Resource

const TransitionRes = preload("../../script/source/nested_fsm_res.gd").TransitionRes
var transit_flow 
#-------------------
var from_state setget ,get_from_state
func get_from_state():
	if transit_flow:
		return transit_flow.from.state_name
	return "Null" 
var to_state setget ,get_to_state
func get_to_state():
	if transit_flow:
		return transit_flow.to.state_name
	return "Null"

var transition_type :int setget set_transition_type , get_transition_type
func set_transition_type(type:int):
	if transit_flow:
		transit_flow.transition_type = type
func get_transition_type():
	if transit_flow:
		return transit_flow.transition_type
	return 0

var auto_condition_res :TransitionRes.AutoConditionRes =TransitionRes.AutoConditionRes.new() setget _set_auto_condition_res , _get_auto_condition_res
func _set_auto_condition_res(auto_res:TransitionRes.AutoConditionRes ) :
	if transit_flow:
		transit_flow.auto_condition_res = auto_res
func _get_auto_condition_res():
	if transit_flow:
		return transit_flow.auto_condition_res
		
var expression_condition_res :TransitionRes.ExpressionConditionRes = TransitionRes.ExpressionConditionRes.new() setget _set_expression_condition_res , _get_expression_condition_res
func _set_expression_condition_res(expresstion_res :TransitionRes.ExpressionConditionRes):
	if transit_flow:
		transit_flow.expression_condition_res = expresstion_res
func _get_expression_condition_res():
	if transit_flow:
		return transit_flow.expression_condition_res
		
var variable_condition_res :TransitionRes.VariableConditionRes = TransitionRes.VariableConditionRes.new() setget _set_variable_condition_res , _get_variable_condition_res
func _set_variable_condition_res(variable_res:TransitionRes.VariableConditionRes):
	if transit_flow:
		transit_flow.variable_condition_res = variable_res
func _get_variable_condition_res():
	if transit_flow:
		return transit_flow.variable_condition_res

func _init(_transit_flow):
	transit_flow = _transit_flow


func _get_property_list():
	var properties :Array
	properties.push_back({name = "Transition",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "from_state",type = TYPE_STRING })
	properties.push_back({name = "to_state",type = TYPE_STRING })
	properties.push_back({name = "condition_type",type = TYPE_INT })
	
	
	return properties
	
func update_comment():
	if transit_flow :
		transit_flow.update_comment()
