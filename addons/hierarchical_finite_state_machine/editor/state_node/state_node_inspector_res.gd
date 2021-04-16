extends Resource
const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
const NestedFsmRes = preload("../../script/source/nested_fsm_res.gd")

var state_node :GraphNode
##-------------------
var state_name :String setget _set_state_name , _get_state_name 
func _set_state_name(n :String):
	state_node.state_name = n
func _get_state_name():
	if state_node :
		return state_node.state_name
	

var state_type :int setget _set_state_type , _get_state_type
func _set_state_type(t :int) :
	state_node.action_set_state_type(state_node.state_type , t)
	state_node.state_type = t
func _get_state_type():
	if state_node:
		return state_node.state_type
	

var state_script :Script setget _set_state_script , _get_state_script
func _set_state_script(s:Script):
	state_node._load_state_script(s)
func _get_state_script():
	if state_node:
		return state_node.state_script

var is_nested :bool setget _set_is_nested , _get_is_nested
func _set_is_nested(i :bool):
	state_node.action_set_is_nested(state_node.is_nested , i)

func _get_is_nested ():
	if state_node:
		return state_node.is_nested
var reset_properties_when_entry:bool setget _set_reset_properties_when_entry,_get_reset_properties_when_entry
func _set_reset_properties_when_entry(v:bool):
	state_node.action_set_reset_properties_when_entry(v)
	property_list_changed_notify ()
func _get_reset_properties_when_entry():
	if state_node:
		return state_node.reset_properties_when_entry 
var nested_fsm_res :NestedFsmRes

var reset_nested_fsm_when_entry:bool setget _set_reset_nested_fsm_when_entry , _get_reset_nested_fsm_when_entry
func _set_reset_nested_fsm_when_entry(v:bool):
	state_node.action_set_reset_nested_fsm_when_entry(v)
	yield(state_node.get_tree(),"idle_frame")
	property_list_changed_notify ()
func _get_reset_nested_fsm_when_entry():
	if state_node:
		return state_node.reset_nested_fsm_when_entry

func _init(_state_node):
	state_node = _state_node


func _get_property_list():
	var properties :Array
	properties.push_back({name = "State",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "state_name",type = TYPE_STRING })
	properties.push_back({name = "state_type",type = TYPE_INT , hint = PROPERTY_HINT_ENUM , hint_string = "Normal,ENTRY,EXIT" })
	properties.push_back({name = "reset_properties_when_entry",type = TYPE_BOOL })
	properties.push_back({name = "state_script",type = TYPE_OBJECT , hint =  PROPERTY_HINT_RESOURCE_TYPE  , hint_string = "GDScript"})
	properties.push_back({name = "is_nested",type = TYPE_BOOL })
	if _get_is_nested () :
		properties.push_back({name = "reset_nested_fsm_when_entry",type = TYPE_BOOL })
		properties.push_back({name = "nested_fsm_res",type = TYPE_OBJECT , hint =  PROPERTY_HINT_RESOURCE_TYPE ,usage = PROPERTY_USAGE_STORAGE })

	return properties

