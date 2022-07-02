##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  daylily-zeleen@foxmail.com. 
#                                                  
#	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#	Hirerarchical Finite State Machine - Trial Version(HFSM - Trial Version)   
#     
#                 
#	This file is part of HFSM - Trial Version.
#                                                                
#	HFSM -Triabl Version is free Godot Plugin: you can redistribute it and/or 
#modify it under the terms of the GNU Lesser General Public License as published 
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#	HFSM -Triabl Version is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public License
#along with HFSM -Triabl Version.  If not, see <http://www.gnu.org/licenses/>.                                                                          *
#
#	HFSM -Triabl Version是一个自由Godot插件，您可以自由分发、修改其中的源
#代码或者重新发布它，新的任何修改后的重新发布版必须同样在遵守LGPL3或更后续的
#版本协议下发布.关于LGPL协议的细则请参考COPYING、COPYING.LESSER文件，
#	您可以在HFSM -Triabl Version的相关目录中获得LGPL协议的副本，
#如果没有找到，请连接到 http://www.gnu.org/licenses/ 查看。
#
#
#	This is HFSM‘s triable version ,but it contain almost features of the full version
#(please read the READEME.md to learn difference.).If this plugin is useful for you,
#please consider to support me by getting the full version.
#
#	虽然这是HFSM的试用版本，但是几乎包含了完整版本的所有功能(请阅读README.md了解他们的差异)。如果这个
#插件对您有帮助，请考虑通过获取完整版本来支持我。
#	
# Sponsor link (赞助链接): 
#	https://afdian.net/@Daylily-Zeleen
#	https://godotmarketplace.com/?post_type=product&p=37138   
#
#                                    
#	@author   Daylily-Zeleen                                                      
#	@email    daylily-zeleen@foxmail.com. @qq.com                                              
#	@version  0.8(版本号)                                                       
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)  
#                                                                      
#----------------------------------------------------------------------------
#  Remark         :                                          
#----------------------------------------------------------------------------
#  Change History :                                                          
#  <Date>     | <Version> | <Author>       | <Description>                   
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file                 
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
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



