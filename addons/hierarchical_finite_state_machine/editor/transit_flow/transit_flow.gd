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
#  2021/07/2 | 0.8   | Daylily-Zeleen      | Support script transition  (full version)        
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
tool
extends GraphNode
#--------identifier--------------
func TransitFlow():
	pass
#----------signal-----------
signal connect_state_updated
#signal selected(transit)
#---------const-------------
const normal_color :Color = Color.gray
const hover_color :Color = Color.ghostwhite
const select_color :Color = Color.springgreen

const LINE_WIDTH =4
const LINE_HALF_WIDTH = LINE_WIDTH/2
const OVERLAP_OFFSET = 13

const Message = preload("../message.gd")
const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
const NestedFsmRes = preload("../../script/source/nested_fsm_res.gd")
const TransitFlowInspectorRes = preload("transit_flow_inspector_res.gd")
const TransitionRes = NestedFsmRes.TransitionRes
const VarExpressionRes = TransitionRes.VariableConditionRes.VariableExpressionRes
#----------properties-----------------
var res_index :int
var hfsm_editor
var undo_redo:UndoRedo
var message :Message 
var inspector_res :TransitFlowInspectorRes = TransitFlowInspectorRes.new(self)

var transition_res :TransitionRes  setget _set_transition_res 
func _set_transition_res(res :TransitionRes) :
	transition_res = res 
	hfsm_editor.current_nested_fsm_res.add_transition(transition_res)
	set_from(hfsm_editor.get_state_node_by_state_name_or_null(transition_res.from_res.state_name) if transition_res.from_res else null)
	set_to(hfsm_editor.get_state_node_by_state_name_or_null(transition_res.to_res.state_name) if transition_res.to_res else null)
	


#var offset :Vector2 = Vector2.ZERO setget set_offset
#func set_offset(v):
#	offset = v
#	if get_parent() is GraphEdit:
#		var graph_edit :GraphEdit= get_parent()
#		rect_position = offset - graph_edit.scroll_offset 

	
#var selected :bool = false setget set_selected ,is_selected
#func set_selected(v:bool):
#	selected =v
#	if selected  :
#		modulate = select_color
#		emit_signal("selected", self)
#	else :
#		var parent =  get_parent()
#		if parent and parent is GraphEdit:
#			if get_rect().has_point(parent.get_local_mouse_position()) :
#				modulate = hover_color
#			else :
#				modulate = normal_color
				
func is_selected():
	return selected

var comment_visible :bool = true setget set_comment_visible
func set_comment_visible(v:bool):
	comment_visible = v
	condition_comment.visible = true if v else false
		
#-----------Link to  res--------------------------------
var from setget set_from, get_from
func set_from(new_from ):
	if new_from!= from and from:
		if from.is_connected("offset_changed",self,"_on_StateNode_offset_changed") :
			from.disconnect("offset_changed",self,"_on_StateNode_offset_changed")
		if from.is_connected("resized" , self , "_on_StateNode_resized"):
			from.disconnect("resized" , self , "_on_StateNode_resized")
	from = new_from
	if from :
		from.connect("offset_changed",self,"_on_StateNode_offset_changed")
		from.connect("resized" , self , "_on_StateNode_resized")
		transition_res.from_res = from.state_res
	if from and not to :
		set_offset(from.offset - rect_pivot_offset)
	emit_signal("connect_state_updated")
func get_from():
	return from
	
