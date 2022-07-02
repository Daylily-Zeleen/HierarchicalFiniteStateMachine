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
#  2021/07/2 | 0.1   | Daylily-Zeleen      | Support C# state script     
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
tool
extends GraphNode

const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
const Message = preload("../message.gd")
const NestedFsmRes = preload("../../script/source/nested_fsm_res.gd")
const StateRes = NestedFsmRes.StateRes
const StateNodeInspectRes = preload("state_node_inspector_res.gd")
signal entry_nested_request(state_node)
#-------------------标识函数-------------------
func StateNode()->void:
	pass
	
#--------properties----------------
var hfsm_editor :Node
var undo_redo :UndoRedo
var message :Message



var state_res :StateRes setget _set_state_res
func _set_state_res(res :StateRes) :
	state_res = res
	if not state_res.is_connected("param_updated" , self ,"_on_StateRes_param_updated") :
		state_res.connect("param_updated" , self ,"_on_StateRes_param_updated")
		
	(hfsm_editor.current_nested_fsm_res as NestedFsmRes).add_state(res)
	if state_res :
		set_offset(state_res.editor_offset)
		_set_state_name(state_res.state_name)
		_set_is_nested(state_res.is_nested)
		_set_state_type(state_res.state_type)
		_set_nested_hfsm_res(state_res.nested_fsm_res)
		_set_state_script(state_res.state_script)
	update_nested_state_script()

var inspector_res :StateNodeInspectRes

var state_name :String = "state" setget _set_state_name ,_get_state_name
func _set_state_name(n :String):
	if n.length() > 0: 
		
		state_name = n
		name = n
		state_res.state_name = n
		if name_edit:
			name_edit.set_text(state_name)
func _get_state_name() ->String:
	return state_res.state_name

export(int ,"Normal" , "ENTRY" , "EXIT") var state_type :int = HfsmConstant.STATE_TYPE_NORMAL setget  _set_state_type,_get_state_type
func _set_state_type(t :int):
	state_res.state_type = t 

	match t:
		HfsmConstant.STATE_TYPE_NORMAL:
			overlay = OVERLAY_DISABLED
		HfsmConstant.STATE_TYPE_ENTRY :
			overlay = OVERLAY_BREAKPOINT
		HfsmConstant.STATE_TYPE_EXIT :
			overlay = OVERLAY_POSITION
	
func _get_state_type():
	return state_res.state_type


var nested_fsm_res :NestedFsmRes setget _set_nested_hfsm_res, _get_nested_hfsm_res
func _set_nested_hfsm_res(nested_fsm_res :NestedFsmRes) :
	state_res.nested_fsm_res = nested_fsm_res
func _get_nested_hfsm_res():
	return state_res.nested_fsm_res 
		
#是否嵌套状态机
export(bool)var is_nested :bool = false setget _set_is_nested,_get_is_nested
func _set_is_nested(v:bool):
	state_res.is_nested = v 
	if nested_button:
		nested_button.visible = v
		set_deferred("rect_size",Vector2.ZERO)
	if not nested_fsm_res:
		nested_fsm_res = NestedFsmRes.new(_get_state_name() , true)
func _get_is_nested():
	return state_res.is_nested 

#状态脚本
export(Script) var state_script:Script setget _set_state_script,_get_state_script
func _set_state_script(new_script:Script):
	if new_script and new_script.resource_path != "" :
		state_res.state_script = new_script 
		get_node("MarginContainer/ScriptTip").show()
	else :
		state_res.state_script = null 
		get_node("MarginContainer/ScriptTip").hide()
func _get_state_script():
	return state_res.state_script

export(bool) var reset_properties_when_entry:bool setget _set_disable_properties_reset_when_entry ,_get_disable_properties_reset_when_entry
func _set_disable_properties_reset_when_entry(v:bool):
	state_res.reset_properties_when_entry = v
func _get_disable_properties_reset_when_entry():
	return state_res.reset_properties_when_entry
	
