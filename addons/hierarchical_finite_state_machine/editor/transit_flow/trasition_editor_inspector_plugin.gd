extends EditorInspectorPlugin


const TransitionEditor = preload("editor_inspector_plugin/transition_editor.tscn")
const TransitionInspectRes = preload("transit_flow_inspector_res.gd")
func can_handle(object):
	return object is TransitionInspectRes


func parse_property(object, type, path, hint, hint_text, usage):
	if path == "condition_type":
		var transition_editor = TransitionEditor.instance()
		add_custom_control(transition_editor)
		if object is TransitionInspectRes :
			if not transition_editor.is_inside_tree():
				yield(transition_editor , "ready")
			transition_editor.owner = object.transit_flow.hfsm_editor.the_plugin.get_editor_interface().get_inspector()
			object.transit_flow.connect("connect_state_updated" , transition_editor , "_on_connect_state_updated")
			transition_editor.init(object)
			transition_editor._on_connect_state_updated()
			
		return true
	return true

		
