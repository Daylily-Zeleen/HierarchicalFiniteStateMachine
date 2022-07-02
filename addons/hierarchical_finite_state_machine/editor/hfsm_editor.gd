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
#  2021/04/18 | 0.1   | Daylily-Zeleen      | Fix pupupmenue delete               
#  2021/04/18 | 0.1   | Daylily-Zeleen      | Fix pupupmenue delete  
#  2022/07/1~3 | 0.8   | Daylily-Zeleen      |   Bugfix, add new feature.                  
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
tool
extends Control
#----------
signal node_selected(selected_object)
signal multiple_select_updated(state_node ,is_selected)
signal delete_request(node)

const HfsmConstant = preload("../script/source/hfsm_constant.gd")
const StateNode = preload("state_node/state_node.gd")
const TransitFlow = preload("transit_flow/transit_flow.gd")
const SwithcButton =preload("switch_button.gd")
const NestedFsmRes = preload("../script/source/nested_fsm_res.gd")
const HFSM = preload("../script/hfsm.gd")
const VariableList = preload("variable_list.gd")
const Message = preload("message.gd")

#------------nodes---------------
onready var comment_visible_button :ToolButton
onready var popup_menu:PopupMenu = get_node("PopupMenu")
onready var script_popup_menu:PopupMenu = get_node("PopupMenu/ScriptPopupMenu")
onready var message:Message = get_node("FsmEditior/Message") 
onready var graph_edit :GraphEdit = get_node("FsmEditior/GraphEdit")
onready var variable_list :VariableList = get_node("FsmEditior/GraphEdit/VariableList")
onready var switch_buttons :Node = get_node("FsmEditior/Panel/CenterContainer/SwitchButtons")
onready var not_state_warming :Node = get_node("NotStateWarming")
#插件
var the_plugin:EditorPlugin setget _set_the_plugin
func _set_the_plugin(p :EditorPlugin) :
	the_plugin = p
	undo_redo = p.get_undo_redo()
var undo_redo :UndoRedo 

var loading := false
var current_hfsm :HFSM setget _set_current_hfsm
func _set_current_hfsm(hfsm:HFSM):
	loading = true
	current_hfsm = hfsm
	current_hfsm._root_fsm_res.is_deleted_state_script()
	for b in switch_buttons.get_children():
		if b is SwithcButton:
			b.queue_free()
	variable_list.init(self,current_hfsm._root_fsm_res)
	current_nested_fsm_res = null
	yield(_set_current_nested_fsm_res(current_hfsm._root_fsm_res) , "completed")
	while current_nested_fsm_res.entered_nested_fsm_res :
		yield(_set_current_nested_fsm_res(current_nested_fsm_res.entered_nested_fsm_res),"completed")
	loading = false
	get_entry_state_count()
var editor_selection:EditorSelection

var enable :bool setget _set_enable
func _set_enable(v:bool) :
	enable = v
	if v :
		get_node("NotSelectedWarming").hide()
	else :
		get_node("NotSelectedWarming").show()
		
var transition_comment_visible :bool = true setget _set_transition_comment_visible 
func _set_transition_comment_visible (v:bool):
	if current_nested_fsm_res:
		current_nested_fsm_res.transition_comment_visible = v
	for i in graph_edit.get_children():
		if i is TransitFlow :
			i.comment_visible = v
		

var current_nested_fsm_res:NestedFsmRes setget _set_current_nested_fsm_res
func _set_current_nested_fsm_res(nested_fsm_res :NestedFsmRes):
	graph_edit.scroll_offset = nested_fsm_res.editor_scroll_offset
	variable_list.offset = nested_fsm_res.variable_list_offset
	if current_nested_fsm_res :#保存嵌套状态
		current_nested_fsm_res.entered_nested_fsm_res = nested_fsm_res
	current_nested_fsm_res = nested_fsm_res
	if not loading:
		current_nested_fsm_res.entered_nested_fsm_res = null
	current_fsm_button = add_new_switch_button(nested_fsm_res)
	yield(_load_state_machine_from_res(),"completed")
	comment_visible_button.pressed = nested_fsm_res.transition_comment_visible
	_set_transition_comment_visible(nested_fsm_res.transition_comment_visible)
	if current_nested_fsm_res.state_res_list.size() == 0:
		not_state_warming.show()
	else :
		not_state_warming.hide()
		

var current_fsm_button :SwithcButton  

func _ready():
	popup_menu.set_item_submenu(2,"ScriptPopupMenu")
	comment_visible_button = ToolButton.new()
	comment_visible_button.toggle_mode = true
	comment_visible_button.icon = preload("res://addons/hierarchical_finite_state_machine/editor/icon/visiblity_icon.png")
	comment_visible_button.connect("toggled",self,"_on_CommentVisibleButton_toggled")
	for c in graph_edit.get_children():
		for c_c in c.get_children():
			if "HBoxContainer"in c_c.name:
				for i in c.get_children():
					if i is HBoxContainer:
						i.add_child(comment_visible_button)
						break
				break
	_set_enable(false)
	