var to setget set_to,get_to
func set_to(new_to :Node):
	if to and new_to != to:
		if to.is_connected("offset_changed",self,"_on_StateNode_offset_changed") :
			to.disconnect("offset_changed",self,"_on_StateNode_offset_changed")
		if to.is_connected("resized" , self , "_on_StateNode_resized"):
			to.disconnect("resized" , self , "_on_StateNode_resized")

	action_reconnect(new_to)
	to = new_to
	if to :
		transition_res.to_res = to.state_res
	if to == from or is_existed():
		delete_self()
		return
	if to:
		if not to.is_connected("offset_changed",self,"_on_StateNode_offset_changed"):
			to.connect("offset_changed",self,"_on_StateNode_offset_changed")
		if not to.is_connected("resized" , self , "_on_StateNode_resized"):
			to.connect("resized" , self , "_on_StateNode_resized")
	if from and to:
		place_line(from ,to)
		mouse_filter = Control.MOUSE_FILTER_STOP

		if transition_res:
			transition_res.from_res = from.state_res
			transition_res.to_res = to.state_res

	var overlap_transit_flow = get_overlaping_transit_flow_or_null()
	if overlap_transit_flow:
		if overlap_transit_flow.offset == overlap_transit_flow.from.offset + overlap_transit_flow.from.rect_size / 2 - overlap_transit_flow.rect_pivot_offset:
			overlap_transit_flow.offset += Vector2.UP .rotated(deg2rad(overlap_transit_flow.rect_rotation))* OVERLAP_OFFSET
	emit_signal("connect_state_updated")
	
func get_to():
	return to


var transition_type : int = HfsmConstant.TRANSITION_TYPE_AUTO setget _set_transition_type ,_get_transition_type
func _set_transition_type(t :int) :
	transition_res.transition_type = t 
func _get_transition_type():
	return transition_res.transition_type 
	
var auto_condition_res :TransitionRes.AutoConditionRes =TransitionRes.AutoConditionRes.new() setget _set_auto_condition_res , _get_auto_condition_res
func _set_auto_condition_res(auto_res:TransitionRes.AutoConditionRes ) :
	transition_res.auto_condition_res = auto_res
func _get_auto_condition_res():
	return transition_res.auto_condition_res
		
var expression_condition_res :TransitionRes.ExpressionConditionRes = TransitionRes.ExpressionConditionRes.new() setget _set_expression_condition_res , _get_expression_condition_res
func _set_expression_condition_res(expresstion_res :TransitionRes.ExpressionConditionRes):
	transition_res.expression_condition_res = expresstion_res
func _get_expression_condition_res():
	return transition_res.expression_condition_res
		
var variable_condition_res :TransitionRes.VariableConditionRes = TransitionRes.VariableConditionRes.new() setget _set_variable_condition_res , _get_variable_condition_res
func _set_variable_condition_res(variable_res:TransitionRes.VariableConditionRes):
	transition_res.variable_condition_res = variable_res
func _get_variable_condition_res():
	return transition_res.variable_condition_res


#----------------------------------------
onready var arrow:Control = get_node("CenterContainer/Control/Arrow")
onready var condition_comment :VBoxContainer = get_node("CenterContainer/Control/ConditionComment")


func init(editor ,  transition_res:TransitionRes ):
	hfsm_editor = editor
	undo_redo = hfsm_editor.undo_redo
	message = hfsm_editor.message
	_set_transition_res( transition_res)
	
	_set_transition_type(transition_res.transition_type)
	_set_auto_condition_res(transition_res.auto_condition_res)
	_set_expression_condition_res(transition_res.expression_condition_res)
	_set_variable_condition_res(transition_res.variable_condition_res)
	if from and to :
		show()
		
func _ready():
	self.rect_pivot_offset = Vector2(0,LINE_HALF_WIDTH)
	
func connect_state():
	if from and to :
		if not from.is_connected("offset_changed",self,"_on_StateNode_offset_changed"):
			from.connected("offset_changed",self,"_on_StateNode_offset_changed")
		if not to.is_connected("offset_changed",self,"_on_StateNode_offset_changed"):
			to.connected("offset_changed",self,"_on_StateNode_offset_changed")
	else :
		return false

