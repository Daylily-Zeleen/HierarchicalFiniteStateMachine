extends EditorInspectorPlugin


const HfsmInspectorResource = preload("hfsm_inspector_res.gd")
func can_handle(object):
	return object is HfsmInspectorResource


func parse_property(object, type, path, hint, hint_text, usage):
	if path == "active":
		return false
	elif path == "process_type" :
		return false
	elif path == "agents":
		return false
	elif path == "_disable_rename_to_snake_case" :
		return false
	elif path == "_force_all_state_entry_behavior" :
		return false
	elif path == "_force_all_fsm_entry_behavior" :
		return false

	return true