func _load_state_machine_from_res():
	#移除
	if current_nested_fsm_res :
		for s in graph_edit.get_children():
			if s is StateNode :
				s.queue_free()
	if current_nested_fsm_res :
		for t in graph_edit.get_children() :
			if t is TransitFlow :
				t.queue_free()
	yield(get_tree(),"idle_frame")
	#载入state node
	for state_res in current_nested_fsm_res.state_res_list :
		if state_res is NestedFsmRes.StateRes :
			add_state_node(state_res)
	yield(get_tree(),"idle_frame")
	#载入TransitFlow 
	for transition_res in current_nested_fsm_res.transition_res_list :
		if transition_res is NestedFsmRes.TransitionRes:
			add_transit_flow(transition_res)
	
func _get_mouse_pos_offset() -> Vector2:
	return  graph_edit.get_local_mouse_position() + graph_edit.scroll_offset
	

func get_state_node_by_state_name_or_null(state_name : String):
	for s in graph_edit.get_children() :
		if s is StateNode :
			if s.state_name == state_name :
				return s
	return null
	
	
func add_state_node(state_res:NestedFsmRes.StateRes = NestedFsmRes.StateRes.new()):
	var new_state_node = preload("state_node/state_node.tscn").instance()
	graph_edit.add_child(new_state_node)
	new_state_node.init(self ,state_res )
	new_state_node.connect("entry_nested_request",self , "_on_entry_nested_request",[],CONNECT_PERSIST)
	
	graph_edit.connect("node_selected" , new_state_node ,"_on_selected",[],CONNECT_PERSIST)
	graph_edit.connect("node_unselected" , new_state_node ,"_on_unselected",[],CONNECT_PERSIST)
	
	get_entry_state_count()
	return new_state_node


	
func add_transit_flow(transition_res :NestedFsmRes.TransitionRes) ->TransitFlow:
	var new_transit_flow :TransitFlow = preload("transit_flow/transit_flow.tscn").instance()
	graph_edit.add_child(new_transit_flow)
	new_transit_flow.init(self , transition_res)
	graph_edit.move_child(new_transit_flow,0)
	connect("multiple_select_updated" , new_transit_flow,"_on_graph_edit_multiple_select_updated",[],CONNECT_PERSIST)
	graph_edit.connect("node_selected" , new_transit_flow ,"_on_self_selected",[],CONNECT_PERSIST)
	graph_edit.connect("node_unselected" , new_transit_flow ,"_on_self_unselected",[],CONNECT_PERSIST)
	
	new_transit_flow.comment_visible = transition_comment_visible
	return new_transit_flow

func get_entry_state_count():
	var count :int = 0
	for s_res in current_nested_fsm_res.state_res_list:
		if s_res.state_type == HfsmConstant.STATE_TYPE_ENTRY:
			count += 1
	if count == 0:
		message.set_error(Message.Error.NOT_ENTRY_STATE)
	elif count > 1 :
		message.set_error(Message.Error.MULTI_ENTRY_STATE)
	return count


	

## ----------------- Custom Methods ------
func refresh_state_node():
	for c in graph_edit.get_children():
		if c is StateNode:
			c.state_res = c.state_res
			
func refresh_transition_comment():
	for c in graph_edit.get_children():
		if c is TransitFlow:
			c.update_comment()
func refresh_transition_line() :
	for c in graph_edit.get_children():
		if c is TransitFlow:
			c.place_line()
			
func add_new_switch_button(nested_fsm_res:NestedFsmRes) -> SwithcButton:
	if current_fsm_button and current_fsm_button is SwithcButton:
		current_fsm_button.disabled = false
	var n_b:SwithcButton = SwithcButton.new(self,nested_fsm_res)
	switch_buttons.add_child(n_b)
	n_b.connect("switch_fsm_request" , self , "_on_switch_fsm_request")
	n_b.disabled =true
	current_fsm_button = n_b
	current_fsm_button.disabled = true
	return n_b
	
func _on_switch_fsm_request(switch_button:SwithcButton):
	action_switch_fsm(switch_button)

var copy_state_list :Array 
var copy_transition_list :Array
func copy():
	copy_state_list.clear()
	copy_transition_list.clear()
	for c in graph_edit.get_children():
		if c is StateNode and c.is_selected():
			copy_state_list.append(c.state_res)
		if c is TransitFlow and c.is_selected():
			copy_transition_list.append(c.transition_res)

func paste(offset:Vector2):
	action_paste(offset)

func get_top_control_or_null_at_pos(position:Vector2 = graph_edit.get_local_mouse_position()):
	var count :int = graph_edit.get_child_count()
	var mouse_pos :Vector2 = position#graph_edit.get_local_mouse_position()
	for i in range(count-1,-1,-1):
		var current:Control = graph_edit.get_child(i)
		if current is StateNode and current.get_rect().has_point(mouse_pos):
			return current
		elif current is TransitFlow and current.get_rect().has_point(mouse_pos):
			return current
	return null


func clear_other_selected_whitout_exception(exception):
	if not Input.is_key_pressed(KEY_CONTROL):
		for c in graph_edit.get_children():
			if (c is StateNode or c is TransitFlow) and c != exception:
				if c is StateNode and c.is_selected():
					graph_edit.emit_signal("node_unselected" , c)
				c.set_selected(false)

