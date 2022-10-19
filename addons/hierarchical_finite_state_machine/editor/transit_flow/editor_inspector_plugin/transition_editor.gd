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
#	@version  0.9(版本号)
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)
#
#----------------------------------------------------------------------------
#  Remark         :
#----------------------------------------------------------------------------
#  Change History :
#  <Date>     | <Version> | <Author>       | <Description>
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file
#  2021/07/2 | 0.8   | Daylily-Zeleen      | Support script transition(full version)
#  2021/09/18 | 0.9   | Daylily-Zeleen      | fix trail version bug: can't change transition type.
#----------------------------------------------------------------------------
#
##############################################################################
tool
extends VBoxContainer
const Message = preload("../../message.gd")
const HfsmConstant = preload("../../../script/source/hfsm_constant.gd")
const VariableExpressionEditor = preload("variable_expression_editor.gd")
const TransitFlow =preload("../transit_flow.gd")
const TransitflowInspectorRes =preload("../transit_flow_inspector_res.gd")
const NestedFsmRes = preload("../../../script/source/nested_fsm_res.gd")
const TransitionRes = NestedFsmRes.TransitionRes
const VariableExpressionRes = TransitionRes.VariableConditionRes.VariableExpressionRes
var root_fsm_res :NestedFsmRes
var inspector_res :TransitflowInspectorRes setget _set_inspector_res
func _set_inspector_res(res):
	inspector_res = res
	root_fsm_res = inspector_res.transit_flow.hfsm_editor.current_hfsm._root_fsm_res
	_on_FoldButton_toggled(root_fsm_res.transition_editor_folded)
#	fold_button.pressed = root_fsm_res.transition_editor_folded
var transition_editor_folded :bool = false setget _set_transition_editor_folded , _get_transition_editor_folded
func _set_transition_editor_folded(v:bool):
	root_fsm_res.transition_editor_folded = v
func _get_transition_editor_folded():
	return root_fsm_res.transition_editor_folded
var undo_redo: UndoRedo
var message :Message

onready var from_label :Label =get_node("FromLabel")
onready var to_label :Label =get_node("ToLabel")
onready var fold_button :Button = get_node("InspectTitle/HBoxContainer/FoldButton")

func _on_connect_state_updated():
	if inspector_res and inspector_res.transit_flow:
		if inspector_res.transit_flow.from :
			from_label.text ="From : " + inspector_res.transit_flow.from.state_name
		else :
			from_label.text ="From : NULL"
		if inspector_res.transit_flow.to :
			to_label.text ="To   : "+ inspector_res.transit_flow.to.state_name
		else :
			to_label.text ="To   : NULL "

var transition_type :int = HfsmConstant.TRANSITION_TYPE_AUTO setget _set_transition_type ,_get_transition_type
func _set_transition_type(type)->void:
	action_set_transition_type(_get_transition_type() , type)

func _get_transition_type():
	return inspector_res.transition_type



#------------------automode_properties-------------------------------------
var auto_transit_mode :int = HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER setget _set_auto_transit_mode , _get_auto_transit_mode
func _set_auto_transit_mode (t:int):
	action_auto_transit_mode(_get_auto_transit_mode() , t)

func _get_auto_transit_mode() :
	return inspector_res.auto_condition_res.auto_transit_mode

var delay_time :float = 1.0 setget _set_delay_time , _get_delay_time
func _set_delay_time(t :float) :
	action_set_delay_time(_get_delay_time(),t)

func _get_delay_time ():
	return inspector_res.auto_condition_res.delay_time

var times :int = 5 setget _set_times , _get_times
func _set_times(t:int) :
	action_set_times(_get_times() , t)

func _get_times():
	return inspector_res.auto_condition_res.times

#---------------------expression properties-----------------------------
var expression_text :String setget _set_expression_string , _get_expression_string
func _set_expression_string(expression:String):
	inspector_res.expression_condition_res.expression_text = expression
	_uptate_transition_comment()
func _get_expression_string():
	return inspector_res.expression_condition_res.expression_text


var expression_comment :String setget _set_expression_comment , _get_expression_comment
func _set_expression_comment(comment:String):
	inspector_res.expression_condition_res.expression_comment = comment
	_uptate_transition_comment()
func _get_expression_comment():
	return inspector_res.expression_condition_res.expression_comment