export(bool) var reset_nested_fsm_when_entry:bool setget _set_nested_fsm_force_reset_when_entry,_get_nested_fsm_force_reset_when_entry
func _set_nested_fsm_force_reset_when_entry(v:bool):
	state_res.reset_nested_fsm_when_entry = v
func _get_nested_fsm_force_reset_when_entry():
	return state_res.reset_nested_fsm_when_entry
#
#-----------Nodes-------------
onready var name_edit:LineEdit = get_node("MarginContainer/HBoxContainer/NameEdit") 
onready var nested_button :Button =get_node("MarginContainer/HBoxContainer/NestedButton")
#
func init(editor , _state_res:NestedFsmRes.StateRes = NestedFsmRes.StateRes.new() ):
	hfsm_editor = editor
	undo_redo = hfsm_editor.undo_redo
	message = hfsm_editor.message
	_set_state_res(_state_res)
	inspector_res = StateNodeInspectRes.new(self)


func make_state_name_unique():
	var exist_name_list :Array 
	for s_res in hfsm_editor.current_nested_fsm_res.state_res_list:
		if s_res is StateRes and s_res !=  state_res:
			exist_name_list.append(s_res.state_name)
	while state_name in exist_name_list:
		state_name += "_"
	_set_state_name(state_name)

func _get_children(node:Node)->Array:
	var list:Array
	for c in node.get_children():
		list.append(c)
		if c.get_child_count() >0:
			for c_c in _get_children(c) :
				list.append(c_c)
	return list
		
func create_new_script():
	var scd :ScriptCreateDialog = hfsm_editor.the_plugin.script_create_dialog
	var res_path :String = hfsm_editor.current_hfsm._root_fsm_res.resource_path
	var folder_path :String = res_path.substr(0,res_path.find("::")).get_base_dir()
	var dir :Directory = Directory.new()
	var new_name :String = "hfsm_state_" + _get_state_name()
	while dir.file_exists(folder_path + "/"+new_name+".gd" ) or dir.file_exists(folder_path + "/"+new_name+".cs" ) :
		new_name += "_"
	scd.config(HfsmConstant.ExtendsPath , folder_path.plus_file(new_name))
	for n in _get_children(scd):
		var setted:bool = false
		if n is OptionButton:
			for i in n.get_popup().get_item_count():
				if n.get_popup().get_item_text(i) == HfsmConstant.TemplateName:
					n.select(i)
					scd._template_changed(i)
					setted = true
					break
		if setted :
			break
	scd.popup_centered()
	if not scd.is_connected("script_created",self ,"_on_SCD_script_created") :
		scd.connect("script_created",self ,"_on_SCD_script_created") 
	if not scd.is_connected("popup_hide",self , "_on_SCD_script_popup_hide") :
		scd.connect("popup_hide",self , "_on_SCD_script_popup_hide") 
		
func attach_exist_script():
	var ssd :FileDialog = hfsm_editor.the_plugin.script_select_dialog
	if not ssd.is_connected("file_selected", self, "_on_script_file_selected") :
		ssd.connect("file_selected", self, "_on_script_file_selected")
		if not ssd.is_connected("popup_hide", self, "_on_script_select_dialog_popup_hide") :
			ssd.connect("popup_hide", self, "_on_script_select_dialog_popup_hide")
		var res_path = hfsm_editor.current_hfsm._root_fsm_res.resource_path
		ssd.current_dir = res_path.substr(0,res_path.find("::")).get_base_dir()
		ssd.popup_centered()
# ---------- signals -------------
func _on_StateRes_param_updated():
	match state_res.state_type:
		HfsmConstant.STATE_TYPE_NORMAL:
			overlay = OVERLAY_DISABLED
		HfsmConstant.STATE_TYPE_ENTRY :
			overlay = OVERLAY_BREAKPOINT
		HfsmConstant.STATE_TYPE_EXIT :
			overlay = OVERLAY_POSITION
	
	nested_button.visible = state_res.is_nested
	set_deferred("rect_size",Vector2.ZERO)
	