#############################################
func convert_to_nested(request_node):
	if not request_node:
		return
	if request_node is StateNode and request_node.is_selected():
		var nested_fsm_res:NestedFsmRes = NestedFsmRes.new(request_node.state_name , true)
		var nested_state_res:NestedFsmRes.StateRes = NestedFsmRes.StateRes.new(request_node.offset , request_node.state_name, request_node.state_type ,request_node.state_script,true,nested_fsm_res)
		current_nested_fsm_res.state_res_list.append(nested_state_res)
		var nested_state_node :StateNode = add_state_node(nested_state_res)

		for t in graph_edit.get_children():#修正transitflow
			if t is TransitFlow:
				if t.from == request_node and not t.to.is_selected():
					t.from = nested_state_node
				elif t.to == request_node and not t.from.is_selected():
					t.to = nested_state_node
				elif (t.from.is_selected() and not t.to.is_selected()) or (not t.from.is_selected() and t.to.is_selected()) :
					emit_signal("delete_request",t)
					
		for c in graph_edit.get_children() :
			if c is StateNode and c.is_selected():
				nested_fsm_res.state_res_list.append(c.state_res)
				current_nested_fsm_res.deleted_state(c.state_res)
				if c == request_node :
					(c as StateNode).state_type = HfsmConstant.STATE_TYPE_ENTRY
				
			elif c is TransitFlow and c.is_selected():
				nested_fsm_res.transition_res_list.append(c.transition_res)
				current_nested_fsm_res.delete_transition(c.transition_res)
		nested_state_res.state_name = request_node.state_name
		request_node.state_script = null
		_on_entry_nested_request(nested_state_node)#进入该嵌套状态机

# ----------------- signals -----------------

var _last_right_click_pos:Vector2 = Vector2.ZERO
func _on_GraphEdit_popup_request(position):
	_last_right_click_pos = graph_edit.get_local_mouse_position()
	#首先处理transitFlow编辑模式
	if editing_transit_flow :
		return
		
	var top = get_top_control_or_null_at_pos()
	if top and (top is StateNode or top is TransitFlow):
		top.selected = true
	var has_selected:bool = false
	var has_selected_state :bool = false
	for c in graph_edit.get_children():
		if c is StateNode and c.is_selected() :
			has_selected_state = true
			break
	if not has_selected:
		for c in graph_edit.get_children():
			if c is TransitFlow and c.is_selected(): 
				has_selected = true
				break
	popup_menu.set_item_disabled(CREATE_TRANSITION ,false if top and top is StateNode else true)
	popup_menu.set_item_disabled(SCRIPT ,false if top is StateNode else true)
	#
	if top is StateNode:
		script_popup_menu.set_item_disabled(OPEN_SCRIPT ,false if top.state_script else true)
		script_popup_menu.set_item_disabled(CREATE_NEW_SCRIPT ,false if not top.state_script else true)
		script_popup_menu.set_item_disabled(ATTACH_EXIST_SCRIPT ,false if not top.state_script else true)
		script_popup_menu.set_item_disabled(REMOVE_SCRIPT ,false if top.state_script else true)
	#
	popup_menu.set_item_disabled(COPY ,false if has_selected_state  else true)
	popup_menu.set_item_disabled(PASTE ,false if not copy_state_list.empty() else true)
	popup_menu.set_item_disabled(DUPLICATE ,false if has_selected_state else true)
	popup_menu.set_item_disabled(DELETE ,false if has_selected else true)
	popup_menu.set_item_disabled(CONVERT_TO_NESTED_STATE_MACHINE ,false if has_selected_state else true)
	popup_menu.set_global_position(position)
	popup_menu.popup()
		
enum {
	ADD_STATE,
	CREATE_TRANSITION,
	SCRIPT ,
	COPY,
	PASTE,
	DUPLICATE,
	DELETE,
	
	CONVERT_TO_NESTED_STATE_MACHINE = 8,
	SHOW_VARIABLE_LIST_AT_HERE,
}
enum {
	OPEN_SCRIPT ,
	CREATE_NEW_SCRIPT ,
	ATTACH_EXIST_SCRIPT ,
	REMOVE_SCRIPT ,
}
func _on_PopupMenu_index_pressed(index):
	match index:
		ADD_STATE :
			for c in graph_edit.get_children():
				if c is GraphNode or c is TransitFlow :
					c.selected = false
			action_add_new_state_node(NestedFsmRes.StateRes.new(_last_right_click_pos + graph_edit.scroll_offset))
			message.set_tip(Message.Tip.ADD_STATE)
		CREATE_TRANSITION :
			var top = get_top_control_or_null_at_pos(_last_right_click_pos)
			if top is StateNode:
				var transition_res :TransitFlow.TransitionRes = TransitFlow.TransitionRes.new( top.state_res , null ) 
				editing_transit_flow = add_transit_flow(transition_res)
				message.set_tip(Message.Tip.CONNECT)
		COPY:
			copy()
		PASTE :
			#计算中心
			var offset_center :Vector2 = Vector2.ZERO
			for s in copy_state_list:
				offset_center += s.editor_offset
			offset_center /= float(copy_state_list.size())
			var offset:Vector2 = _get_mouse_pos_offset() - offset_center
			paste(offset)
		DUPLICATE:
			action_duplicate()
		DELETE:
			action_delete()
			
		CONVERT_TO_NESTED_STATE_MACHINE :
			action_convert_to_nested(get_top_control_or_null_at_pos(_last_right_click_pos))
		SHOW_VARIABLE_LIST_AT_HERE:
			variable_list.switch_visible(true,_last_right_click_pos + graph_edit.scroll_offset)

