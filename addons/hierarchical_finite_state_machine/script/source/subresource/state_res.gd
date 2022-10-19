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
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Implement C# state script support
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
	properties.push_back({name = "nested_fsm_res",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string = "Resource" ,usage = PROPERTY_USAGE_STORAGE})
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
#		print("------------------------",state_script)
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

