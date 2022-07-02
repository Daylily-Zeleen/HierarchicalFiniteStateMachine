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
#  2021/07/2 | 0.8   | Daylily-Zeleen      | Support script transition (full version)                     
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
extends Resource

const TransitionRes = preload("../../script/source/nested_fsm_res.gd").TransitionRes
var transit_flow 
#-------------------
var from_state setget ,get_from_state
func get_from_state():
	if transit_flow:
		return transit_flow.from.state_name
	return "Null" 
var to_state setget ,get_to_state
func get_to_state():
	if transit_flow:
		return transit_flow.to.state_name
	return "Null"

var transition_type :int setget set_transition_type , get_transition_type
func set_transition_type(type:int):
	if transit_flow:
		transit_flow.transition_type = type
func get_transition_type():
	if transit_flow:
		return transit_flow.transition_type
	return 0

var auto_condition_res :TransitionRes.AutoConditionRes =TransitionRes.AutoConditionRes.new() setget _set_auto_condition_res , _get_auto_condition_res
func _set_auto_condition_res(auto_res:TransitionRes.AutoConditionRes ) :
	if transit_flow:
		transit_flow.auto_condition_res = auto_res
func _get_auto_condition_res():
	if transit_flow:
		return transit_flow.auto_condition_res
		
var expression_condition_res :TransitionRes.ExpressionConditionRes = TransitionRes.ExpressionConditionRes.new() setget _set_expression_condition_res , _get_expression_condition_res
func _set_expression_condition_res(expresstion_res :TransitionRes.ExpressionConditionRes):
	if transit_flow:
		transit_flow.expression_condition_res = expresstion_res
func _get_expression_condition_res():
	if transit_flow:
		return transit_flow.expression_condition_res
		
var variable_condition_res :TransitionRes.VariableConditionRes = TransitionRes.VariableConditionRes.new() setget _set_variable_condition_res , _get_variable_condition_res
func _set_variable_condition_res(variable_res:TransitionRes.VariableConditionRes):
	if transit_flow:
		transit_flow.variable_condition_res = variable_res
func _get_variable_condition_res():
	if transit_flow:
		return transit_flow.variable_condition_res




func _init(_transit_flow):
	transit_flow = _transit_flow


func _get_property_list():
	var properties :Array
	properties.push_back({name = "Transition",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "from_state",type = TYPE_STRING })
	properties.push_back({name = "to_state",type = TYPE_STRING })
	properties.push_back({name = "condition_type",type = TYPE_INT })
	
	
	return properties
	
func update_comment():
	if transit_flow :
		transit_flow.update_comment()