func _on_ScriptPopupMenu_index_pressed(index):
	var top = get_top_control_or_null_at_pos(_last_right_click_pos)
	if top is StateNode:
		match index :
			OPEN_SCRIPT :
				the_plugin.get_editor_interface().edit_resource(top.state_script)
			CREATE_NEW_SCRIPT :
				top.create_new_script()
			ATTACH_EXIST_SCRIPT :
				top.attach_exist_script()
			REMOVE_SCRIPT :
				top.state_script = null


var is_multiple_select :bool = false
var editing_transit_flow :TransitFlow
func _on_GraphEdit_gui_input(event):
	if event is InputEventMouseButton :
		var mouse_button_event :InputEventMouseButton  = event
		if mouse_button_event.pressed :
			if mouse_button_event.button_index == BUTTON_LEFT:
				#获取最上层的控件
				var the_top_control = get_top_control_or_null_at_pos()
				if not the_top_control is StateNode:
					clear_other_selected_whitout_exception(the_top_control)#清除其他选中
				if not the_top_control :
					if not editing_transit_flow:
						is_multiple_select = true
				else :
					is_multiple_select = false
					
				if Input.is_key_pressed(KEY_SHIFT):
					var top_state:StateNode = the_top_control
		
		if not mouse_button_event.pressed :#松开
			if mouse_button_event.button_index == BUTTON_LEFT:#左键
				is_multiple_select = false#在信号中处理多选，此处仅复位
				if editing_transit_flow:
					yield(get_tree(),"idle_frame")#等待PlaceLine
					yield(get_tree(),"idle_frame")
					
			if mouse_button_event.button_index == BUTTON_RIGHT :
				if editing_transit_flow:
					graph_edit.move_child(editing_transit_flow,0)
					if not editing_transit_flow.old_to :
						editing_transit_flow.delete_self()
						message.set_tip(Message.Tip.CANCEL_CONNECT)
					else :
						editing_transit_flow.to = editing_transit_flow.old_to
						message.set_tip(Message.Tip.CANCEL_RECONNECT)
						editing_transit_flow.place_line()
					editing_transit_flow = null
				
	elif event is InputEventMouseMotion :
		var mouse_moution_event :InputEventMouseMotion = event
		if editing_transit_flow :
			editing_transit_flow.follow_mouse(_get_mouse_pos_offset())
			
	elif event is InputEventKey :
		var key_event :InputEventKey = event
		if key_event.pressed and not key_event.echo and key_event.scancode == KEY_ESCAPE :
			if editing_transit_flow:
				editing_transit_flow.delete_self()
				message.set_tip(Message.Tip.CANCEL_CONNECT)
				editing_transit_flow = null

func _on_GraphEdit_node_selected(node):
	if not is_multiple_select and Engine.editor_hint:
		emit_signal("node_selected" , node )
	#	
	if node is StateNode:
		if not editing_transit_flow :
			if Input.is_key_pressed(KEY_SHIFT):
				var transition_res :TransitFlow.TransitionRes = TransitFlow.TransitionRes.new( node.state_res , null ) 
				editing_transit_flow = add_transit_flow(transition_res)
				message.set_tip(Message.Tip.CONNECT)
		else :
			var t_res = editing_transit_flow.transition_res
			t_res.to_res = node.state_res
			if editing_transit_flow.is_existed():
				if editing_transit_flow.old_to :
					editing_transit_flow.to = editing_transit_flow.old_to
					message.set_tip(Message.Tip.CREATE_CONNECT_SUCCESS )
				else :
					editing_transit_flow.delete_self()
					message.set_error(Message.Error.TRANSITION_ALREADY_EXIST)
			else:
				editing_transit_flow.queue_free()
				action_add_new_transit_flow(t_res)
				message.set_tip(Message.Tip.DEFAULT)
			editing_transit_flow = null
		#检测多选：
		if is_multiple_select:
			emit_signal("multiple_select_updated", node , true)
	elif node is TransitFlow:
		graph_edit.move_child(node,0)


func _on_GraphEdit_node_unselected(node):
	if node is StateNode:
		#检测多选：
		if is_multiple_select:
			emit_signal("multiple_select_updated", node , false)

func _on_GraphEdit_duplicate_nodes_request():
	action_duplicate()

func iterator_return_children(node:Node):
	var children:Array
	if node.get_child_count() >0 :
		for c in node.get_children():
			children.append(c)
		for c in node.get_children():
			for c_c in  iterator_return_children(c):
				children.append(c_c)
	return children
	