func update_comment():
	if not comment_visible:
		return
	match _get_transition_type():
		HfsmConstant.TRANSITION_TYPE_AUTO :
			var label_text :String = "Empty,this Transition Will be false."
			match _get_auto_condition_res().auto_transit_mode :
				HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER :
					label_text = "delay " + str(_get_auto_condition_res().delay_time) + "s."
				HfsmConstant.AUTO_TRANSIT_MODE_MANUAL :
					label_text = "call exit() in state script manually."
				HfsmConstant.AUTO_TRANSIT_MODE_NESTED_FSM_EXIT:
					label_text = "nested fsm exited"
				HfsmConstant.AUTO_TRANSIT_MODE_MANUAL:
					label_text = "execut manual_exit() in state script."
				HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES :
					label_text = "update() be called " + str(_get_auto_condition_res().times) +"times."
				HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES :
					label_text = "physics_update() be called " + str(_get_auto_condition_res().times) +"times."
			condition_comment.get_child(0).text = label_text
			condition_comment.get_child(0).show()
			for i in range(1,condition_comment.get_child_count()) :
				condition_comment.get_child(i).hide()
		HfsmConstant.TRANSITION_TYPE_VARIABLE :
			condition_comment.get_child(0).text = "Empty,this Transition Will be false."
			var last_index = condition_comment.get_child_count() - 1 
			for v in _get_variable_condition_res().variable_expression_res_list:
				if not v.is_valid():
					_get_variable_condition_res()._on_variable_expression_res_deleted(v)
			var expression_count :int = _get_variable_condition_res().variable_expression_res_list.size()
			for i in range(expression_count) :
				if not _get_variable_condition_res().variable_expression_res_list[i].variable_res.is_connected("deleted" , _get_variable_condition_res().variable_expression_res_list[i] ,"_on_VariableRes_deleted") :
					_get_variable_condition_res().variable_expression_res_list[i].variable_res.connect("deleted" , _get_variable_condition_res().variable_expression_res_list[i] ,"_on_VariableRes_deleted",[],CONNECT_PERSIST) 
				if not _get_variable_condition_res().variable_expression_res_list[i].is_connected("deleted" ,self ,"_on_VariableExpressionRes_deleted"):
					_get_variable_condition_res().variable_expression_res_list[i].connect("deleted" ,self ,"_on_VariableExpressionRes_deleted")
				if i >last_index :
					var label :Label = condition_comment.get_child(0).duplicate()
					condition_comment.add_child(label)
				condition_comment.get_child(i).show()
				var var_exp_res :VarExpressionRes = _get_variable_condition_res().variable_expression_res_list[i]
				var text :String = var_exp_res.variable_res.variable_name
				match var_exp_res.variable_res.variable_type : 
					HfsmConstant.VARIABLE_TYPE_TRIGGER :
						if var_exp_res.trigger_mode == HfsmConstant.TRIGGER_MODE_FORCE:
							text += " force trigger"
						else :
							text += " normal trigger"
					_ :
						match var_exp_res.comparation :
							HfsmConstant.COMPARATION_EQUEAL :
								text += " == "
							HfsmConstant.COMPARATION_UNEQUEAL :
								text += " != "
							HfsmConstant.COMPARATION_GREATER_THAN :
								text += " > "
							HfsmConstant.COMPARATION_GREATER_THAN_OR_EQUAL :
								text += " >= "
							HfsmConstant.COMPARATION_LESS_THAN :
								text += " < "
							HfsmConstant.COMPARATION_LESS_THAN_OR_EQUAL :
								text += " <= "
						if var_exp_res.variable_res.variable_type == HfsmConstant.VARIABLE_TYPE_STRING :
							text += "'" + var_exp_res.value + "'"
						else :
							if var_exp_res.variable_res.variable_type == HfsmConstant.VARIABLE_TYPE_FLOAT :
								text += str(var_exp_res.value) 
								if not "." in str(var_exp_res.value):
									text += ".0"
							else:
								text += str(var_exp_res.value)
				condition_comment.get_child(i).text = text
			if last_index + 1 > expression_count :
				for i in range(expression_count , last_index + 1 ):
					if i > 0 :
						condition_comment.get_child(i).hide()
		HfsmConstant.TRANSITION_TYPE_EXPRESSION :
			var label_text :String = _get_expression_condition_res().expression_text
			condition_comment.get_child(0).text = label_text if label_text and label_text.length() > 0 else "Empty,this Transition Will be false."
			condition_comment.get_child(0).show()
			for i in range(1,condition_comment.get_child_count()) :
				condition_comment.get_child(i).hide()
		
	condition_comment.set_deferred("rect_size",Vector2.ZERO)
