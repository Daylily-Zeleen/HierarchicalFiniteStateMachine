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
#const State = preload("../state.gd")

signal param_updated

var state_name :String  = "state" setget _set_state_name 
func _set_state_name(new_name :String):
	state_name =  new_name
	if nested_fsm_res:
		nested_fsm_res.fsm_name = new_name
var state_type:int = HfsmConstant.STATE_TYPE_NORMAL setget _set_state_type
func _set_state_type(t :int ):
	state_type = t
	emit_signal("param_updated")
var state_script :Script  = null setget _set_state_script
func _set_state_script(s) :
	state_script = s
	emit_signal("param_updated")
var is_nested :bool = false setget _set_is_nested
func _set_is_nested(i_n :bool):
	is_nested = i_n
	emit_signal("param_updated")
var nested_fsm_res = null 
var editor_offset :Vector2= Vector2.ZERO
var reset_properties_when_entry :bool = true
var reset_nested_fsm_when_entry:bool = false

func _get_property_list():
	var properties :Array

	properties.push_back({name = "state_name",type = TYPE_STRING , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "state_type",type = TYPE_INT , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "state_script",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE , hint_string = "Script" , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "is_nested",type = TYPE_BOOL , usage = PROPERTY_USAGE_DEFAULT })
	properties.push_back({name = "nested_fsm_res",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string = "Resource" , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "editor_offset",type = TYPE_VECTOR2 , usage = PROPERTY_USAGE_DEFAULT })
	properties.push_back({name = "reset_properties_when_entry",type = TYPE_BOOL , usage = PROPERTY_USAGE_DEFAULT })
	properties.push_back({name = "reset_nested_fsm_when_entry",type = TYPE_BOOL , usage = PROPERTY_USAGE_DEFAULT })
	
	return properties
	
func _init(_offset :Vector2 = Vector2.ZERO , _name :String  = "state" , _type:int = HfsmConstant.STATE_TYPE_NORMAL ,_script  = null,_is_nested :bool = false,_nested_hfsm_res = null):
	editor_offset = _offset
	state_name = _name
	state_type = _type
	state_script = _script
	is_nested = _is_nested
	nested_fsm_res = _nested_hfsm_res

func duplicate_self():
	var d = self.duplicate()
	if nested_fsm_res:
		d.nested_fsm_res = nested_fsm_res.duplicate_self()
	return d

func update_nested_state_script():
	var text :String = HfsmConstant.NestedFsmStateStartMark
	if state_script and is_nested and nested_fsm_res:
		text += "const NestedFsmState = preload(\"%s\")\n" % state_script.resource_path
		text += "var fsm_%s : NestedFsmState\n" % state_name.capitalize().to_lower().replace(" ","_")
	text += HfsmConstant.NestedFsmStateEndMark
	for state_res in nested_fsm_res.state_res_list:
		if state_res.state_script:
			var code_text:String = state_res.state_script.source_code
			if HfsmConstant.Extends in code_text.replace(" ","") or HfsmConstant.Extends_ in code_text.replace(" ",""):
				if HfsmConstant.NestedFsmStateStartMark in code_text and HfsmConstant.NestedFsmStateEndMark in code_text:
					var start_index :int = code_text.find(HfsmConstant.NestedFsmStateStartMark) 
					var end_index :int = code_text.find(HfsmConstant.NestedFsmStateEndMark) + HfsmConstant.NestedFsmStateEndMark.length()
					var replace_text = code_text.substr(start_index , end_index-start_index)
					code_text = code_text.replace(replace_text , text)
			var tmp_script
			if state_res.state_script is GDScript:
				tmp_script = GDScript.new()
			tmp_script.source_code = code_text
			
			var tmp :Resource = Resource.new()
			tmp.take_over_path(state_res.state_script.resource_path)
			tmp.resource_path = ""
			ResourceSaver.save(state_res.state_script.resource_path, tmp_script)

