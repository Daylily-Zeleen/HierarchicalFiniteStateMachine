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
extends HBoxContainer

func VariableExpressionEditor()->void:
	pass
	
export(Color) var trigger_color :Color = Color.darkred
export(Color) var boolean_color :Color = Color.darkorange
export(Color) var integer_color :Color = Color.darkblue
export(Color) var float_color :Color = Color.darkslateblue
export(Color) var string_color :Color = Color.darkviolet

signal deleted(deleted_variable_expression_res)
signal params_updated

const Message = preload("../../message.gd")
const NestedFsmRes = preload("../../../script/source/nested_fsm_res.gd")
const VariableRes = NestedFsmRes.VariableRes
const VariableConditionRes = NestedFsmRes.TransitionRes.VariableConditionRes
const VariableExpressionRes = VariableConditionRes.VariableExpressionRes
#-------node------
onready var variable_type_label :Label = get_node("VariableTypeLabel")
onready var name_label:Label = get_node("NameLabel")
onready var not_number_comparation_button:MenuButton =get_node("NotNumberComparationButton")
onready var number_comparation_button :MenuButton = get_node("NumberComparationButton")
onready var boolean_value_button :MenuButton = get_node("BooleanValueButton")
onready var trigger_mode_button :MenuButton = get_node("TriggerModeButton")
onready var value_edit :LineEdit = get_node("ValueEdit")
enum {
	VARIABLE_TYPE_TRIGGER ,
	VARIABLE_TYPE_BOOLEAN , 
	VARIABLE_TYPE_INTEGER ,
	VARIABLE_TYPE_FLOAT ,
	VARIABLE_TYPE_STRING ,
}

const OPERATER_TEXT = [ "==" , "!=" , ">" , ">=" , "<" , "<="]
const BOOLEAN_VALUE_TEXT = [ "True" , "False"]
const TRIGGER_MODE_TEXT = [ "Force mode" , "Normal mode"]

func _get_not_num_op_type() ->int :
	for i in range(OPERATER_TEXT.size()) :
		if OPERATER_TEXT[i] == not_number_comparation_button.text :
			return i
	return 0
func _get_num_op_type() ->int :
	for i in range(OPERATER_TEXT.size()) :
		if OPERATER_TEXT[i] == number_comparation_button.text :
			return i
	return 0
func _get_boolean_value() ->int :
	for i in range(BOOLEAN_VALUE_TEXT.size()) :
		if BOOLEAN_VALUE_TEXT[i] == boolean_value_button.text :
			return i
	return 0
func _get_trigger_mode() ->int :
	for i in range(TRIGGER_MODE_TEXT.size()) :
		if TRIGGER_MODE_TEXT[i] == trigger_mode_button.text :
			return i
	return 0

var transition_editor setget _set_transition_editor
func _set_transition_editor(editor):
	transition_editor = editor
	self.variable_condition_res = transition_editor.variable_condition_res
	undo_redo = transition_editor.undo_redo
	message = transition_editor.message 
var undo_redo:UndoRedo
var message :Message
var variable_condition_res :VariableConditionRes


#表达式资源
var variable_expression_res :VariableExpressionRes setget _set_variable_expression_res
func _set_variable_expression_res(res :VariableExpressionRes):
	if transition_editor and transition_editor.variable_expression_res_list:
		if not res in transition_editor.variable_expression_res_list :
			transition_editor.variable_expression_res_list.append(res)
	if not res.is_connected("deleted" , transition_editor.inspector_res.variable_condition_res , "_on_variable_expression_res_deleted"):
		res.connect("deleted" , transition_editor.inspector_res.variable_condition_res , "_on_variable_expression_res_deleted",[],CONNECT_PERSIST)
	variable_expression_res = res
	_set_variable_res(res.variable_res)

#变量资源
var variable_res :VariableRes setget _set_variable_res ,_get_variable_res 
func _set_variable_res(res :VariableRes):
	variable_expression_res.variable_res = res
	if not res.is_connected("variable_res_param_updated" , self , "_on_variable_res_param_updated") :
		res.connect("variable_res_param_updated" , self , "_on_variable_res_param_updated",[],CONNECT_PERSIST)
	self.variable_type = variable_expression_res.variable_res.variable_type
	_set_variable_name(res.variable_name)