func duplicate_node(node:Node , parent:Node) ->Node:
	var d_n:Node = node.duplicate()
	parent.add_child(d_n)
	#重连节点外的接入信号
	for i in node.get_incoming_connections():
		if i.source is Node and i.source != node and not i.source in iterator_return_children(node):
			if not i.source.is_connected(i.signal_name , d_n, i.method_name):
				i.source.connect(i.signal_name , d_n, i.method_name)
	var property_list:Array = node.get_script().get_script_property_list()
	for p in property_list:
		if node[p.name] is Object:
			if node[p.name] is Node:
				#如果属性是节点内部的子节点,让复制节点重新获取其内部的相同节点
				if node[p.name] in iterator_return_children(node) or node[p.name] == node:
					d_n[p.name] = d_n.get_node(node.get_path_to(node[p.name])) 
				#如果属性是节点外部的节点，将改外部节点赋给复制节点
				elif node[p.name]:
					d_n[p.name] = node[p.name]
			elif node[p.name] is Resource:
				#资源类,复制资源   其他类型的Object保持引用
				d_n[p.name] = node[p.name].duplicate()
		else:
			#变量类型
			if d_n[p.name] is Dictionary or d_n[p.name] is Array:
				#容器型，深度复制，断开引用
				d_n[p.name] = node[p.name].duplicate(true)
			else :
				#其他直接赋值，包括pool array，本身没有引用
				d_n[p.name] = node[p.name]
	return d_n


func _on_state_node_mouse_entery(node):
	if editing_transit_flow :
		editing_transit_flow.to = node
		
func _on_GraphEdit_copy_nodes_request():
	copy()

func _on_GraphEdit_paste_nodes_request():
	paste(Vector2(30,20))

func _on_GraphEdit_delete_nodes_request():
	action_delete()




func _on_GraphEdit_resized():
	for t in graph_edit.get_children():
		if t is TransitFlow:
			t.set_offset(t.offset)
func _on_GraphEdit_scroll_offset_changed(ofs):
	if current_nested_fsm_res:
		current_nested_fsm_res.editor_scroll_offset = ofs
	for t in graph_edit.get_children():
		if t is TransitFlow:
			t.set_offset(t.offset)

func _on_entry_nested_request(nested_state: StateNode):
	action_enter_nested(nested_state.nested_fsm_res)
	
var previous_os_low_processor_usage_mode :bool
func _on_GraphEdit_mouse_entered():
	previous_os_low_processor_usage_mode = OS.low_processor_usage_mode
	OS.low_processor_usage_mode = true

func _on_GraphEdit_mouse_exited():
	OS.low_processor_usage_mode = previous_os_low_processor_usage_mode


func _on_CommentVisibleButton_toggled(button_pressed:bool):
	action_switch_comment_visible(button_pressed)

var state_res_to_from_to :Dictionary
func _on_GraphEdit__begin_node_move():
	state_res_to_from_to.clear()
	for c in graph_edit.get_children():
		if c is StateNode and c.is_selected():
			state_res_to_from_to[c.state_res] = [c.offset]

func _on_GraphEdit__end_node_move():
	for s in graph_edit.get_children():
		if s is StateNode and s.state_res in state_res_to_from_to.keys():
			state_res_to_from_to[s.state_res].append(s.offset)
	undo_redo.create_action("Drag Objects")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.DRAG_OBJECTS)
	undo_redo.add_do_method(self, "action_drag" , state_res_to_from_to, true )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.DRAG_OBJECTS)
	undo_redo.add_undo_method(self, "action_drag" , state_res_to_from_to, false )
	undo_redo.commit_action()
	message.set_history(Message.History.DRAG_OBJECTS)
	

#--------------------undo redo sub ------------------------
func action_switch_comment_visible(v:bool):
	undo_redo.create_action("Switch Transition comment visible")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SWITCH_TRANSITION_COMMENT_VISIBLE)
	undo_redo.add_do_method(self , "_set_transition_comment_visible" , v)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SWITCH_TRANSITION_COMMENT_VISIBLE)
	undo_redo.add_undo_method(self , "_set_transition_comment_visible" , !v)
	undo_redo.commit_action()
	message.set_history(Message.History.SWITCH_TRANSITION_COMMENT_VISIBLE)
func _redo_deleted(delete_state_res_list:Array , delete_transition_res_list:Array):
	for c in graph_edit.get_children():
		if (c is StateNode and c.state_res in delete_state_res_list ) or (c is TransitFlow and c.transition_res in delete_transition_res_list):
			c.delete_self()
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	refresh_transition_line()
	get_entry_state_count()
			
func _undo_deleted(delete_state_res_list:Array , delete_transition_res_list:Array , unselected_transition_res_list:Array):
	for s in delete_state_res_list :
		add_state_node(s).selected = true
	for t in delete_transition_res_list :
		var t_f = add_transit_flow(t)
		if not t in unselected_transition_res_list :
			t_f.selected = true 
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	refresh_transition_line()
	get_entry_state_count()
		