#--------------------------variable properties------------------------------------------------
var variable_condition_res :NestedFsmRes.TransitionRes.VariableConditionRes setget _set_variable_condition_res , _get_variable_condition_res
func _set_variable_condition_res(v):
	inspector_res.variable_condition_res = v
	_uptate_transition_comment()
func _get_variable_condition_res():
	return inspector_res.variable_condition_res
var variable_op_mode :int = HfsmConstant.VARIABLE_CONDITION_OP_MODE_AND setget _set_variable_op_mode , _get_variable_op_mode
func _set_variable_op_mode(mode :int) :
	action_set_variable_condition_operate_mode(_get_variable_op_mode() ,mode )
func _get_variable_op_mode() :
	return inspector_res.variable_condition_res.variable_op_mode
var variable_expression_res_list :Array = [] setget _set_variable_expression_res_list , _get_variable_expression_res_list
func _set_variable_expression_res_list(res_list:Array) :
	inspector_res.variable_condition_res.variable_expression_res_list = res_list
	_uptate_transition_comment()
func _get_variable_expression_res_list():
	return inspector_res.variable_condition_res.variable_expression_res_list



onready var auto_mode_button :OptionButton = get_node("Editor/AutoEditor/Panel/VBoxContainer/Title/AutoModeButton")
onready var times_edit :LineEdit = get_node("Editor/AutoEditor/Panel/VBoxContainer/TimesEditor/TimesEdit")
onready var delay_time_edit : LineEdit = get_node("Editor/AutoEditor/Panel/VBoxContainer/DelayTimerEditor/DelayTimerEdit")
onready var variable_expression_editor_list:Control = get_node("Editor/VariableEditor/Panel/ScrollContainer/VariableExpressionEditorList")
onready var transition_type_button :OptionButton = get_node("InspectTitle/HBoxContainer/TransitionTypeOptionButton")
onready var variable_op_mode_button :OptionButton = get_node("Editor/VariableEditor/VariableOpModeButton")
onready var expression :TextEdit = get_node("Editor/ExpressionEditior/Expression")
onready var comment :TextEdit = get_node("Editor/ExpressionEditior/Comment")
#-----------method---------------
func add_variable_expression(variable_expression_res :VariableExpressionRes,pos :int = -1):
	if _get_transition_type() != HfsmConstant.TRANSITION_TYPE_VARIABLE:
		message.set_error(Message.Error.NOT_AT_VARIABLE_CONDITION_MODE)
		return
	for i in variable_expression_editor_list.get_children() :
		if (i as VariableExpressionEditor).variable_expression_res.variable_res == variable_expression_res.variable_res :
			message.set_error(Message.Error.VARIABLE_EXPRESSION_ALREADY_EXIST)
			return
	_get_variable_condition_res().add_variable_expression_res(variable_expression_res,pos)
	var expression_editor = _add_variable_expression_editor()
	expression_editor.init(self , variable_expression_res)
	if pos != -1:
		expression_editor.get_parent().move_child(expression_editor,pos)
	if not variable_expression_res.is_connected("deleted",inspector_res.transit_flow ,"_on_VariableExpressionRes_deleted"):
		variable_expression_res.connect("deleted",inspector_res.transit_flow ,"_on_VariableExpressionRes_deleted",[],CONNECT_PERSIST)
	message.set_tip(Message.Tip.ADD_VARIABLE_EXPRESSION_SUCCESS)
	inspector_res.update_comment()




func delete_variable_expression_and_res(variable_expression_res :VariableExpressionRes):
	for c in variable_expression_editor_list.get_children() :
		if c is VariableExpressionEditor and c.variable_expression_res == variable_expression_res:
			(c as VariableExpressionEditor).delete_self()


func init(_inspector_res :TransitflowInspectorRes):
	self.inspector_res = _inspector_res
	undo_redo = inspector_res.transit_flow.undo_redo
	message = inspector_res.transit_flow.message
	if not is_inside_tree() :
		yield(self,"ready")
	#type
	get_node("Editor/ExpressionEditior").visible = true if inspector_res.transition_type == HfsmConstant.TRANSITION_TYPE_EXPRESSION else false

	get_node("Editor/VariableEditor").visible = true if inspector_res.transition_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false
	get_node("InspectTitle/HBoxContainer/FoldButton").visible = true if inspector_res.transition_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false

	get_node("Editor/AutoEditor").visible = true if inspector_res.transition_type == HfsmConstant.TRANSITION_TYPE_AUTO else false
	get_node("Editor/AutoEditor/Panel/VBoxContainer/TipLabel").text = _get_tip_text(inspector_res.transition_type)