func _on_NameEdit_text_changed(new_text :String):
	if new_text.length()>0 :
		state_name = new_text
		name = new_text
		state_res.state_name = new_text
	set_deferred("rect_size",Vector2.ZERO)
	(hfsm_editor.the_plugin as EditorPlugin).get_editor_interface().get_inspector().refresh()
	
func _on_NameEdit_focus_exited():
	name_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_edit.selecting_enabled = false
	name_edit.editable = false
	action_change_state_name(old_name , state_name)

func _on_NameEdit_text_entered(new_text):
	make_state_name_unique()
	_set_state_name(new_text)
	set_deferred("rect_size",Vector2.ZERO)
	name_edit.release_focus()


#被选中
func _on_selected(node):
	if node ==self:
		pass

func _on_unselected(node):
	if node ==self:
		if name_edit.selecting_enabled and name_edit.editable:
			make_state_name_unique()
		name_edit.selecting_enabled = false
		name_edit.editable = false



var double_click_flag :bool = false
func _on_State_gui_input(event):
	if hfsm_editor.editing_transit_flow :
		name_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_edit.selecting_enabled = false
		name_edit.editable = false
	if event is InputEventMouseButton:
		if event.pressed and event.button_index ==BUTTON_LEFT and event.doubleclick and double_click_flag == false :
			double_click_flag = true
		elif not event.pressed and event.button_index ==BUTTON_LEFT :
			if double_click_flag :
				double_click_flag = false 
				var state_script :Script = _get_state_script()
				if state_script :
					#双击打开脚本
					hfsm_editor.the_plugin.get_editor_interface().edit_resource(state_script)
				else :
					#没有脚本则弹出选择对话框
					attach_exist_script()
					
			else :
				if name_edit.get_rect().has_point(name_edit.get_parent().get_local_mouse_position()) :
					yield(get_tree().create_timer(1) ,"timeout")
					name_edit.mouse_filter = Control.MOUSE_FILTER_STOP

func _load_state_script(path_or_script):
	var new_script :Script 
	if path_or_script is String:
		if not path_or_script.empty():
			new_script = load(path_or_script)
		else:
			new_script = null
	else:
		if path_or_script is Script:
			new_script = path_or_script
		else:
			new_script = null
	if new_script and ("::" in new_script.resource_path or not (HfsmConstant.Extends in new_script.source_code.replace(" ","") or HfsmConstant.Extends_ in new_script.source_code.replace(" ",""))):
		if new_script is GDScript and (not HfsmConstant.AgentsStartMark in new_script.source_code or not HfsmConstant.AgentsEndMark in new_script.source_code or not HfsmConstant.NestedFsmStateStartMark in new_script.source_code or not HfsmConstant.NestedFsmStateEndMark in new_script.source_code ):
			create_new_script()
			printerr("HFSM : attach script faild,the script is not obey the 'Hfsm State Template'.")
			return
		elif new_script.get_class() == "CSharpScript":
			print("HFSM: attach a c# script, currently can't check it is valid or not, please ensure your script is inhirt from HFSM.State.")
	action_set_state_script(_get_state_script() , new_script)
	
	var hfsm_inspector_res = hfsm_editor.current_hfsm._inspector_res
	hfsm_inspector_res.agents = hfsm_inspector_res.agents 
	update_nested_state_script()

func _on_SCD_script_created(new_script:Script)->void:
	_load_state_script(new_script)
func _on_SCD_script_popup_hide():
	var scd :ScriptCreateDialog = hfsm_editor.the_plugin.script_create_dialog
	scd.disconnect("script_created",self ,"_on_SCD_script_created") 
	scd.disconnect("popup_hide",self , "_on_SCD_script_popup_hide") 
	
