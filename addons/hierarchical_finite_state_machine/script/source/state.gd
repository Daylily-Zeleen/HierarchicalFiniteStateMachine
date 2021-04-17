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
#	@author   Daylily-Zeleen                                                      
#	@email    735170336@qq.com                                              
#	@version  0.1(版本号)                                                       
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)                                
#                                                                      
#----------------------------------------------------------------------------
#  Remark         : this is the State class's script,you can see it API in this script。
#					这是State类的脚本，您可以在此脚本中查看State类的API。                                            
#----------------------------------------------------------------------------
#  Change History :                                                          
#  <Date>     | <Version> | <Author>       | <Description>                   
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file                     
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
extends Reference
const HFSM = preload("../hfsm.gd")

#======================================================
#-------------------Properties-------------------------
#======================================================

#------------------------------------------------------------------------------
#@description : Read only.the name of this State.
#----------------------------------------------------
var state_name :String = "" setget _set_state_name,get_state_name

#------------------------------------------------------------------------------
#@description : Read only.the instance of HFSM,which contain this State.
#------------------------------------------------------------------------------
var hfsm:HFSM  setget _set_hfsm , get_hfsm

#------------------------------------------------------------------------------
#@description : Read only.if true,this State is exited.
#------------------------------------------------------------------------------
var is_exited:bool = false setget _set_is_exit, is_exited

#======================================================
#--------------------Methods---------------------------
#======================================================

#------------------------------------------------------------------------------
#@description : manually exit this State.
#@note : if this state is exited,it will not update and physics update anymore,
#		and can trigger auto transit,if the auto transition which start State is this,
#		and auto transit mode is "Manual Exit".
#------------------------------------------------------------------------------
func manual_exit()->void:
	if not is_exited:
		is_exited = true
		exit()
		
#------------------------------------------------------------------------------
#@description : getter of property 'state_name'.
#------------------------------------------------------------------------------
func get_state_name():
	return state_name

#------------------------------------------------------------------------------
#@description : getter of property 'hfsm'.
#------------------------------------------------------------------------------
func get_hfsm():
	return hfsm
	
#------------------------------------------------------------------------------
#@description : getter of property 'is_exited'.
#------------------------------------------------------------------------------
func is_exited()->bool:
	return is_exited
	








#======================================================
#--------------------Internal--------------------------
#======================================================
func _set_is_exit(v:bool):
	return
	
func _set_state_name(name:String):
	if state_name == "":
		state_name = name
	else :
		printerr("HFSM: Can not set state name when running.")
		
var _state_type :int = 0# 0 normal,1 entry ,2 exit 
func _set_hfsm(_hfsm)->void:
	if _hfsm and not hfsm:#and not _hfsm.is_connected("tree_exited" ,self ,"_on_HFSM_tree_exited"):
		hfsm = _hfsm
		var p_name_list :Array 
		for p in get_script().get_script_property_list():
			p_name_list.append(p.name)
		for agent in hfsm.agents.keys():
			if agent != "null" and agent in p_name_list:
				self[agent] = hfsm.agents[agent]
		init()
		for property in get_script().get_script_property_list():
			if not property.name in [ "_property_to_default_value" ,"state_name","_state_type","hfsm","_nested_fsm"] and not property.name in hfsm.agents.keys() :
				_property_to_default_value[property.name] = self[property.name]
	else :
		printerr("Can not set state property 'hfsm'.")

var _nested_fsm setget _set_nested_fsm
func _set_nested_fsm(v)->void:
	if not _nested_fsm:
		_nested_fsm = v
	else:
		printerr("HFSM:Can not set state property '_nested_fsm' when running.")

var _transition_list:Array 

var _reset_when_entry:bool
var _property_to_default_value:Dictionary
	
func _entry()->void:
	is_exited = false
	if not _reset_when_entry:
		_reset()
	for transition in _transition_list :
		transition.refresh()
	entry()
	if _nested_fsm:
		_nested_fsm._entry()
	
func _update(delta:float)->void:
	if not is_exited:
		update(delta)
func _physics_update(delta:float)->void:
	if not is_exited:
		physics_update(delta)
func _exit(is_terminated_by_upper_level:bool = false )->void:
	if not is_exited:
		is_exited = true
		if not is_terminated_by_upper_level:
			var queue :Array = [self] 
			while queue.back()._nested_fsm and queue.back()._nested_fsm.is_running:
				queue.push_back(queue.back()._nested_fsm._current_state)
			while not queue.empty():
				queue.pop_back()._exit(true)
		else :
			if _nested_fsm and _nested_fsm.is_running:
				_nested_fsm._exit_by_state()
		exit()
	
func _reset()->void:
	for property_name in _property_to_default_value.keys():
		self[property_name] = _property_to_default_value[property_name]
#-------override-----------
func init()->void:
	pass
func entry()->void:
	pass
func update(delta:float)->void:
	pass
func physics_update(delta:float)->void:
	pass
func exit()->void:
	pass