#	get_node()
	transition_type_button.select(inspector_res.transition_type)
	#auto
	auto_mode_button.select(inspector_res.auto_condition_res.auto_transit_mode)
	delay_time_edit.text = str(inspector_res.auto_condition_res.delay_time)
	times_edit.text = str(inspector_res.auto_condition_res.times)
	get_node("Editor/AutoEditor/Panel/VBoxContainer/DelayTimerEditor").visible = true if inspector_res.auto_condition_res.auto_transit_mode == HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER else false
	get_node("Editor/AutoEditor/Panel/VBoxContainer/TimesEditor").visible = true if inspector_res.auto_condition_res.auto_transit_mode in [ HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES ,  HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES] else false
	get_node("Editor/AutoEditor/Panel/VBoxContainer/TipLabel").text = _get_tip_text(inspector_res.auto_condition_res.auto_transit_mode)

	#expression
	expression.text = inspector_res.expression_condition_res.expression_text
	comment.text = inspector_res.expression_condition_res.expression_comment
	if comment.text.length() == 0:
		comment.text = HfsmConstant.ExpressionCommentDefaultText
	#variable
	variable_op_mode_button.select(inspector_res.variable_condition_res.variable_op_mode)
	for variable_expression_res in inspector_res.variable_condition_res.variable_expression_res_list :
		if variable_expression_res.is_valid():
			_add_variable_expression_editor().init(self ,variable_expression_res)
		else :
			inspector_res.variable_condition_res._on_variable_expression_res_deleted(variable_expression_res)

func _add_variable_expression_editor() -> VariableExpressionEditor:
	var new_expression = preload("variable_expression_editor.tscn").instance()
	variable_expression_editor_list.add_child(new_expression)
	new_expression.connect("params_updated" , self , "_uptate_transition_comment")
	if inspector_res:
		inspector_res.variable_condition_res.add_variable_expression_res(VariableExpressionRes.new())
	return new_expression


#------------signal--------------
func _on_TransitionTypeOptionButton_item_selected(index):
	_set_transition_type(index)


func _uptate_transition_comment():
	inspector_res.update_comment()

#----------expression signal--------------
func _on_Expression_text_changed():
	message.set_history(Message.History.EDIT_EXPRESSTION_CONDITION_TEXT)
	#更新表达式
	_set_expression_string(expression.text)

func _on_Comment_text_changed():
	if comment.text and comment.text != "" :
		var last_ascii:int= comment.text.substr(comment.text.length()-1).to_ascii()[0]
		if not(("a".to_ascii()[0]<= last_ascii and last_ascii<="z".to_ascii()[0]) or
			("A".to_ascii()[0]<= last_ascii and last_ascii<="Z".to_ascii()[0]) or
			("0".to_ascii()[0]<= last_ascii and last_ascii<="9".to_ascii()[0]) or
			last_ascii == "_".to_ascii()[0]):
			old_comment = comment.text
	else:
		old_comment = comment.text
	message.set_history(Message.History.EDIT_EXPRESSTION_CONDITION_COMMENT)
	_set_expression_comment(comment.text)

func _on_Comment_focus_exited():
	if comment.text.length() == 0 :
		comment.text = HfsmConstant.ExpressionCommentDefaultText

#----------------auto signal------------------------
func _on_AutoModeButton_item_selected(index):
	_set_auto_transit_mode(index)

func _on_DelayTimerEdit_text_changed(new_text):
	if not new_text.substr(new_text.length()-1) == ".":
		delay_time_edit.text = str(float(new_text))
		delay_time_edit.caret_position = delay_time_edit.text.length()
	_uptate_transition_comment()

func _on_DelayTimerEdit_text_entered(new_text):
	delay_time_edit.release_focus()

func _on_DelayTimerEdit_focus_exited():
	delay_time_edit.text = str(float(delay_time_edit.text))
	if not "." in delay_time_edit.text:
		delay_time_edit.text += ".0"
	_set_delay_time(float(delay_time_edit.text))

func _on_TimesEdit_text_changed(new_text):
	times_edit.text = str(int(new_text))
	times_edit.caret_position = times_edit.text.length()
	_uptate_transition_comment()