func action_delete():
	var state_res_list :Array
	var transition_res_list :Array
	var unselected_transition_res_list :Array
	for c in graph_edit.get_children() :
		if c is StateNode and c.is_selected():
			state_res_list.append(c.state_res)
	for c in graph_edit.get_children():
		if c is TransitFlow and(c.is_selected() or c.from.state_res in state_res_list or c.to.state_res in state_res_list) :
			transition_res_list.append(c.transition_res)
			if not c.is_selected():
				unselected_transition_res_list.append(c.transition_res)
				
	undo_redo.create_action("Delete objects")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.DELETE_OBJECT)
	undo_redo.add_do_method(self , "_redo_deleted" , state_res_list , transition_res_list)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.DELETE_OBJECT)
	undo_redo.add_undo_method(self  , "_undo_deleted" , state_res_list , transition_res_list , unselected_transition_res_list)
	undo_redo.commit_action()	
	message.set_history(Message.History.DELETE_OBJECT)
	
func _undo_add_new_state_node(_state_res:NestedFsmRes.StateRes):
	for c in graph_edit.get_children():
		if c is StateNode and c.state_res == _state_res :
			c.delete_self()
	get_entry_state_count()
	
func action_add_new_state_node(_state_res:NestedFsmRes.StateRes):
	undo_redo.create_action("Add new state")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.ADD_STATE)
	undo_redo.add_do_method(self , "add_state_node" , _state_res )
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.ADD_STATE)
	undo_redo.add_undo_method(self , "_undo_add_new_state_node" , _state_res)
	undo_redo.commit_action()
	message.set_history(Message.History.ADD_STATE)
	
func _undo_add_new_transit_flow(_transition_res:NestedFsmRes.TransitionRes):
	for c in graph_edit.get_children():
		if c is TransitFlow and c.transition_res == _transition_res :
			c.delete_self()
	
func action_add_new_transit_flow(_transition_res:NestedFsmRes.TransitionRes) :
	undo_redo.create_action("Creat new transition")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.CREATE_TRANSITION)
	undo_redo.add_do_method(self , "add_transit_flow" , _transition_res)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.CREATE_TRANSITION)
	undo_redo.add_undo_method(self , "_undo_add_new_transit_flow" , _transition_res)
	undo_redo.commit_action()
	message.set_history(Message.History.CREATE_TRANSITION)
	
func _redo_convert_to_nested(data:Dictionary):
	#重连
	for t in data.reconnect_from_transition_res_list :
		(t as NestedFsmRes.TransitionRes).from_res = data.nested_state_res
	for t in data.reconnect_to_transition_res_list :
		(t as NestedFsmRes.TransitionRes).to_res = data.nested_state_res
	#移动所属
	for s in data.selected_stata_res_list:
		data.request_nested_fsm_res.deleted_state(s)
		data.nested_fsm_res.state_res_list.append(s)
	for t in data.selected_transition_res_list :
		if not t in data.reconnect_from_transition_res_list and not t in data.reconnect_to_transition_res_list :
			data.request_nested_fsm_res.delete_transition(t)
			data.nested_fsm_res.add_transition(t)
	#删除多余
	for t in data.delete_transition_res_list :
		data.request_nested_fsm_res.delete_transition(t)
	#更改设定
	data.nested_state_res.state_type = data.request_state_res.state_type
	
	data.nested_state_res.is_nested = true
	data.nested_state_res.nested_fsm_res = data.nested_fsm_res
	
	data.request_state_res.state_type = HfsmConstant.STATE_TYPE_ENTRY
	if data.exist_entry :
		data.exist_entry.state_type = HfsmConstant.STATE_TYPE_NORMAL
	#添加拷贝
	data.request_nested_fsm_res.add_state(data.nested_state_res)
	#切换状态机
	current_fsm_button.disabled = false
	yield(_set_current_nested_fsm_res(data.nested_fsm_res) , "completed")
	get_entry_state_count()
	
func _undo_convert_to_nested(data:Dictionary):
	#移除拷贝
	data.request_nested_fsm_res.deleted_state(data.nested_state_res)
	#更改设定
	data.request_state_res.state_type = data.request_state_type
	
	if data.exist_entry :
		data.exist_entry.state_type = HfsmConstant.STATE_TYPE_ENTRY
	#还原多余
	for t in data.delete_transition_res_list:
		data.request_nested_fsm_res.add_transition(t)
	#还原所属
	for t in data.selected_transition_res_list :
		data.nested_fsm_res.delete_transition(t)
		data.request_nested_fsm_res.add_transition(t)
	for s in data.selected_stata_res_list:
		if s in data.nested_fsm_res.transition_res_list:
			data.nested_fsm_res.deleted_state(s)
			data.request_nested_fsm_res.add_state(s)
	#还原重连
	for t in data.reconnect_from_transition_res_list :
		(t as NestedFsmRes.TransitionRes).from_res = data.request_state_res
	for t in data.reconnect_to_transition_res_list :
		(t as NestedFsmRes.TransitionRes).to_res = data.request_state_res
	#弹出最后两个按钮
	for i in range(switch_buttons.get_child_count()-2 , switch_buttons.get_child_count()) :
		switch_buttons.get_child(i).delete_self()
	#切换状态机
	current_fsm_button.disabled = false
	yield(_set_current_nested_fsm_res(data.request_nested_fsm_res) , "completed")
	for c in graph_edit.get_children():
		if c is StateNode and c.state_res in data.selected_stata_res_list :
			c.selected = true
		elif c is TransitFlow and c.transition_res in data.selected_transition_res_list :
			c.selected = true
	get_entry_state_count()
	
