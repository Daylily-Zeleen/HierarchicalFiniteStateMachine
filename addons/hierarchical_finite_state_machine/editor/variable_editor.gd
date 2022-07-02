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
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Remove _custom_class_list, change "tarnsited" signal param to static type.            
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
tool
extends Control

const Message = preload("message.gd")
const HfsmConstant = preload("../script/source/hfsm_constant.gd")
const TransitionEditor = preload("transit_flow/editor_inspector_plugin/transition_editor.gd")
const NestedFsmRes = preload("../script/source/nested_fsm_res.gd")
const TransitionRes = NestedFsmRes.TransitionRes
const VariableRes = NestedFsmRes.VariableRes
const VariableExpressionRes = TransitionRes.VariableConditionRes.VariableExpressionRes

#-------node------
onready var variable_type_button :OptionButton = get_node("VariableEditor/VariableEditor/ValueTypeButton")
onready var name_edit:LineEdit = get_node("VariableEditor/VariableEditor/NameEdit")
onready var drag_button:Button = get_node("VariableEditor/DragButton")

onready var up_button :Button = get_node("VariableEditor/VariableEditor/MoveUpButton")
onready var down_button :Button = get_node("VariableEditor/VariableEditor/MoveDownButton")
onready var comment_edit : LineEdit = get_node("VariableEditor/VariableEditor/CommentEdit")

var _root_fsm_res :NestedFsmRes
var undo_redo :UndoRedo
var message :Message
var is_fold :bool = true setget set_fold 
func set_fold(v):
	is_fold = v
	up_button.visible = false if v else true 
	down_button.visible = false if v else true 
	comment_edit.visible = false if v else true 
	
var is_warning :bool setget set_warning
func set_warning(v:bool)->void:
	is_warning = v 
	if is_warning :
		name_edit.modulate = Color.red
		drag_button.hint_tooltip = "This variable name is already exists or empty , and will be ignored when running."
	else :
		name_edit.modulate = Color.white
		drag_button.hint_tooltip = ""
	
var _is_focus :bool = true

var variable_res:VariableRes setget _set_variable_res #,_get_variable_res
func _set_variable_res(res :VariableRes):
	variable_res = res

var variable_name :String = "" setget _set_variable_name ,_get_variable_name 
func _set_variable_name(new_name :String):
	variable_res.variable_name = new_name
func _get_variable_name():
	return variable_res.variable_name

var variable_comment :String = "" setget _set_variable_comment ,_get_variable_comment
func _set_variable_comment(new_comment:String) :
	variable_res.variable_comment = new_comment
func _get_variable_comment():
	return variable_res.variable_comment
	
		
var variable_type :int  = HfsmConstant.VARIABLE_TYPE_TRIGGER setget set_variable_type,get_variable_type
func set_variable_type(type:int):
	undo_redo.create_action("Set variable_type")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_VARIABLE_TYPE)
	undo_redo.add_undo_property(variable_res , "variable_type" , get_variable_type())
	undo_redo.add_undo_property(variable_type_button,"selected",get_variable_type())
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_VARIABLE_TYPE)
	undo_redo.add_do_property(variable_res , "variable_type" , type)
	undo_redo.add_do_property(variable_type_button,"selected",type)
	undo_redo.commit_action()
	message.set_history(Message.History.SET_VARIABLE_TYPE)
func get_variable_type():
	return variable_res.variable_type
	
var not_num_op_popup :PopupMenu
var num_op_popup :PopupMenu
var boolean_value_popup :PopupMenu
var trigger_mode_popup :PopupMenu
func _ready():
	set_fold(get_parent().is_fold)
	
var selected_variable_data : VariableExpressionRes
func _process(delta):
	if not _is_mouse_inside() :
		_is_focus = false
		drag_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
	if selected_variable_data :
		#確認拖到東西
		if not Input.is_mouse_button_pressed(BUTTON_LEFT) :
			#鬆開左鍵時
			_drag_and_add_variable_condition()
			selected_variable_data = null
	elif not _is_focus :
		#拖了個寂寞
		set_process(false)
		
			
		
#---------------methods------------------
func _is_mouse_inside() :
	return drag_button.get_rect().has_point(drag_button.get_parent().get_local_mouse_position())

func _iterator(node:Node)->Array :
	var nodes:Array 
	for c in node.get_children() :
		nodes.append(c)
	for c in node.get_children() :
		if c.get_child_count() >0:
			for c_c in c.get_children():
				nodes.append(c_c)
	return nodes