func _on_script_file_selected(file_path:String):
	_load_state_script(file_path)
	hfsm_editor.the_plugin.script_select_dialog.disconnect("file_selected", self, "_on_script_file_selected")
	hfsm_editor.the_plugin.script_select_dialog.disconnect("popup_hide", self, "_on_script_select_dialog_popup_hide")
func _on_script_select_dialog_popup_hide():
	hfsm_editor.the_plugin.script_select_dialog.disconnect("file_selected", self, "_on_script_file_selected")
	hfsm_editor.the_plugin.script_select_dialog.disconnect("popup_hide", self, "_on_script_select_dialog_popup_hide")
	
var old_name:String
func _on_NameEdit_gui_input(event):
	if hfsm_editor.editing_transit_flow :
		name_edit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_edit.selecting_enabled = false
		name_edit.editable = false
	if event is InputEventMouseButton and name_edit.mouse_filter == Control.MOUSE_FILTER_STOP:
		#单击松开
		if not event.pressed and event.button_index == BUTTON_LEFT :
			name_edit.selecting_enabled = true
			name_edit.editable = true
			#undoredo
			old_name = _get_state_name()


func delete_self():
	hfsm_editor.current_nested_fsm_res.deleted_state(state_res)
	queue_free()


func _on_State_dragged(from, to):
	state_res.editor_offset = offset


func _on_NestedButton_pressed():
	if hfsm_editor.editing_transit_flow:
		return
	if not _get_nested_hfsm_res():
		_set_nested_hfsm_res(NestedFsmRes.new(_get_state_name() , true))
	if state_name.length():
		name = state_name
	emit_signal("entry_nested_request" , self)


func _fresh_inspector():
	if inspector_res:
		inspector_res.property_list_changed_notify()

func update_nested_state_script():
	var nested_state_res_list :Array= hfsm_editor.current_hfsm._root_fsm_res.get_all_nested_state_res()
	for res in nested_state_res_list:
		if res is StateRes:
			res.update_nested_state_script()
	hfsm_editor.the_plugin._on_script_reload_request()
	var inspector_res = hfsm_editor.current_hfsm._inspector_res
	if is_instance_valid(inspector_res):
		inspector_res.call_deferred("_change_script_agents")
#------------undo redo----------------
func action_change_state_name(old_name , new_name):
	undo_redo.create_action("Set state_name")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_NAME)
	undo_redo.add_do_property(state_res,"state_name" , new_name)
	undo_redo.add_do_property(self,"state_name" , new_name)
	undo_redo.add_do_property(self,"name" , new_name)
	undo_redo.add_do_property(self,"rect_size" , Vector2.ZERO)
	undo_redo.add_do_method(self , "update_nested_state_script")
	undo_redo.add_do_method(self , "_fresh_inspector")
	
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_NAME)
	undo_redo.add_undo_property(state_res,"state_name" , old_name)
	undo_redo.add_undo_property(self,"state_name" , old_name)
	undo_redo.add_undo_property(self,"name" , old_name)
	undo_redo.add_undo_property(self,"rect_size" , Vector2.ZERO)
	undo_redo.add_undo_method(self , "update_nested_state_script")
	undo_redo.add_undo_method(self , "_fresh_inspector")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_NAME)

func action_set_state_script(old_script , new_script):
	undo_redo.create_action("Set state_script")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_SCRIPT)
	undo_redo.add_do_property(state_res , "state_script", new_script)
	undo_redo.add_do_property(get_node("MarginContainer/ScriptTip") , "visible", true if new_script else false)
	undo_redo.add_do_method(self , "update_nested_state_script")
	undo_redo.add_do_method(self , "_fresh_inspector")
	
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_SCRIPT)
	undo_redo.add_undo_property(state_res , "state_script", old_script)
	undo_redo.add_undo_property(get_node("MarginContainer/ScriptTip") , "visible", true if old_script else false)
	undo_redo.add_undo_method(self , "update_nested_state_script")
	undo_redo.add_undo_method(self , "_fresh_inspector")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_SCRIPT)

