tool
extends GraphNode


const NestedFsmRes = preload("../script/source/nested_fsm_res.gd")
const VariableEditor = preload("variable_editor.gd")
const Message = preload("message.gd")


var undo_redo :UndoRedo
var message :Message

var the_plugin :EditorPlugin 

var hfsm_editor
var _root_fsm_res :NestedFsmRes setget _set_root_fsm_res
func _set_root_fsm_res(res :NestedFsmRes):
	_root_fsm_res = res
	_load_variables()

	
#var variable_res_list:Array setget _set_variable_res_list , _get_variable_res_list
#func _set_variable_res_list(list :Array) :
#	_root_fsm_res.variable_res_list = list
#func _get_variable_res_list():
#	return _root_fsm_res.variable_res_list


func _load_variables():
	if _root_fsm_res :
		for v in _root_fsm_res.variable_res_list :
			if v is NestedFsmRes.VariableRes and not v in get_children():
				add_new_variable_editor(v)
	
#初始化设置
func init(_hfsm_editor,_root_fsm_res :NestedFsmRes):
	for i in get_children() :
		if i is VariableEditor :
			i.queue_free()
	hfsm_editor = _hfsm_editor
	message = _hfsm_editor.message
	undo_redo = _hfsm_editor.undo_redo
	_set_root_fsm_res(_root_fsm_res)
	set_deferred("rect_size",Vector2.ZERO)
	
	
func deleted_variable_editor_and_res(variable_res:VariableEditor.VariableRes):
	for c in get_children() :
		if c is VariableEditor :
			if c.variable_res == variable_res :
				c.deleted_self()
		
func _process(delta):
	if not the_plugin and hfsm_editor and hfsm_editor.the_plugin :
		the_plugin = hfsm_editor.the_plugin
		
	if hfsm_editor and hfsm_editor.enable :
		var exist_name :Array
		for c in get_children() :
			if c is VariableEditor :
				if c.name_edit.text in exist_name or c.name_edit.text.length() == 0:
					c.set_warning(true)
				else:
					c.set_warning(false)
					exist_name.append(c.name_edit.text)
			
func _on_FsmVariableNode_resize_request(new_minsize):
	set_deferred("rect_size" , new_minsize)


func add_new_variable_editor(res:NestedFsmRes.VariableRes,pos:int = -1)->VariableEditor:
	res.is_deleted = false
	_root_fsm_res.add_variable(res,pos)
	var new_variable_editor = preload("variable_editor.tscn").instance()
	new_variable_editor.undo_redo = undo_redo
	new_variable_editor.message = message
	new_variable_editor._root_fsm_res = _root_fsm_res
	add_child(new_variable_editor)
	if pos ==-1:
		move_child(new_variable_editor,new_variable_editor.get_index()-1)
	else:
		move_child(new_variable_editor , pos)
	if not res.is_connected("deleted",hfsm_editor.current_hfsm._root_fsm_res , "_on_variable_res_deleted"):
		res.connect("deleted",hfsm_editor.current_hfsm._root_fsm_res , "_on_variable_res_deleted",[],CONNECT_PERSIST)
	new_variable_editor.set_fold(is_fold)
	new_variable_editor.init( res)

	return new_variable_editor
	
		
func _on_AddButton_pressed():
	var variable_res :NestedFsmRes.VariableRes = NestedFsmRes.VariableRes.new()
	action_add_new_variable(variable_res)
	
var is_fold :bool = true
onready var fold_button :Button = get_node("OpButtons/FoldButton")
func _on_FoldButton_pressed():
	action_switch_is_fold(!is_fold)
	
func switch_is_fold(_is_fold:bool) :
	is_fold = _is_fold
	if is_fold :
		fold_button.text = ">>"
	else :
		fold_button.text = "<<"
	for v in get_children() :
		if v is VariableEditor :
			v.set_fold(is_fold)
	yield(get_tree(),"idle_frame")
	set_deferred("rect_size" , Vector2.ZERO)

func _on_VariableList_close_request():
	switch_visible(false)
	
func switch_visible(visible :bool, _offset:Vector2 = offset):
	action_switch_visible(visible ,_offset)
#----------------undo redo--------------------
func action_switch_visible(new:bool , _offset:Vector2):
	undo_redo.create_action("Switch variable_list_visiblle")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SWITCH_VARIABLE_LIST_VISIBLE)
	undo_redo.add_do_property(self , "offset", _offset )
	undo_redo.add_do_property(self , "visible", new )
	undo_redo.add_do_property(self , "selected", true if new else false )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SWITCH_VARIABLE_LIST_VISIBLE)
	undo_redo.add_undo_property(self , "offset", offset )
	undo_redo.add_undo_property(self , "visible", !new )
	undo_redo.add_undo_property(self , "selected", true )
	undo_redo.commit_action()
	message.set_history(Message.History.SWITCH_VARIABLE_LIST_VISIBLE)
	
func action_switch_is_fold(new:bool ):
	undo_redo.create_action("Switch is_fold")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SWITCH_VARIABLE_LIST_FOLDING_STATE)
	undo_redo.add_do_method(self , "switch_is_fold" ,new)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SWITCH_VARIABLE_LIST_FOLDING_STATE)
	undo_redo.add_undo_method(self , "switch_is_fold" , !new)
	undo_redo.commit_action()
	message.set_history(Message.History.SWITCH_VARIABLE_LIST_FOLDING_STATE)


func _undo_add_new_variable_editor(res:NestedFsmRes.VariableRes):
	for c in get_children():
		if c is VariableEditor and c.variable_res == res:
			c._on_DeletButton_pressed()
			
func action_add_new_variable(variable_res : NestedFsmRes.VariableRes):
	undo_redo.create_action("Add new variable")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.ADD_VARIABLE)
	undo_redo.add_do_method(self , "add_new_variable_editor" ,variable_res )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.ADD_VARIABLE)
	undo_redo.add_undo_method(self , "_undo_add_new_variable_editor" ,variable_res )
	undo_redo.commit_action()
	message.set_history(Message.History.ADD_VARIABLE)

func _on_VariableList_dragged(from, to):
	undo_redo.create_action("Drag Variable List")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.DRAG_VARIABLE_LIST)
	undo_redo.add_do_property(self , "offset" ,to )
	undo_redo.add_do_property(hfsm_editor.current_nested_fsm_res , "variable_list_offset", to)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.DRAG_VARIABLE_LIST)
	undo_redo.add_undo_property(self , "offset" ,from )
	undo_redo.add_undo_property(hfsm_editor.current_nested_fsm_res , "variable_list_offset", to)
	undo_redo.commit_action()
	message.set_history(Message.History.DRAG_VARIABLE_LIST)


func do_delete_related_expression(data_dict:Dictionary):
	for t_res in data_dict.keys() :
		for v_e in data_dict[t_res] :
			t_res.variable_condition_res._on_variable_expression_res_deleted(v_e)
	hfsm_editor.refresh_transition_comment()
			
func undo_delete_related_expression(data_dict:Dictionary):
	for t_res in data_dict.keys() :
		for v_e in data_dict[t_res] :
			t_res.variable_condition_res.add_variable_expression_res(v_e)
	hfsm_editor.refresh_transition_comment()



