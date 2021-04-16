extends EditorInspectorPlugin


const StateInspectorResource = preload("state_node_inspector_res.gd")
func can_handle(object):
	return object is StateInspectorResource


func parse_property(object, type, path, hint, hint_text, usage):
	if path == "state_name":
		return false
	elif path == "state_type" :
		return false
	elif path == "state_script":
		return false
	elif path == "is_nested" :
		return false
	elif path == "nested_fsm_res" :
		return false
	elif path == "reset_nested_fsm_when_entry" :
		return false
	elif path == "reset_properties_when_entry" :
		return false

	return true
