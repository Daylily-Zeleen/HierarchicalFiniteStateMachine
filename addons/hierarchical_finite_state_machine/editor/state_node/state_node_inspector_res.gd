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
extends Resource
const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
const NestedFsmRes = preload("../../script/source/nested_fsm_res.gd")

var state_node :GraphNode
##-------------------
var state_name :String setget _set_state_name , _get_state_name 
func _set_state_name(n :String):
	state_node.state_name = n
func _get_state_name():
	if state_node :
		return state_node.state_name
	

var state_type :int setget _set_state_type , _get_state_type
func _set_state_type(t :int) :
	state_node.action_set_state_type(state_node.state_type , t)
	state_node.state_type = t
func _get_state_type():
	if state_node:
		return state_node.state_type
	

var state_script :Script setget _set_state_script , _get_state_script
func _set_state_script(s:Script):
	state_node._load_state_script(s)
func _get_state_script():
	if state_node:
		return state_node.state_script

var is_nested :bool setget _set_is_nested , _get_is_nested
func _set_is_nested(i :bool):
	state_node.action_set_is_nested(state_node.is_nested , i)

func _get_is_nested ():
	if state_node:
		return state_node.is_nested
var reset_properties_when_entry:bool setget _set_reset_properties_when_entry,_get_reset_properties_when_entry
func _set_reset_properties_when_entry(v:bool):
	state_node.action_set_reset_properties_when_entry(v)
	property_list_changed_notify ()
func _get_reset_properties_when_entry():
	if state_node:
		return state_node.reset_properties_when_entry 
var nested_fsm_res :NestedFsmRes

var reset_nested_fsm_when_entry:bool setget _set_reset_nested_fsm_when_entry , _get_reset_nested_fsm_when_entry
func _set_reset_nested_fsm_when_entry(v:bool):
	state_node.action_set_reset_nested_fsm_when_entry(v)
	yield(state_node.get_tree(),"idle_frame")
	property_list_changed_notify ()
func _get_reset_nested_fsm_when_entry():
	if state_node:
		return state_node.reset_nested_fsm_when_entry

func _init(_state_node):
	state_node = _state_node


func _get_property_list():
	var properties :Array
	properties.push_back({name = "State",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "state_name",type = TYPE_STRING })
	properties.push_back({name = "state_type",type = TYPE_INT , hint = PROPERTY_HINT_ENUM , hint_string = "Normal,ENTRY,EXIT" })
	properties.push_back({name = "reset_properties_when_entry",type = TYPE_BOOL })
	properties.push_back({name = "state_script",type = TYPE_OBJECT , hint =  PROPERTY_HINT_RESOURCE_TYPE  , hint_string = "GDScript,CSharpScript"})
	properties.push_back({name = "is_nested",type = TYPE_BOOL })
	if _get_is_nested () :
		properties.push_back({name = "reset_nested_fsm_when_entry",type = TYPE_BOOL })
		properties.push_back({name = "nested_fsm_res",type = TYPE_OBJECT , hint =  PROPERTY_HINT_RESOURCE_TYPE ,usage = PROPERTY_USAGE_STORAGE })

	return properties