func action_set_state_type(old_type , new_type):
	var old_entry_state_res = (hfsm_editor.current_nested_fsm_res as NestedFsmRes).get_exist_entry_res()
	undo_redo.create_action("Set state_type")
	
	var old_overlay = overlay
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_TYPE)
	undo_redo.add_undo_property(state_res , "state_type" ,old_type)
	undo_redo.add_undo_method(hfsm_editor.current_nested_fsm_res , "set_unique_entry_state" , old_entry_state_res)
	undo_redo.add_undo_property(self , "overlay" ,old_overlay)
	undo_redo.add_undo_method(hfsm_editor , "get_entry_state_count")
	undo_redo.add_undo_method(self , "_fresh_inspector")
	
	var new_overlay
	match new_type:
		HfsmConstant.STATE_TYPE_NORMAL:
			new_overlay = OVERLAY_DISABLED
		HfsmConstant.STATE_TYPE_ENTRY :
			new_overlay = OVERLAY_BREAKPOINT
		HfsmConstant.STATE_TYPE_EXIT :
			new_overlay = OVERLAY_POSITION
			
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_TYPE)
	undo_redo.add_do_property(state_res , "state_type",new_type)
	if new_type == HfsmConstant.STATE_TYPE_ENTRY:
		undo_redo.add_do_method(hfsm_editor.current_nested_fsm_res , "set_unique_entry_state" ,state_res)
	undo_redo.add_do_property(self , "overlay" ,new_overlay)
	undo_redo.add_do_method(hfsm_editor , "get_entry_state_count")
	undo_redo.add_do_method(self , "_fresh_inspector")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_TYPE)
	
func action_set_is_nested(old , new) :
	undo_redo.create_action("Set is_nested")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_IS_NESTED)
	undo_redo.add_do_method(self , "_set_is_nested",new)
	undo_redo.add_do_method(self , "_fresh_inspector")
	undo_redo.add_do_method(self , "set_deferred" , "rect_size" , Vector2.ZERO)
	undo_redo.add_do_method(self , "update_nested_state_script")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_IS_NESTED)
	undo_redo.add_undo_method(self , "_set_is_nested" , old)
	undo_redo.add_undo_method(self , "update_nested_state_script")
	undo_redo.add_undo_method(self , "set_deferred" , "rect_size" , Vector2.ZERO)
	undo_redo.add_undo_method(self , "_fresh_inspector")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_IS_NESTED)
	
func action_set_reset_properties_when_entry(new:bool):
	undo_redo.create_action("Set reset_properties_when_entry")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_AUTO_RESET)
	undo_redo.add_do_property(state_res,"reset_properties_when_entry" , new)
	undo_redo.add_do_method(self , "_fresh_inspector")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_AUTO_RESET)
	undo_redo.add_undo_property(state_res,"reset_properties_when_entry" , !new)
	undo_redo.add_undo_method(self , "_fresh_inspector")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_AUTO_RESET)
	
func action_set_reset_nested_fsm_when_entry(new:bool):
	undo_redo.create_action("Set action_set_reset_nested_fsm_when_entry")
	undo_redo.add_do_method(message,"set_redo_history",Message.History.SET_STATE_NESTED_FSM_AUTO_RESET)
	undo_redo.add_do_property(state_res,"reset_when_entry" , new)
	undo_redo.add_do_method(self , "_fresh_inspector")
	undo_redo.add_do_method(self , "update_nested_state_script")
	undo_redo.add_undo_method(message,"set_undo_history",Message.History.SET_STATE_NESTED_FSM_AUTO_RESET)
	undo_redo.add_undo_property(state_res,"reset_when_entry" , !new)
	undo_redo.add_undo_method(self , "_fresh_inspector")
	undo_redo.add_undo_method(self , "update_nested_state_script")
	undo_redo.commit_action()
	message.set_history(Message.History.SET_STATE_NESTED_FSM_AUTO_RESET)



func _on_State_tree_exiting():
	inspector_res.free()