func _on_TimesEdit_text_entered(new_text):
	times_edit.release_focus()

func _on_TimesEdit_focus_exited():
	times_edit.text = str(int(times_edit.text))
	_set_times(int(times_edit.text))
#----------------variable signal-----------------------------


func _on_VariableOpModeButton_item_selected(index):#改变表达式运行类型
	_set_variable_op_mode(index)



#------------------undo redo ----------------------------
func action_set_transition_type(old_type , new_type):
	undo_redo.create_action("Set transition_type")

	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_TRANSITION_TYPE)
	undo_redo.add_do_property(inspector_res , "transition_type" , new_type)
	if get_node_or_null("Editor/ScriptEditior"):
		undo_redo.add_do_property(get_node("Editor/ScriptEditior") , "visible" ,true if new_type == HfsmConstant.TRANSITION_TYPE_SCRIPT else false)
	undo_redo.add_do_property(get_node("Editor/ExpressionEditior") , "visible" ,true if new_type == HfsmConstant.TRANSITION_TYPE_EXPRESSION else false)
	undo_redo.add_do_property(get_node("Editor/VariableEditor") , "visible" ,true if new_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false)
	undo_redo.add_do_property(get_node("Editor/AutoEditor") , "visible" ,true if new_type == HfsmConstant.TRANSITION_TYPE_AUTO else false)
	undo_redo.add_do_property(fold_button , "visible" ,true if new_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false)

	undo_redo.add_do_method(transition_type_button , "select" , new_type )
	undo_redo.add_do_method(inspector_res , "update_comment" )


	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_TRANSITION_TYPE)
	undo_redo.add_undo_property(inspector_res , "transition_type" , old_type)
	if get_node_or_null("Editor/ScriptEditior"):
		undo_redo.add_undo_property(get_node("Editor/ScriptEditior") , "visible" ,true if old_type == HfsmConstant.TRANSITION_TYPE_SCRIPT else false)
	undo_redo.add_undo_property(get_node("Editor/ExpressionEditior") , "visible" ,true if old_type == HfsmConstant.TRANSITION_TYPE_EXPRESSION else false)
	undo_redo.add_undo_property(get_node("Editor/VariableEditor") , "visible" ,true if old_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false)
	undo_redo.add_undo_property(get_node("Editor/AutoEditor") , "visible" ,true if old_type == HfsmConstant.TRANSITION_TYPE_AUTO else false)
	undo_redo.add_undo_property(fold_button , "visible" ,true if old_type == HfsmConstant.TRANSITION_TYPE_VARIABLE else false)
	undo_redo.add_undo_method(transition_type_button , "select" , old_type )
	undo_redo.add_undo_method(inspector_res , "update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.SET_TRANSITION_TYPE)

func _get_tip_text(auto_mode:int):
	match auto_mode:
		HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER:
			return HfsmConstant.AutoTransitionTipText.DELAY_TIMER
		HfsmConstant.AUTO_TRANSIT_MODE_NESTED_FSM_EXIT:
			return HfsmConstant.AutoTransitionTipText.NESTED_FSM_EXIT
		HfsmConstant.AUTO_TRANSIT_MODE_MANUAL:
			return HfsmConstant.AutoTransitionTipText.MANUAL
		HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES:
			return HfsmConstant.AutoTransitionTipText.UPDATE_TIMES
		HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES:
			return HfsmConstant.AutoTransitionTipText.PHYSICS_UPDATE_TIMES
func action_auto_transit_mode(old_mode , new_mode):
	undo_redo.create_action("Set auto_transit_mode")
	var tip_text :String = _get_tip_text(new_mode)
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_AUTO_CONDITION_MODE)
	undo_redo.add_do_property(inspector_res.auto_condition_res , "auto_transit_mode" , new_mode)
	undo_redo.add_do_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/DelayTimerEditor") , "visible" ,true if new_mode == HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER else false)
	undo_redo.add_do_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/TimesEditor"), "visible" ,true if new_mode in [ HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES ,  HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES] else false)
	undo_redo.add_do_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/TipLabel") , "text" ,tip_text)
	undo_redo.add_do_method(auto_mode_button , "select" , new_mode )
	undo_redo.add_do_method(inspector_res , "update_comment" )

	tip_text = _get_tip_text(old_mode)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_AUTO_CONDITION_MODE)
	undo_redo.add_undo_property(inspector_res.auto_condition_res , "auto_transit_mode" , old_mode)
	undo_redo.add_undo_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/DelayTimerEditor") , "visible" ,true if old_mode == HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER else false)
	undo_redo.add_undo_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/TimesEditor"), "visible" ,true if old_mode in [ HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES ,  HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES] else false)
	undo_redo.add_undo_property(get_node("Editor/AutoEditor/Panel/VBoxContainer/TipLabel") , "text" , tip_text )
	undo_redo.add_undo_method(auto_mode_button , "select" , old_mode )
	undo_redo.add_undo_method(inspector_res , "update_comment" )

	undo_redo.commit_action()
	message.set_history(Message.History.SET_AUTO_CONDITION_MODE)

