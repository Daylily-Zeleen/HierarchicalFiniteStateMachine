##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  735170336@qq.com. 
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
#	@email    735170336@qq.com                                              
#	@version  0.1(版本号)                                                       
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
extends Resource
const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
signal script_reload_request
var hfsm
func _init(_hfsm):
	hfsm = _hfsm


enum ProcessTypes {
	IDLE_AND_PHYSICS , 
	IDLE ,
	PHYSICS ,
	MANUAL ,
}
enum ResetOption {
	NOT_FORCE , 
	FORCE_RESET ,
	FORCE_PERSIST , 
}
var active : bool = true setget set_active, get_active
func set_active(v:bool)->void :
	hfsm.active = v
func get_active()->bool :
	return hfsm.active

var process_type :int = ProcessTypes.IDLE_AND_PHYSICS setget set_process_type , get_process_type
func set_process_type(type :int)->void:
	hfsm.process_type = type
func get_process_type()->int:
	return hfsm.process_type
	
var agents :Dictionary = {"null" : NodePath("")} setget _set_agents , _get_agents
func _set_agents(a:Dictionary)->void:
	for p in hfsm.agents.values():
		var obj:Node = hfsm.owner.get_node_or_null(String(p)) if hfsm.owner else hfsm.get_node_or_null(String(p))
		if not obj:
			obj = hfsm.get_node_or_null(p) 
		if obj:
			if obj.is_connected("renamed",self,"_on_Agents_node_renamed"):
				obj.disconnect("renamed",self,"_on_Agents_node_renamed")
	var obj_to_path :Dictionary
	for k in a.keys():
		var obj = hfsm.owner.get_node_or_null(String(a[k])) if hfsm.owner else hfsm.get_node_or_null(String(a[k]))
		if not obj:
			obj = hfsm.get_node_or_null(a[k])
		if not obj:
			a.erase(k)
		elif not obj in obj_to_path.keys():
			obj_to_path[obj] = a[k]
			obj.connect("renamed",self,"_on_Agents_node_renamed")
	var new_agents :Dictionary 
	for obj in obj_to_path.keys():
		var node_name :String = obj.name
		if not self._disable_rename_to_snake_case :
			node_name = node_name.capitalize().to_lower().replace(" " ,"_")
		while node_name in new_agents.keys():
			push_warning("HFSM : The name of node '%s' already exist in 'agents' ,and be rename by append '_' ,recommend to rename the target node name." % obj.name)
			node_name += "_"
		new_agents[node_name] = obj_to_path[obj]
	new_agents["null"] = NodePath()
	hfsm.agents = new_agents
	_change_script_agents()
	yield(hfsm.get_tree(),"idle_frame")
	yield(hfsm.get_tree(),"idle_frame")
	property_list_changed_notify()
func _get_agents()->Dictionary:
	var a :Dictionary = hfsm.agents.duplicate()
	for k in a.keys():
		if k == "null":
			 a.erase(k)
	a["null"] = NodePath()
	return a

var _disable_rename_to_snake_case :bool = false setget _set_disable_rename_to_snake_case
func _set_disable_rename_to_snake_case(b:bool)->void:
	_disable_rename_to_snake_case = b
	self.agents = self.agents


var _force_all_state_entry_behavior :int = 0 setget _set_force_all_state_reset_behavior , _get_force_all_state_reset_behavior
func  _set_force_all_state_reset_behavior(v:int):
	hfsm._force_all_state_entry_behavior = v
func  _get_force_all_state_reset_behavior():
	return hfsm._force_all_state_entry_behavior
var _force_all_fsm_entry_behavior :int = 0 setget _set_force_all_fsm_auto_reset_behavior , _get_force_all_fsm_auto_reset_behavior
func _set_force_all_fsm_auto_reset_behavior(v:int):
	hfsm._force_all_fsm_entry_behavior = v
func _get_force_all_fsm_auto_reset_behavior():
	return hfsm._force_all_fsm_entry_behavior
	
func _get_property_list()->Array:
	var process_types_hint_string :String
	for i in range(ProcessTypes.size()):
		for enum_key in ProcessTypes.keys():
			if i == ProcessTypes[enum_key]:
				if process_types_hint_string != "":
					process_types_hint_string += ","
				process_types_hint_string += (enum_key as String).capitalize()
				
	var reset_option_hint_string :String
	for i in range(ResetOption.size()):
		for enum_key in ResetOption.keys():
			if i == ResetOption[enum_key]:
				if reset_option_hint_string != "":
					reset_option_hint_string += ","
				reset_option_hint_string += (enum_key as String).capitalize()
	var properties :Array
	properties.push_back({name = "HFSM",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "active",type = TYPE_BOOL })
	properties.push_back({name = "process_type",type = TYPE_INT , hint = PROPERTY_HINT_ENUM ,hint_string = process_types_hint_string })
	properties.push_back({name = "agents",type = TYPE_DICTIONARY })
	
	properties.push_back({name = "Advanced Setting" , type = TYPE_NIL , usage = PROPERTY_USAGE_GROUP})
	
	properties.push_back({name = "_disable_rename_to_snake_case",type = TYPE_BOOL })
	properties.push_back({name = "_force_all_state_entry_behavior",type = TYPE_INT,hint = PROPERTY_HINT_ENUM , hint_string = reset_option_hint_string })
	properties.push_back({name = "_force_all_fsm_entry_behavior",type = TYPE_INT,hint = PROPERTY_HINT_ENUM  , hint_string = reset_option_hint_string})
	properties.push_back({name = "_root_fsm_res",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string ="Resource" ,usage = PROPERTY_USAGE_STORAGE})
	
	return properties

func _change_script_agents():
	var agents_text :String = HfsmConstant.AgentsStartMark
	for agent_name in self.agents.keys():
		var obj:Node = hfsm.owner.get_node_or_null(String(self.agents[agent_name]))if hfsm.owner else hfsm.get_node_or_null(String(self.agents[agent_name]))
		if not obj:
			obj = hfsm.get_node_or_null(self.agents[agent_name])
		var obj_class :String 
		if obj:
			if not obj_class :
				obj_class = obj.get_class()
			agents_text += "var %s : %s \n"%[agent_name , obj_class]
	agents_text += HfsmConstant.AgentsEndMark
	
	var state_script_to_state:Dictionary = hfsm._root_fsm_res.get_state_script_to_state()
	for s_s in state_script_to_state.keys() :
		var code_text:String = s_s.source_code
		if HfsmConstant.Extends in code_text.replace(" ","") or HfsmConstant.Extends_ in code_text.replace(" ",""):
			if HfsmConstant.AgentsStartMark in code_text and HfsmConstant.AgentsEndMark in code_text:
				var start_index :int = code_text.find(HfsmConstant.AgentsStartMark) 
				var end_index :int = code_text.find(HfsmConstant.AgentsEndMark) + HfsmConstant.AgentsEndMark.length()
				var replace_text = code_text.substr(start_index , end_index-start_index)
				code_text = code_text.replace(replace_text , agents_text)
		var tmp_script
		if s_s is GDScript:
			tmp_script = GDScript.new()
		tmp_script.source_code = code_text
		
		var tmp :Resource = Resource.new()
		tmp.take_over_path(s_s.resource_path)
		tmp.resource_path = ""
		ResourceSaver.save(s_s.resource_path, tmp_script)
			
	emit_signal("script_reload_request")

func _on_Agents_node_renamed():
	var size:int = self.agents.size()
	self.agents = self.agents
	if size > self.agents.size() :
		printerr("HFSM :the agent node has been renamed and lost reference , consider to add it again.")