func _get_variable_res():
	return variable_expression_res.variable_res


#只读
export(int, "Trigger" , "Boolean","Integer","Float","String")var variable_type :int  = VARIABLE_TYPE_TRIGGER setget _set_variable_type,_get_variable_type
func _set_variable_type(type:int):
	variable_type = type
	var type_text :String 
	var tip :String 
	var bg_color:Color
	match type:
		VARIABLE_TYPE_TRIGGER :
			tip = "Trigger"
			type_text = "Trigger" if is_fold else "T" 
			bg_color = trigger_color
		VARIABLE_TYPE_BOOLEAN : 
			tip = "Boolean"
			type_text = "Boolean" if is_fold else "B"
			bg_color = boolean_color
		VARIABLE_TYPE_INTEGER :
			tip = "Integer"
			type_text = "Integer" if is_fold else "I"
			bg_color = integer_color
		VARIABLE_TYPE_FLOAT :
			tip = "Float"
			type_text = "Float" if is_fold else "F"
			bg_color = float_color
		VARIABLE_TYPE_STRING :
			tip = "String"
			type_text = "String" if is_fold else "S"
			bg_color = string_color
		
	variable_type_label.text = " " + type_text + " "
	variable_type_label.hint_tooltip = tip
	variable_type_label.get("custom_styles/normal").bg_color = bg_color
	not_number_comparation_button.visible = true if type in [VARIABLE_TYPE_BOOLEAN , VARIABLE_TYPE_STRING] else false
	number_comparation_button.visible = true if type in [VARIABLE_TYPE_INTEGER , VARIABLE_TYPE_FLOAT] else false
	boolean_value_button.visible = true if type == VARIABLE_TYPE_BOOLEAN else false
	value_edit.visible = true if type in[VARIABLE_TYPE_INTEGER ,VARIABLE_TYPE_FLOAT ,VARIABLE_TYPE_STRING]  else false
	trigger_mode_button.visible = true if type == VARIABLE_TYPE_TRIGGER else false
	
func _get_variable_type():
	get_node("NotNumberComparationButton").visible = true if variable_type in [VARIABLE_TYPE_BOOLEAN , VARIABLE_TYPE_STRING] else false
	get_node("NumberComparationButton").visible = true if variable_type in [VARIABLE_TYPE_INTEGER , VARIABLE_TYPE_FLOAT] else false
	get_node("BooleanValueButton").visible = true if variable_type == VARIABLE_TYPE_BOOLEAN else false
	get_node("ValueEdit").visible = true if variable_type in[VARIABLE_TYPE_INTEGER ,VARIABLE_TYPE_FLOAT ,VARIABLE_TYPE_STRING]  else false
	get_node("TriggerModeButton").visible = true if variable_type == VARIABLE_TYPE_TRIGGER else false
	
	return variable_type#variable_expression_res.variable_res.variable_type 
	
#只读
var variable_name :String setget _set_variable_name ,_get_variable_name 
func _set_variable_name(n:String) :
	name_label.text = " " + n + " "
func _get_variable_name():
	return variable_expression_res.variable_name 

#读写
var trigger_mode : int setget _set_trigger_mode , _get_trigger_mode_
func _set_trigger_mode(mode:int) :
	undo_redo.create_action("Set trigger_mode")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_VARIABLE_EXPRESSION_TRIGGET_MODE)
	undo_redo.add_undo_property(variable_expression_res , "trigger_mode" , _get_trigger_mode_())
	undo_redo.add_undo_method(self , "emit_signal" , "params_updated")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_VARIABLE_EXPRESSION_TRIGGET_MODE)
	undo_redo.add_do_property(variable_expression_res , "trigger_mode" , mode)
	undo_redo.add_do_method(self , "emit_signal" , "params_updated")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_VARIABLE_EXPRESSION_TRIGGET_MODE)

func _get_trigger_mode_ () :
	return variable_expression_res.trigger_mode
