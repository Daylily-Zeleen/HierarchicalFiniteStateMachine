extends Button

signal switch_fsm_request(switch_button)

const NestedFsmRes = preload("../script/source/nested_fsm_res.gd") 
var hfsm_editor 
var nested_fsm_res:NestedFsmRes


func delete_self():
	queue_free()
	
func _init(_hfsm_editor , _nested_fsm_res:NestedFsmRes):
	hfsm_editor = _hfsm_editor
	nested_fsm_res = _nested_fsm_res
	text = nested_fsm_res.fsm_name
	name = nested_fsm_res.fsm_name
	nested_fsm_res.connect("fsm_name_changed" , self , "_on_fsm_name_changed")
	connect("pressed",self ,"_on_pressed")
	
func _on_fsm_name_changed(new_name:String):
	text = new_name
	name = new_name
	
func _on_pressed():
	emit_signal("switch_fsm_request" ,self)