func action_set_delay_time(old_time:float , new_time:float):
	undo_redo.create_action("Set delay_time")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_AUTO_CONDITION_DELAY_TIME)
	undo_redo.add_do_property(inspector_res.auto_condition_res,"delay_time", new_time)
	undo_redo.add_do_property(delay_time_edit,"text", str(new_time))
	undo_redo.add_do_method(inspector_res , "update_comment" )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_AUTO_CONDITION_DELAY_TIME)
	undo_redo.add_undo_property(inspector_res.auto_condition_res,"delay_time", old_time)
	undo_redo.add_undo_property(delay_time_edit,"text", str(old_time))
	undo_redo.add_undo_method(inspector_res , "update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.SET_AUTO_CONDITION_DELAY_TIME)

func action_set_times(old_times , new_times) :
	undo_redo.create_action("Set times")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_AUTO_CONDITION_TIMES)
	undo_redo.add_do_property(inspector_res.auto_condition_res , "times" , new_times)
	undo_redo.add_do_property(times_edit , "text" , str(new_times))
	undo_redo.add_do_method(inspector_res , "update_comment" )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_AUTO_CONDITION_TIMES)
	undo_redo.add_undo_property(inspector_res.auto_condition_res , "times" , old_times)
	undo_redo.add_undo_property(times_edit , "text" , str(old_times))
	undo_redo.add_undo_method(inspector_res , "update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.SET_AUTO_CONDITION_TIMES)


var old_comment:String = ""
func action_update_expression_comment(new_text):
	undo_redo.create_action("Update expression_comment")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.EDIT_EXPRESSTION_CONDITION_COMMENT)
	undo_redo.add_do_property(inspector_res.expression_condition_res,"expression_comment",new_text)
	undo_redo.add_do_property(comment,"text",new_text)
	undo_redo.add_do_method(inspector_res , "update_comment" )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.EDIT_EXPRESSTION_CONDITION_COMMENT)
	undo_redo.add_undo_property(inspector_res.expression_condition_res,"expression_comment",old_comment)
	undo_redo.add_undo_property(comment,"text",old_comment)
	undo_redo.add_undo_method(inspector_res , "update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.EDIT_EXPRESSTION_CONDITION_COMMENT)


func action_set_variable_condition_operate_mode(old_mode , new_mode):
	undo_redo.create_action("Set variable_condition_operate_mode")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_VARIABLE_CONDITION_OPERATION_MODE)
	undo_redo.add_do_property(inspector_res.variable_condition_res,"variable_op_mode",new_mode)
	undo_redo.add_do_property(variable_op_mode_button,"selected",new_mode)
	undo_redo.add_do_method(inspector_res , "update_comment" )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_VARIABLE_CONDITION_OPERATION_MODE)
	undo_redo.add_undo_property(inspector_res.variable_condition_res,"variable_op_mode",old_mode)
	undo_redo.add_undo_property(variable_op_mode_button,"selected",old_mode)
	undo_redo.add_undo_method(inspector_res , "update_comment" )
	undo_redo.commit_action()
	message.set_history(Message.History.SET_VARIABLE_CONDITION_OPERATION_MODE)



func _on_VariableExpressionEditorList_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT :
			grab_focus()


func _on_FoldButton_toggled(button_pressed):
	root_fsm_res.transition_editor_folded = button_pressed
	fold_button.text = "<<" if button_pressed else ">>"
	for c in variable_expression_editor_list.get_children():
		if c is VariableExpressionEditor:
			c.is_fold = button_pressed