func action_convert_to_nested(request_node):
	if request_node and request_node is StateNode and request_node.is_selected():
		var data :Dictionary ={
			"request_nested_fsm_res" : current_nested_fsm_res ,
			"request_state_res" : request_node.state_res ,
			"request_state_type" : request_node.state_res.state_type ,
			"nested_fsm_res" : NestedFsmRes.new(request_node.state_name , true) ,
			"nested_state_res" : NestedFsmRes.StateRes.new(request_node.offset , request_node.state_name) , 
			"reconnect_from_transition_res_list" : [] ,
			"reconnect_to_transition_res_list" : [] ,
			"delete_transition_res_list" : [],
			"selected_stata_res_list" : [] ,
			"selected_transition_res_list" :[],
			"exist_entry":null ,
		}
		for t in graph_edit.get_children():
			if t is TransitFlow:
				if t.from == request_node and not t.to.is_selected():
					data.reconnect_from_transition_res_list.append(t.transition_res)
				elif t.to == request_node and not t.from.is_selected():
					data.reconnect_to_transition_res_list.append(t.transition_res)
				elif (t.from.is_selected() and not t.to.is_selected()) or (not t.from.is_selected() and t.to.is_selected()) :
					data.delete_transition_res_list.append(t.transition_res)

		for c in graph_edit.get_children() :
			if c is StateNode and c.is_selected():
				data.selected_stata_res_list.append(c.state_res)
				if c.state_res.state_type == HfsmConstant.STATE_TYPE_ENTRY:
					data.exist_entry = c.state_res
					
			elif c is TransitFlow and c.is_selected():
				data.selected_transition_res_list.append(c.transition_res)
				
		undo_redo.create_action("Convert to nested state machine")
		undo_redo.add_do_method(message,"set_redo_history",message.History.CONVERT_TO_NESTED_STATE_MACHINE)
		undo_redo.add_do_method(self , "_redo_convert_to_nested",data)
		undo_redo.add_undo_method(message,"set_undo_history",message.History.CONVERT_TO_NESTED_STATE_MACHINE)
		undo_redo.add_undo_method(self , "_undo_convert_to_nested" ,data)
		undo_redo.commit_action()
		message.set_history(Message.History.CONVERT_TO_NESTED_STATE_MACHINE)

func _redo_paste(s_state_res_list:Array ,s_transition_res_list :Array ,state_res_origin_to_duplicate:Dictionary , d_transition_res_list :Array ):
	for s in state_res_origin_to_duplicate.values() :
		current_nested_fsm_res.add_state(s) 
		current_nested_fsm_res.make_state_name_unique(s)
		add_state_node(s).selected = true
	for t in d_transition_res_list:
		current_nested_fsm_res.add_transition(t)
		add_transit_flow(t).selected = true
	for c in graph_edit.get_children() :
		if c is StateNode and c.state_res in s_state_res_list :
			c.selected = false
		elif c is TransitFlow and c.transition_res in s_transition_res_list :
			c.selected = false
	get_entry_state_count()
			
func _undo_paste(s_state_res_list:Array ,s_transition_res_list :Array ,state_res_origin_to_duplicate:Dictionary , d_transition_res_list :Array ) :
	for c in graph_edit.get_children() :
		if c is StateNode :
			if c.state_res in s_state_res_list :
				c.selected = true 
			elif c.state_res in state_res_origin_to_duplicate.values() :
				c.delete_self()
		elif c is TransitFlow:
			if c.transition_res in s_transition_res_list :
				c.selected = true
			elif c.transition_res in d_transition_res_list :
				c.delete_self()
	get_entry_state_count()
		
		
func action_duplicate():
	var s_state_res_list:Array
	var s_transition_res_list :Array 
	var state_res_origin_to_duplicate:Dictionary
	var d_transition_res_list :Array 
	
	for c in graph_edit.get_children() :
		if c is StateNode and c.is_selected() :
			s_state_res_list.append(c.state_res)
		elif c is TransitFlow and c.is_selected():
			s_transition_res_list.append(c.transition_res)
	
	for s in s_state_res_list :
		state_res_origin_to_duplicate[s] = s.duplicate_self()
		state_res_origin_to_duplicate[s].editor_offset += Vector2(30,20)
	for t in s_transition_res_list :
		if t.from_res in s_state_res_list and t.to_res in s_state_res_list :
			var d_t :NestedFsmRes.TransitionRes = t.duplicate_self()
			d_t.from_res = state_res_origin_to_duplicate[t.from_res]
			d_t.to_res = state_res_origin_to_duplicate[t.to_res]
			d_transition_res_list.append(d_t)
	if state_res_origin_to_duplicate.size()>0 :
		undo_redo.create_action("Duplicate seleccted objcet")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.DUPLICATE)
		undo_redo.add_do_method(self , "_redo_paste",s_state_res_list ,s_transition_res_list ,state_res_origin_to_duplicate , d_transition_res_list )
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.DUPLICATE)
		undo_redo.add_undo_method(self , "_undo_paste",s_state_res_list ,s_transition_res_list ,state_res_origin_to_duplicate , d_transition_res_list )
		undo_redo.commit_action()
		message.set_history(Message.History.DUPLICATE)
	