func _drag_and_add_variable_condition():
	if selected_variable_data:
		var inspector:EditorInspector = (get_parent().the_plugin as EditorPlugin).get_editor_interface().get_inspector()
		var nodes = _iterator(inspector.get_child(0))
		var transition_editor 
		for node in nodes:
			if node is TransitionEditor:
				transition_editor =  node
		if transition_editor :
			var mouse_pos :Vector2 = transition_editor.variable_expression_editor_list.get_parent().get_local_mouse_position()
			if transition_editor.variable_expression_editor_list.visible and transition_editor.variable_expression_editor_list.get_rect().has_point(mouse_pos):
				transition_editor.add_variable_expression(selected_variable_data)
				

func init(res:VariableRes):
	_set_variable_res(res)
	name_edit.text = res.variable_name
	variable_type_button.select(res.variable_type)
	comment_edit.text = res.variable_comment
	
func deleted_self():
	variable_res.deleted_self()
	queue_free()
#---------------signals----------------------
func _on_ValueTypeButton_item_selected(index):
	set_variable_type(index)

func _on_CommentEdit_text_changed(new_text):
	message.set_history(Message.History.EDIT_VARIABLE_COMMENT)
	_set_variable_comment(new_text)
func _on_NameEdit_text_changed(new_text):
	get_parent().hfsm_editor.refresh_transition_comment()
	message.set_history(Message.History.EDIT_VARIABLE_NAME)
	_set_variable_name(new_text)
	
func _iterator_transition_res_to_expression_list(_root_fsm_res:NestedFsmRes) ->Dictionary:
	var transition_res_to_expression_list:Dictionary
	for t in _root_fsm_res.transition_res_list:
		for v in t.variable_condition_res.variable_expression_res_list:
			if v.variable_res == variable_res:
				if not t in transition_res_to_expression_list.keys():
					transition_res_to_expression_list[t] = [v]
				else:
					transition_res_to_expression_list[t].append(v)
	for s in _root_fsm_res.state_res_list :
		if s.nested_fsm_res:
			var tmp:Dictionary = _iterator_transition_res_to_expression_list(s.nested_fsm_res)
			for k in tmp.keys():
				transition_res_to_expression_list[k] = tmp[k]
	return transition_res_to_expression_list

func _on_DeletButton_pressed():
	var data_dict:Dictionary = _iterator_transition_res_to_expression_list(_root_fsm_res)
	undo_redo.create_action("Delete variable")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.DELETED_VARIABLE)
	undo_redo.add_do_method(get_parent(),"deleted_variable_editor_and_res" ,variable_res )
	undo_redo.add_do_method(get_parent(),"do_delete_related_expression" ,data_dict )
	undo_redo.add_do_property(variable_res,"is_deleted",true)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.DELETED_VARIABLE)
	undo_redo.add_undo_property(variable_res,"is_deleted",false)
	undo_redo.add_undo_method(get_parent(),"undo_delete_related_expression" ,data_dict )
	undo_redo.add_undo_method(get_parent() , "add_new_variable_editor" ,variable_res , get_index() )
	undo_redo.commit_action()
	message.set_history(Message.History.DELETED_VARIABLE)
	
func _on_MoveUpButton_pressed():
	if get_index()>0:
		undo_redo.create_action("Variable move up")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.MOVE_VARIABLE_UP)
		undo_redo.add_do_method(get_parent(),"move_child",self , get_index()-1)
		undo_redo.add_do_method(_root_fsm_res , "move_variable" , variable_res,true)
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.MOVE_VARIABLE_UP)
		undo_redo.add_undo_method(get_parent(),"move_child",self , get_index()+1)
		undo_redo.add_undo_method(_root_fsm_res , "move_variable" , variable_res,false)
		undo_redo.commit_action()
		message.set_history(Message.History.MOVE_VARIABLE_UP)
		

func _on_MoveDownButton_pressed():
	if get_index()<get_parent().get_child_count() -2:
		undo_redo.create_action("Variable move down")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.MOVE_VARIABLE_DOWN)
		undo_redo.add_do_method(get_parent(),"move_child",self , get_index()+1)
		undo_redo.add_do_method(_root_fsm_res , "move_variable" , variable_res,false)
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.MOVE_VARIABLE_DOWN)
		undo_redo.add_undo_method(get_parent(),"move_child",self , get_index()-1)
		undo_redo.add_undo_method(_root_fsm_res , "move_variable" , variable_res,true)
		undo_redo.commit_action()
		message.set_history(Message.History.MOVE_VARIABLE_DOWN)

func _on_DragButton_pressed():
	drag_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_is_focus = true 
	set_process(true)

func _on_DragButton_gui_input(event):
	if drag_button.get_rect().has_point(get_local_mouse_position()) :
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if not is_warning and not name_edit.text in ["",null]:
				selected_variable_data = VariableExpressionRes.new(variable_res ,0 , 0 ,"")
				set_process(true)

