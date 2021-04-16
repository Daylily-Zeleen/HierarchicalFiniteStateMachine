tool
extends Resource

const VariableRes = preload("../variable_res.gd")
const HfsmConstant = preload("./../../../../script/source/hfsm_constant.gd")

signal deleted(deleted_variable_variable_expression_res )
var variable_res :VariableRes
var trigger_mode :int = HfsmConstant.TRIGGER_MODE_FORCE 
var comparation :int = HfsmConstant.COMPARATION_EQUEAL
var value setget _set_value ,_get_value
func _set_value(v) :
	value  = str(v)
func _get_value():
	match variable_res.variable_type :
		HfsmConstant.VARIABLE_TYPE_BOOLEAN:
			return true if value == "true" else "false"
		HfsmConstant.VARIABLE_TYPE_STRING:
			return value
		HfsmConstant.VARIABLE_TYPE_INTEGER:
			return int(value) 
		HfsmConstant.VARIABLE_TYPE_FLOAT:
			return float(value)
func _get_property_list():
	var properties :Array
	
	properties.push_back({name = "variable_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE,hint_string = "Resource" })
	properties.push_back({name = "trigger_mode",type = TYPE_INT })
	properties.push_back({name = "comparation",type = TYPE_INT })
	properties.push_back({name = "value",type = TYPE_STRING })

	return properties
func _init(_variable_res:VariableRes = null, _trigger_mode :int = HfsmConstant.TRIGGER_MODE_FORCE , _comparation :int = HfsmConstant.COMPARATION_EQUEAL , _value = null):
	variable_res =_variable_res
	if _variable_res and not _variable_res.is_connected("deleted" , self , "_on_VariableRes_deleted") :
		_variable_res.connect("deleted" , self , "_on_VariableRes_deleted",[],CONNECT_PERSIST)
	trigger_mode = _trigger_mode
	comparation = _comparation
	value = str(_value)
	
func _on_VariableRes_deleted(variable_res):
	emit_signal("deleted" , self)
	
func deleted_self():
	emit_signal("deleted" , self)

func is_valid():
	return false if variable_res.is_deleted else true
	
