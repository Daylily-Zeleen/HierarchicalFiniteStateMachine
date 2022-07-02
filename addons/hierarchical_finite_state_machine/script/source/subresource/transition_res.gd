##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  735170336@qq.com.                                                   
#
#	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#	Hirerarchical Finite State Machine(HFSM - Full Version).   
#     
#                 
#	This file is part of HFSM - Full Version.
#                                                                                                                       *
#	HFSM - Full Version is a Godot Plugin that can be used freely except in any 
#form of dissemination, but the premise is to donate to plugin developers.
#Please refer to LISENCES.md for more information.
#                                                                   
#	HFSM - Full Version是一个除了以任何形式传播之外可以自由使用的Godot插件，前提是向插件开
#发者进行捐赠，具体许可信息请见 LISENCES.md.
#
#	This is HFSM‘s full version ,But there are only a few more unnecessary features 
#than the trial version(please read the READEME.md to learn difference.).If this 
#plugin is useful for you,please consider to support me by getting the full version.
#If you do not want to donate,please consider to use the trial version.
#
#	虽然称为HFSM的完整版本，但仅比试用版本多了少许非必要的功能(请阅读README.md了解他们的差异)。
#如果这个插件对您有帮助，请考虑通过获取完整版本来支持插件开发者，如果您不想进行捐赠，请考虑使
#用试用版本。
#
# Trail version link : 
#	https://gitee.com/y3y3y3y33/HierarchicalFiniteStateMachine
#	https://github.com/Daylily-Zeleen/HierarchicalFiniteStateMachine
# Sponsor link : 
#	https://afdian.net/@Daylily-Zeleen
#	https://godotmarketplace.com/?post_type=product&p=37138    
#                                    
#	@author   Daylily-Zeleen                                            
#	@email    daylily-zeleen@qq.com                                              
#	@version  0.8(版本号)                                                     
#	@license  Custom License(Read LISENCES.TXT for more details)
#                                                                      
#----------------------------------------------------------------------------
#  Remark         :                                         
#----------------------------------------------------------------------------
#  Change History :                                                          
#  <Date>     | <Version> | <Author>       | <Description>                   
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file     
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Implement script_condition           
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
	properties.push_back({name = "script_condition_res",type = TYPE_OBJECT ,hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Resource"  })
	
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