var comparation : int setget _set_comparation , _get_comparation 
func _set_comparation(c:int):
	undo_redo.create_action("Set comparation")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_VARIABLE_EXPRESSION_COMPARATION)
	undo_redo.add_undo_property(variable_expression_res , "comparation" , _get_comparation())
	undo_redo.add_undo_method(self , "emit_signal" , "params_updated")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_VARIABLE_EXPRESSION_COMPARATION)
	undo_redo.add_do_property(variable_expression_res , "comparation" , c)
	undo_redo.add_do_method(self , "emit_signal" , "params_updated")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_VARIABLE_EXPRESSION_COMPARATION)
	
func _get_comparation():
	return variable_expression_res.comparation
	
var value setget _set_value , _get_value
func _set_value(v) :
	variable_expression_res.value = v
	emit_signal("params_updated")
	message.set_history(Message.History.EDIT_VARIABLE_EXPRESSION_VALUE)

func _get_value():
	return variable_expression_res.value
	
var is_fold :bool setget _set_is_fold
func _set_is_fold(v :bool):
	is_fold = v
	get_node("MoveUpButton").visible = true if is_fold else false
	get_node("MoveDownButton").visible = true if is_fold else false
	self.variable_type = self.variable_type

var not_num_comparation_popup :PopupMenu
var num_comparation_popup :PopupMenu
var boolean_value_popup :PopupMenu
var trigger_mode_popup :PopupMenu
func _ready():
	for c in get_children():
		if c is MenuButton:
			c.flat = false
	not_num_comparation_popup = not_number_comparation_button.get_popup()
	num_comparation_popup = number_comparation_button.get_popup()
	boolean_value_popup = boolean_value_button.get_popup()
	trigger_mode_popup = trigger_mode_button.get_popup()
	
	not_num_comparation_popup.connect("index_pressed" , self ,"_on_Not_Number_Comparation_popup_index_pressed")
	num_comparation_popup.connect("index_pressed" , self ,"_on_Number_Comparation_popup_index_pressed")
	boolean_value_popup.connect("index_pressed" , self ,"_on_Boolean_Value_popup_index_pressed")
	trigger_mode_popup.connect("index_pressed" , self ,"_on_Trigger_Mode_popup_index_pressed")

#---------------methods------------------

#载入变量表达式
func init(_transition_editor , variable_expression_res :VariableExpressionRes) :
	if not is_inside_tree() :
		yield(self ,"ready")
	self.transition_editor = _transition_editor
	self.is_fold = transition_editor.root_fsm_res.transition_editor_folded
	_set_variable_expression_res(variable_expression_res)
	
	#trigger mode 
	trigger_mode_button.text = trigger_mode_popup.get_item_text(variable_expression_res.trigger_mode)
	#comparation
	if variable_expression_res.comparation < 1 :
		not_number_comparation_button.text = not_num_comparation_popup.get_item_text(variable_expression_res.comparation)
		number_comparation_button.text = num_comparation_popup.get_item_text(variable_expression_res.comparation)
	else :
		number_comparation_button.text = num_comparation_popup.get_item_text(variable_expression_res.comparation)
	#value 
	value_edit.text = str(variable_expression_res.value )
	if variable_expression_res.variable_res.variable_type == VARIABLE_TYPE_FLOAT :
		if not "." in value_edit.text :
			value_edit.text += ".0"
		elif value_edit.text.substr(value_edit.text.length()-1) == "." :
			value_edit.text += "0"
	

#---------------signals----------------------

func _on_Not_Number_Comparation_popup_index_pressed(index: int):
	not_number_comparation_button.text = not_num_comparation_popup.get_item_text(index)
	_set_comparation(index)
func _on_Number_Comparation_popup_index_pressed(index: int):
	number_comparation_button.text = num_comparation_popup.get_item_text(index)
	_set_comparation(index)
func _on_Boolean_Value_popup_index_pressed(index: int):
	boolean_value_button.text = boolean_value_popup.get_item_text(index)
	_set_value(true if index == 0 else false)