#--------------method-------------


		
func get_overlaping_transit_flow_or_null():
	for t in  hfsm_editor.graph_edit.get_children():
		if t.has_method("TransitFlow") :
			if t != self and t.from == to and t.to == from :
				return t
	return null
	
func is_existed()->bool:
	for t in hfsm_editor.graph_edit.get_children():
		if t.has_method("TransitFlow") and t.transition_res != transition_res:
			if t != self and  t.transition_res.from_res  == transition_res.from_res  and t.transition_res.to_res == transition_res.to_res:
				return true
	return false
	
func place_comment():
	condition_comment.visible = true
	condition_comment.rect_pivot_offset = condition_comment.rect_size / 2
	condition_comment.rect_position.x = - condition_comment.rect_size.x /2
	if -90 <= self.rect_rotation  and self.rect_rotation <= 90:
		condition_comment.rect_position.y = - 3*rect_size.y - condition_comment.rect_size.y# - condition_comment.rect_pivot_offset.y
		condition_comment.rect_rotation = 0
	else :
		condition_comment.rect_position.y = - rect_size.y - condition_comment.rect_size.y #- condition_comment.rect_pivot_offset.y
		condition_comment.rect_rotation = 180
		
func place_line(start = from , end = to):
	var start_offset :Vector2 = start if start is Vector2 else start.offset + start.rect_size / 2
	var end_offset :Vector2 = end if end is Vector2 else end.offset + end.rect_size / 2
	
	var length:float = start_offset.distance_to(end_offset)
	set_deferred("rect_size" ,Vector2(length , LINE_WIDTH) ) 
	var dir:Vector2 = end_offset - start_offset
	self.rect_rotation = rad2deg(Vector2.RIGHT.angle_to(dir) )
	
	var overlap_transit_flow = get_overlaping_transit_flow_or_null()
	if overlap_transit_flow:
		var overlap_offset
		set_offset(start_offset + (Vector2.UP* OVERLAP_OFFSET ).rotated(deg2rad(rect_rotation)) - rect_pivot_offset)
	else :
		set_offset(start_offset - rect_pivot_offset)
	
	place_comment()
	update_comment()
	

func follow_mouse(mouse_offset:Vector2):
	if get_overlaping_transit_flow_or_null() :
		mouse_offset -= (Vector2.UP* OVERLAP_OFFSET ).rotated(deg2rad(rect_rotation))
	if from :
		place_line(from , mouse_offset)
		visible = true

	
#------------------signal----------------------
func _on_VariableExpressionRes_deleted(res):
	update_comment()

func _on_StateNode_resized():
	if from and to :
		place_line(from , to)
		
func _on_TransitFlow_gui_input(event:InputEvent):
	if event is InputEventMouseButton :
		if event.pressed and (event as InputEventMouseButton).button_index ==BUTTON_LEFT :
			if Input.is_key_pressed(KEY_SHIFT):#重连
				if hfsm_editor :
					hfsm_editor.editing_transit_flow = self
					set_selected(false)
					follow_mouse(hfsm_editor._get_mouse_pos_offset())
					mouse_filter = Control.MOUSE_FILTER_IGNORE
					old_to = to
			else :
				if hfsm_editor :
					hfsm_editor.clear_other_selected_whitout_exception(self)
				set_selected(true)

	
func delete_self():
	(hfsm_editor.current_nested_fsm_res as NestedFsmRes).delete_transition(transition_res)
	queue_free()
		