func action_drag(state_res_to_from_to :Dictionary,do:bool ):
	for s in graph_edit.get_children() :
		if s is StateNode and s.state_res in state_res_to_from_to.keys():
			if do:
				s.offset = state_res_to_from_to[s.state_res][1]
			else :
				s.offset = state_res_to_from_to[s.state_res][0]
			(s.state_res as NestedFsmRes.StateRes).editor_offset = s.offset
	
func action_paste(offset:Vector2) :
	var s_state_res_list:Array
	var s_transition_res_list :Array 
	var state_res_origin_to_duplicate:Dictionary
	var d_transition_res_list :Array 
	
	s_state_res_list = copy_state_list.duplicate()
	s_transition_res_list = copy_transition_list.duplicate()
	
	for s in s_state_res_list :
		state_res_origin_to_duplicate[s] = s.duplicate_self()
		state_res_origin_to_duplicate[s].editor_offset += offset
	for t in s_transition_res_list :
		if t.from_res in s_state_res_list and t.to_res in s_state_res_list :
			var d_t :NestedFsmRes.TransitionRes = t.duplicate_self()
			d_t.from_res = state_res_origin_to_duplicate[t.from_res]
			d_t.to_res = state_res_origin_to_duplicate[t.to_res]
			d_transition_res_list.append(d_t)
	if state_res_origin_to_duplicate.size()>0 :
		undo_redo.create_action("Paste copied objcet")
		undo_redo.add_do_method(message,"set_redo_history",Message.History.PASTE)
		undo_redo.add_do_method(self , "_redo_paste",s_state_res_list ,s_transition_res_list ,state_res_origin_to_duplicate , d_transition_res_list )
		undo_redo.add_undo_method(message,"set_undo_history",Message.History.PASTE)
		undo_redo.add_undo_method(self , "_undo_paste",s_state_res_list ,s_transition_res_list ,state_res_origin_to_duplicate , d_transition_res_list )
		undo_redo.commit_action()
		message.set_history(Message.History.PASTE)

func _redo_switch_fsm(index:int , target_nested_fsm_res:NestedFsmRes):
	for i in range(index , switch_buttons.get_child_count()):
		switch_buttons.get_child(i).delete_self()
	yield(get_tree() ,"idle_frame")
	_set_current_nested_fsm_res(target_nested_fsm_res)

	
func _undo_switch_fsm(res_path:Array):
	for i in range(1,res_path.size()):
		yield(_set_current_nested_fsm_res(res_path[i]), "completed")
	
		
func action_switch_fsm(switch_button:SwithcButton):
	var res_path:Array
	for i in range(switch_button.get_index() , switch_buttons.get_child_count()):
		res_path.append(switch_buttons.get_child(i).nested_fsm_res)
	
	undo_redo.create_action("Switch Finite State Machine")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SWITCH_CURRENT_STATE_MACHINE)
	undo_redo.add_do_method(self ,"_redo_switch_fsm" , switch_button.get_index() , switch_button.nested_fsm_res)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SWITCH_CURRENT_STATE_MACHINE)
	undo_redo.add_undo_method(self ,"_undo_switch_fsm" , res_path)
	undo_redo.commit_action()
	message.set_history(Message.History.SWITCH_CURRENT_STATE_MACHINE)

func _undo_enter_nested(previous_hfsm_res:NestedFsmRes):
	switch_buttons.get_child(switch_buttons.get_child_count()-1).delete_self()
	switch_buttons.get_child(switch_buttons.get_child_count()-2).delete_self()
	yield(get_tree() ,"idle_frame")
	_set_current_nested_fsm_res(previous_hfsm_res)

func action_enter_nested(target_nested_res :NestedFsmRes):
	undo_redo.create_action("Enter nested Finite State Machine")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.ENTER_NESTED_STATE_MACHINE)
	undo_redo.add_do_method(self , "_set_current_nested_fsm_res",target_nested_res)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.ENTER_NESTED_STATE_MACHINE)
	undo_redo.add_undo_method(self , "_undo_enter_nested" ,current_nested_fsm_res )
	undo_redo.commit_action()
	message.set_history(Message.History.ENTER_NESTED_STATE_MACHINE)


func action_create_enter_state():
	var entry_res = NestedFsmRes.StateRes.new(Vector2(200,200),"entry",HfsmConstant.STATE_TYPE_ENTRY)
	undo_redo.create_action("Add new state")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.ADD_STATE)
	undo_redo.add_do_method(self , "add_state_node" , entry_res )
	undo_redo.add_do_property(not_state_warming , "visible" , false)
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.ADD_STATE)
	undo_redo.add_undo_method(self , "_undo_add_new_state_node" , entry_res)
	undo_redo.add_undo_property(not_state_warming , "visible" , true)
	undo_redo.commit_action()
	message.set_history(Message.History.ADD_STATE)

func _on_Button_pressed():
	action_create_enter_state()