func _on_Trigger_Mode_popup_index_pressed(index: int):
	trigger_mode_button.text =  trigger_mode_popup.get_item_text(index)
	_set_trigger_mode(index)


func _on_ValueEdit_text_changed(new_text:String):
	if variable_type == VARIABLE_TYPE_INTEGER :
		if not value_edit.text.is_valid_integer():
			value_edit.text = str(int(new_text))
			value_edit.caret_position = value_edit.text.length() 
	elif variable_type == VARIABLE_TYPE_FLOAT:
		if not value_edit.text.is_valid_float():
			value_edit.text = str(float(new_text))
			value_edit.caret_position = value_edit.text.length() 
	_set_value(value_edit.text)
	
func _on_ValueEdit_text_entered(new_text):
	_on_ValueEdit_focus_exited()
	
func _on_ValueEdit_focus_exited():
	message.set_history(Message.History.EDIT_VARIABLE_EXPRESSION_VALUE)
	if variable_type == VARIABLE_TYPE_FLOAT:
		if not "." in value_edit.text :
			value_edit.text += ".0"
		elif value_edit.text.substr(value_edit.text.length()-1) == "." :
			value_edit.text += "0"
			
func delete_self():
	variable_expression_res.deleted_self()
	yield(get_tree() , "idle_frame")
	emit_signal("params_updated")
	queue_free()
	
func _on_DeletButton_pressed():
	undo_redo.create_action("Delete Variable expression")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.DELETE_VARIABLE_EXPRESSION)
	undo_redo.add_do_method(transition_editor , "delete_variable_expression_and_res",variable_expression_res)
	undo_redo.add_do_method(transition_editor.inspector_res ,"update_comment" )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.DELETE_VARIABLE_EXPRESSION)
	undo_redo.add_undo_method(transition_editor , "add_variable_expression",variable_expression_res,get_index())
	undo_redo.add_undo_method(transition_editor.inspector_res ,"update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.DELETE_VARIABLE_EXPRESSION)
	
func _on_MoveUpButton_pressed():
	if get_index()>0:
		undo_redo.create_action("Variable_expresion move up")
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.MOVE_VARIABLE_EXPRESSION_UP)
		undo_redo.add_undo_method(get_parent(),"move_child",self, get_index()+1)
		undo_redo.add_undo_method(variable_condition_res,"move_variable_expression_res",variable_expression_res, false)
		undo_redo.add_undo_method(self ,"emit_signal" , "params_updated")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.MOVE_VARIABLE_EXPRESSION_UP)
		undo_redo.add_do_method(get_parent(),"move_child",self, get_index()-1)
		undo_redo.add_do_method(variable_condition_res,"move_variable_expression_res",variable_expression_res, true)
		undo_redo.add_do_method(self ,"emit_signal" , "params_updated")
		undo_redo.commit_action()
		message.set_history(Message.History.MOVE_VARIABLE_EXPRESSION_UP)

	

func _on_MoveDownButton_pressed():
	if get_index()<get_parent().get_child_count() -1:
		undo_redo.create_action("Variable_expresion move down")
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.MOVE_VARIABLE_EXPRESSION_DOWN)
		undo_redo.add_undo_method(get_parent(),"move_child",self, get_index()-1)
		undo_redo.add_undo_method(variable_condition_res,"move_variable_expression_res",variable_expression_res, true)
		undo_redo.add_undo_method(self ,"emit_signal" , "params_updated")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.MOVE_VARIABLE_EXPRESSION_DOWN)
		undo_redo.add_do_method(get_parent(),"move_child",self, get_index()+1)
		undo_redo.add_do_method(variable_condition_res,"move_variable_expression_res",variable_expression_res, false)
		undo_redo.add_do_method(self ,"emit_signal" , "params_updated")
		undo_redo.commit_action()
		message.set_history(Message.History.MOVE_VARIABLE_EXPRESSION_DOWN)



#参数更新
func _on_variable_res_param_updated():
	_set_variable_type(_get_variable_res().variable_type)
	_set_variable_name(_get_variable_res().variable_name)
	emit_signal("params_updated")
	


