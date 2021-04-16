tool
extends Resource

const HfsmConstant = preload("../../../script/source/hfsm_constant.gd")

signal deleted(deleted_variable_res)
signal variable_res_param_updated

var variable_name :String setget _set_variable_name
func _set_variable_name(n:String):
	variable_name = n
	emit_signal("variable_res_param_updated")
var variable_type :int setget _set_varibale_type
func _set_varibale_type(t:int):
	variable_type = t
	emit_signal("variable_res_param_updated")
var variable_comment :String

var is_deleted :bool = false setget set_is_deleted,is_deleted
func set_is_deleted(v:bool):
	is_deleted = v
	if v:
		emit_signal("deleted" , self)
func is_deleted():
	return is_deleted
func _get_property_list():
	var properties :Array
	properties.push_back({name = "variable_name",type = TYPE_STRING,  usage = PROPERTY_USAGE_DEFAULT })
	properties.push_back({name = "variable_type",type = TYPE_INT , usage = PROPERTY_USAGE_DEFAULT })
	properties.push_back({name = "variable_comment",type = TYPE_STRING , usage = PROPERTY_USAGE_DEFAULT})
	
	properties.push_back({name = "is_deleted",type = TYPE_BOOL , usage = PROPERTY_USAGE_DEFAULT})

	return properties
	
	
func _init(_name:String="",_type :int = 0,_comment :String = ""):
	variable_name = _name
	variable_type = _type
	variable_comment = _comment
	
	
func deleted_self():
	set_is_deleted(true)