func _on_StateNode_offset_changed():
	if from and to:
		place_line(from , to)

func _on_graph_edit_multiple_select_updated(state_node , is_selected:bool):
	if is_selected:
		if not (from.is_selected() and to.is_selected()) and (state_node == from or from.is_selected()) and (state_node == to or to.is_selected()):
			set_selected(true)
	else :
		if state_node in [from , to]:
			set_selected(false)
			
func _on_TransitFlow_mouse_entered():
	if not is_selected():
		modulate = hover_color

func _on_TransitFlow_mouse_exited():
	if not is_selected():
		modulate = normal_color

const HFSM = preload("res://addons/hierarchical_finite_state_machine/script/hfsm.gd")
func _process(delta):
	if not is_selected() or (hfsm_editor.the_plugin.get_editor_interface().get_selection().get_selected_nodes().size() > 0 and not hfsm_editor.the_plugin.get_editor_interface().get_selection().get_selected_nodes()[0] is HFSM):
		modulate = normal_color
		set_process(false)

func _on_ConditionComment_resized():
	place_comment()


func _on_ConditionComment_ready():
	if not condition_comment:
		get_node("CenterContainer/Control/ConditionComment").connect("resized",self,"_on_ConditionComment_resized")
	else :
		condition_comment.connect("resized",self,"_on_ConditionComment_resized")

func _fresh_inspector():
	(hfsm_editor.the_plugin as EditorPlugin).get_editor_interface().get_inspector().refresh()

#--------------undo redo-------------------------
var old_to 
func _undo_redo_set_to(new_to):
	if to and new_to != to:
		if to.is_connected("offset_changed",self,"_on_StateNode_offset_changed") :
			to.disconnect("offset_changed",self,"_on_StateNode_offset_changed")
		if to.is_connected("resized" , self , "_on_StateNode_resized"):
			to.disconnect("resized" , self , "_on_StateNode_resized")
	to = new_to
	if to == from or is_existed():
		delete_self()
		return
	if to:
		if not to.is_connected("offset_changed",self,"_on_StateNode_offset_changed"):
			to.connect("offset_changed",self,"_on_StateNode_offset_changed")
		if not to.is_connected("resized" , self , "_on_StateNode_resized"):
			to.connect("resized" , self , "_on_StateNode_resized")
	if from and to:
		place_line(from ,to)
		mouse_filter = Control.MOUSE_FILTER_STOP
		
		if transition_res:
			transition_res.from_res = from.state_res
			transition_res.to_res = to.state_res
		
	var overlap_transit_flow = get_overlaping_transit_flow_or_null()
	if overlap_transit_flow:
		if overlap_transit_flow.offset == overlap_transit_flow.from.offset + from.rect_size / 2 - overlap_transit_flow.rect_pivot_offset:
			overlap_transit_flow.offset += Vector2.UP .rotated(deg2rad(overlap_transit_flow.rect_rotation))* OVERLAP_OFFSET# 
	emit_signal("connect_state_updated")
	
func action_reconnect(new_to):
	if old_to and new_to != old_to :
		undo_redo.create_action("Transition reconnect")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.RECONNECT_TRANSITION)
		undo_redo.add_do_method(self , "_undo_redo_set_to" ,new_to )
		undo_redo.add_do_method(self , "_fresh_inspector" )
		
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.RECONNECT_TRANSITION)
		undo_redo.add_undo_method(self , "_undo_redo_set_to" , old_to)
		undo_redo.add_undo_method(self , "_fresh_inspector" )
		undo_redo.commit_action()
		message.set_history(Message.History.RECONNECT_TRANSITION)
	

func _on_self_selected(node):
	if node == self:
		modulate = select_color
		set_process(true)
func _on_self_unselected(node):
	if node == self:
		var parent =  get_parent()
		if parent and parent is GraphEdit:
			if get_rect().has_point(parent.get_local_mouse_position()) :
				modulate = hover_color
			else :
				modulate = normal_color
