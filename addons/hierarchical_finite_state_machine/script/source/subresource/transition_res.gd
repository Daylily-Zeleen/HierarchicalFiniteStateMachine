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
tool
extends Resource

const HfsmConstant = preload("../../../script/source/hfsm_constant.gd")
const StateRes = preload("state_res.gd")
const AutoConditionRes  = preload("transition_subresource/auto_condition_res.gd")
const ExpressionConditionRes = preload("transition_subresource/expression_condition_res.gd")
const VariableConditionRes = preload("transition_subresource/variable_condition_res.gd")

var from_res :StateRes = StateRes.new()
var to_res :StateRes = StateRes.new()
var transition_type :int = HfsmConstant.TRANSITION_TYPE_AUTO

var auto_condition_res :AutoConditionRes =null
var expression_condition_res :ExpressionConditionRes = null 
var variable_condition_res :VariableConditionRes = null 

func _get_property_list():
	var properties :Array
#		properties.push_back({name = "TransitionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "from_res" , type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource" })
	properties.push_back({name = "to_res",type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "transition_type",type = TYPE_INT  })
	properties.push_back({name = "auto_condition_res",type = TYPE_OBJECT,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "expression_condition_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	properties.push_back({name = "variable_condition_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	
	return properties
func _init(
		_from_res :StateRes = null ,
		_to_res:StateRes  = null, 
		_transition_type :int = HfsmConstant.TRANSITION_TYPE_AUTO ,
		_auto_condition_res :AutoConditionRes = AutoConditionRes.new() , 
		_expression_condition_res :ExpressionConditionRes = ExpressionConditionRes.new() ,
		_variable_condition_res :VariableConditionRes = VariableConditionRes.new() 
		):
	from_res = _from_res
	to_res = _to_res
	transition_type = _transition_type
	auto_condition_res = _auto_condition_res
	expression_condition_res = _expression_condition_res
	variable_condition_res = _variable_condition_res


func duplicate_self():
	var d := self.duplicate()
	d.auto_condition_res = auto_condition_res.duplicate()
	d.expression_condition_res = expression_condition_res.duplicate()
	d.variable_condition_res = variable_condition_res.duplicate()
	d.variable_condition_res.variable_expression_res_list = variable_condition_res.variable_expression_res_list.duplicate()
	d.variable_condition_res.variable_expression_res_list.clear()
	for v in variable_condition_res.variable_expression_res_list :
		d.variable_condition_res.variable_expression_res_list.append(v.duplicate())
	return d
