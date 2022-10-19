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
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Bug fix , implement script transition (full version)
#----------------------------------------------------------------------------
#
##############################################################################
tool
extends Resource
signal fsm_name_changed(new_name)

const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
const StateRes = preload("subresource/state_res.gd")
const VariableRes = preload("subresource/variable_res.gd")
const TransitionRes = preload("subresource/transition_res.gd")

const NestedFsm = preload("nested_fsm.gd")
const State = preload("state.gd")
const Transition = preload("transition.gd")


#---------Auto---------------
class AutotTransition :
	extends Transition
	const AutoConditionRes = preload("subresource/transition_subresource/auto_condition_res.gd")

	var auto_condition :Array
	func _init(hfsm:Node,auto_condition_res:AutoConditionRes).(hfsm)->void:
		if auto_condition_res.auto_transit_mode == AutoConditionRes.HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER :
			auto_condition = [0,auto_condition_res.delay_time , false , hfsm]
		elif auto_condition_res.auto_transit_mode == AutoConditionRes.HfsmConstant.AUTO_TRANSIT_MODE_NESTED_FSM_EXIT :
			auto_condition = [1]
		elif auto_condition_res.auto_transit_mode == AutoConditionRes.HfsmConstant.AUTO_TRANSIT_MODE_MANUAL :
			auto_condition = [2]
		elif auto_condition_res.auto_transit_mode == AutoConditionRes.HfsmConstant.AUTO_TRANSIT_MODE_UPDATE_TIMES :
			auto_condition = [3,auto_condition_res.times , 0]
		elif auto_condition_res.auto_transit_mode == AutoConditionRes.HfsmConstant.AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES :
			auto_condition = [4,auto_condition_res.times , 0]

	func refresh()->void:
		if auto_condition[0] == 0 :
			auto_condition[2] = false
			yield(auto_condition[3].get_tree().create_timer(auto_condition[1]) , "timeout")
			auto_condition[2] = true
		elif auto_condition[0] in [3,4] :
			auto_condition[2] = 0

	func check()->bool :
		if auto_condition[0] == 0 :
			return auto_condition[2]
		elif auto_condition[0] == 1:
			return true if from_state._nested_fsm and not from_state._nested_fsm.is_running else false
		elif auto_condition[0] == 2:
			return true if from_state.is_exited else false
		elif auto_condition[0] == 3:
			if not Engine.is_in_physics_frame():
				auto_condition[2] += 1
			return false if auto_condition[2] <=auto_condition[1] else true
		else:#ds auto_condition[0] == 4:
			if Engine.is_in_physics_frame():
				auto_condition[2] += 1
			return false if auto_condition[2] <=auto_condition[1] else true
#----------expression-------------------
class ExpressionTransition:
	extends Transition
	const ExpressionConditionRes = preload("subresource/transition_subresource/expression_condition_res.gd")
	var expression :Expression = Expression.new()
	var expression_text :String
	var name_to_obj :Dictionary = {
		"Input":Input,
		"InputMap":InputMap,
		"JSON":JSON,
		"Performance":Performance,
		"IP":IP,
		"Geometry":Geometry,
		"ResourceLoader":ResourceLoader ,
		"ResourceSaver" :ResourceSaver,
		"OS":OS,
		"Engine":Engine ,
		"ClassDB":ClassDB,
		"Marshalls":Marshalls,
		"TranslationServer":TranslationServer ,
		"JavaClassWrapper":JavaClassWrapper,
		"JavaScript":JavaScript,
		"NavigationMeshGenerator":NavigationMeshGenerator,
		"VisualScriptEditor":VisualScriptEditor,
		"VisualServer":VisualServer ,
		"AudioServer":AudioServer,
		"PhysicsServer":PhysicsServer,
		"Physics2DServer":Physics2DServer,
		"ARVRServer":ARVRServer,
		"CameraServer":CameraServer,
	}

	func _set_from_state(new_state):
		from_state = new_state
		name_to_obj["from_state"] = from_state
	func _set_to_state(new_state):
		to_state = new_state
		name_to_obj["to_state"] = to_state

	func _init(hfsm:Node,expression_condition_res:ExpressionConditionRes).(hfsm)->void:
		expression_text = expression_condition_res.expression_text
		name_to_obj["hfsm"] = hfsm
		name_to_obj["from_state"] = from_state
		name_to_obj["to_state"] = to_state
		for name in hfsm.agents.keys():
			name_to_obj[name] = hfsm.agents[name]
	func check()->bool:
		if expression.parse(expression_text,name_to_obj.keys()) != OK:
			printerr(expression.get_error_text())
			push_warning("HFSM: The ExpressionTransition '%s'->'%s' of '%s/%s' has syntax error,please check it."% [from_state.state_name , to_state.state_name , _hfsm.owner.name if _hfsm.owner else "" ,_hfsm.name ])
			return false
		else :
			var result = expression.execute(name_to_obj.values(),_hfsm,false)
			if not expression.has_execute_failed():
				if result is bool:
					return result
				else :
					if result :
						return true
					else :
						return false
			else :
				push_warning("HFSM: The ExpressionTransition '%s'->'%s' of '%s/%s' has execute failed,please check it."% [from_state.state_name , to_state.state_name , _hfsm.owner.name if _hfsm.owner else "" ,_hfsm.name ])
				return false
#-------------Variable-----------------
class VariableTransition:
	extends Transition
#	var hfsm
	var is_and_mode:bool = true
	var force_trigger_list:Array
	var variable_expression_list:Array
	const VariableConditionRes = preload("subresource/transition_subresource/variable_condition_res.gd")
	func _init(hfsm:Node , variable_condition_res:VariableConditionRes).(hfsm)->void:
#		_hfsm = hfsm
		if variable_condition_res.variable_op_mode >0:
			is_and_mode = false
		for e in variable_condition_res.variable_expression_res_list:
			if e is VariableConditionRes.VariableExpressionRes:
				if e.variable_res.variable_type == VariableConditionRes.HfsmConstant.VARIABLE_TYPE_TRIGGER :
					if e.trigger_mode == VariableConditionRes.HfsmConstant.TRIGGER_MODE_FORCE:
						force_trigger_list.append(e.variable_res.variable_name)
					else:
						variable_expression_list.append([e.variable_res.variable_name,VariableConditionRes.HfsmConstant.COMPARATION_EQUEAL ,true])
				else :
					variable_expression_list.append([e.variable_res.variable_name,e.comparation ,e.value])

	func check()->bool:
		var variables :Dictionary = _hfsm.variables
		for force_trigger in force_trigger_list:
			if variables[force_trigger][1]:
				return true
		var has_true :bool  = false
		for variable_expression in variable_expression_list :
			var current_result :bool =false
			if variable_expression[1] == 0:
				current_result = true if variables[variable_expression[0]][1] == variable_expression[2] else false
			elif variable_expression[1] == 1:
				current_result = true if variables[variable_expression[0]][1] != variable_expression[2] else false
			elif variable_expression[1] == 2:
				current_result = true if variables[variable_expression[0]][1] > variable_expression[2] else false
			elif variable_expression[1] == 3:
				current_result = true if variables[variable_expression[0]][1] >= variable_expression[2] else false
			elif variable_expression[1] == 4:
				current_result = true if variables[variable_expression[0]][1] < variable_expression[2] else false
			elif variable_expression[1] == 5:
				current_result = true if variables[variable_expression[0]][1] <= variable_expression[2] else false

			if is_and_mode and not current_result :
				return false
			elif not is_and_mode and current_result :
				return true

			if current_result:
				has_true = true
		return true if has_true else false




var fsm_name :String = "root" setget _set_fsm_name
func _set_fsm_name(n:String):
	fsm_name = n
	emit_signal("fsm_name_changed" ,n)

var state_res_list :Array

var transition_res_list :Array

var variable_res_list:Array

var is_nested:bool = false

var variable_list_offset :Vector2 = Vector2(0,50)
var editor_scroll_offset :Vector2 = Vector2.ZERO
var transition_comment_visible :bool = true

var transition_editor_folded :bool = false

var entered_nested_fsm_res

func _get_property_list():
	var properties :Array
	properties.push_back({name = "HfsmResource",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	properties.push_back({name = "fsm_name",type = TYPE_STRING , usage = PROPERTY_USAGE_STORAGE})
	properties.push_back({name = "state_res_list",type = TYPE_ARRAY , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "transition_res_list",type = TYPE_ARRAY , usage = PROPERTY_USAGE_DEFAULT})
	properties.push_back({name = "is_nested",type = TYPE_BOOL , usage = PROPERTY_USAGE_STORAGE})
	if not is_nested :
		properties.push_back({name = "variable_res_list",type = TYPE_ARRAY , usage = PROPERTY_USAGE_DEFAULT })

	properties.push_back({name = "variable_list_offset",type = TYPE_VECTOR2 , usage = PROPERTY_USAGE_STORAGE })
	properties.push_back({name = "editor_scroll_offset",type = TYPE_VECTOR2 , usage = PROPERTY_USAGE_STORAGE })
	properties.push_back({name = "transition_comment_visible",type = TYPE_BOOL , usage = PROPERTY_USAGE_STORAGE })
	properties.push_back({name = "entered_nested_hfsm_editor",type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string = "Resource", usage = PROPERTY_USAGE_STORAGE })
	properties.push_back({name = "transition_editor_folded",type = TYPE_BOOL, usage = PROPERTY_USAGE_STORAGE })

	return properties


func _init(_fsm_name :String="root" , _is_nested:bool = false):
	fsm_name =_fsm_name
	is_nested = _is_nested

func set_unique_entry_state(state_res :StateRes) :
	if state_res in state_res_list :
		for s in state_res_list:
			if s.state_type == HfsmConstant.STATE_TYPE_ENTRY and s != state_res :
				s.state_type = HfsmConstant.STATE_TYPE_NORMAL
		state_res.state_type = HfsmConstant.STATE_TYPE_ENTRY


func get_exist_entry_res()->StateRes :
	for s in state_res_list :
		if s.state_type == HfsmConstant.STATE_TYPE_ENTRY :
			return s
	state_res_list[0].state_type = HfsmConstant.STATE_TYPE_ENTRY
	return state_res_list[0]

func add_state(new_state_res:StateRes) :
	if new_state_res and not new_state_res in state_res_list :
		state_res_list.append(new_state_res)
	make_state_name_unique(new_state_res)
	var has_entry :bool = false
	for s in state_res_list:
		if (s as StateRes).state_type == HfsmConstant.STATE_TYPE_ENTRY:
			has_entry = true
			return
	if not has_entry :
		new_state_res.state_type = HfsmConstant.STATE_TYPE_ENTRY

func deleted_state(deleted_state_res:StateRes):
	if deleted_state_res and deleted_state_res in state_res_list:
		state_res_list.erase(deleted_state_res)

func make_state_name_unique(state_res:StateRes):
	var exist_list :Array
	for s in state_res_list:
		if s != state_res :
			exist_list.append(s.state_name)
	while state_res.state_name in exist_list :
		state_res.state_name += "_"


func add_transition(new_transition_res:TransitionRes):
	if new_transition_res and not new_transition_res in transition_res_list:
		transition_res_list.append(new_transition_res)

func delete_transition(deleted_transition_res:TransitionRes):
	if deleted_transition_res and deleted_transition_res in transition_res_list:
		transition_res_list.erase(deleted_transition_res)



#添加变量
func add_variable(new_variable_res :VariableRes , pos :int = -1):
	if new_variable_res :
		#获取root
		if not new_variable_res in variable_res_list :
			if pos ==-1:
				variable_res_list.append(new_variable_res)
			else :
				variable_res_list.insert(pos , new_variable_res)
			new_variable_res.is_deleted = false
#移动变量顺序
func move_variable(variable_res:VariableRes , is_forward:bool):
	if variable_res in variable_res_list :
		var index := variable_res_list.find(variable_res)
		var target_index := index-1 if is_forward else index+1
		variable_res_list[index] = variable_res_list[target_index]
		variable_res_list[target_index] = variable_res
#删除变量
func _on_variable_res_deleted(deleted_variable_res:VariableRes):
	if deleted_variable_res :
#		deleted_variable_res.emit_signal("deleted")
		variable_res_list.erase(deleted_variable_res)

func duplicate_self():
	if is_nested :
		var d = self.duplicate()
		d.state_res_list = state_res_list.duplicate()
		d.transition_res_list = transition_res_list.duplicate()
		d.state_res_list.clear()
		d.transition_res_list.clear()
		for s in state_res_list:
			d.state_res_list.append(s.duplicate_self())
		for t in transition_res_list:
			d.transition_res_list.append(t.duplicate_self())
		return d
	return null

func get_state_script_to_state()->Dictionary :
	var script_to_state:Dictionary
	for s in state_res_list :
		if s is StateRes :
			if s.state_script and not s.state_script in script_to_state.keys() :
				script_to_state[s.state_script] = s
				if s.nested_fsm_res :
					var nested_script_to_state :Dictionary = s.nested_fsm_res.get_state_script_to_state()
					for script in nested_script_to_state.keys():
						if not script in script_to_state.keys():
							script_to_state[script] = nested_script_to_state[script]
	return script_to_state

func is_deleted_state_script():
	var is_deleted : = false
	var script_to_state :Dictionary = get_state_script_to_state()
	for s in script_to_state.keys():
		if "::" in s.resource_path or s.resource_path == "":
			script_to_state[s].state_script = null
			is_deleted = true
	return is_deleted

##########################
func generate_state_list(hfsm:Node , parent_path:Array, nested_state)->Array:
	var state_self_property_name_list:Array
	for p in State.get_script_property_list():
		state_self_property_name_list.append(p.name)
	var state_list :Array
	var nested_fsm_state_name :String
	if nested_state:
		nested_fsm_state_name = "fsm_"+nested_state.state_name.capitalize().to_lower().replace(" ","_")
	for state_res in state_res_list:
		if state_res is StateRes:
			var state # :State 为了兼容 C# 状态脚本
			if state_res.state_script :
				if state_res.state_script is GDScript:
					var source_code:String = state_res.state_script.source_code.replace(" ","")
					if HfsmConstant.Extends in source_code or HfsmConstant.Extends_ in source_code:
						state = state_res.state_script.new()
						for property in state.get_script().get_script_property_list():
							if not property.name in state_self_property_name_list and property.name in hfsm.agents.keys():
								state.set(property.name, hfsm.agents[property.name])
						if nested_state:
							state.set(nested_fsm_state_name, nested_state)
					else :
						state = State.new()
						printerr("HFSM : The state script of %s is error , has not inhearit from the correct directory,please check it.")
				elif state_res.state_script.get_class() == "CSharpScript":
					## 当前无法检查 c# 脚本的代码
					state = state_res.state_script.new()
					for property in state.get_script().get_script_property_list():
						if not property.name in state_self_property_name_list and property.name in hfsm.agents.keys():
							state.set(property.name, hfsm.agents[property.name])
					if nested_state:
						state.set(nested_fsm_state_name, nested_state)

			else :
				state = State.new()
			state.hfsm = hfsm
			if nested_fsm_state_name in state._property_to_default_value.keys():
				state._property_to_default_value.erase(nested_fsm_state_name)
			state.state_name = state_res.state_name
			state._state_type = state_res.state_type
			state._reset_when_entry = state_res.reset_properties_when_entry
			if hfsm._force_all_state_entry_behavior == 1:
				state._reset_when_entry = true
			elif hfsm._force_all_state_entry_behavior == 2:
				state._reset_when_entry = false
			if state_res.is_nested and state_res.nested_fsm_res:
				state._nested_fsm = NestedFsm.new(hfsm,state_res.nested_fsm_res,parent_path,state)

				var n = state._nested_fsm
				n._reset_when_entry = state_res.reset_properties_when_entry
				if hfsm._force_all_fsm_entry_behavior == 1:
					state._nested_fsm._reset_when_entry = true
				elif hfsm._force_all_fsm_entry_behavior == 2:
					state._nested_fsm._reset_when_entry = false
			state_list.append(state)

	for transition_res in transition_res_list :
		if transition_res is TransitionRes :
			var transition :Transition
			if transition_res.transition_type == HfsmConstant.TRANSITION_TYPE_AUTO:
				transition = AutotTransition.new(hfsm,transition_res.auto_condition_res )
			elif transition_res.transition_type == HfsmConstant.TRANSITION_TYPE_EXPRESSION :
				transition = ExpressionTransition.new(hfsm,transition_res.expression_condition_res)
			elif transition_res.transition_type == HfsmConstant.TRANSITION_TYPE_VARIABLE :
				transition = VariableTransition.new(hfsm,transition_res.variable_condition_res)
				if (transition.force_trigger_list as Array).empty() and (transition.variable_expression_list as Array).empty() :
					transition = null
			if transition:
				for s in state_list:
					if s.state_name == transition_res.from_res.state_name :
						transition.from_state = s
					elif s.state_name == transition_res.to_res.state_name :
						transition.to_state = s
				if not transition.from_state and  not transition.to_state:
					transition = null
				if transition :
					transition.from_state._transition_list.append(transition)
	return state_list

func get_all_nested_state_res()->Array:
	var list :Array
	for state_res in state_res_list:
		if state_res is StateRes:
			if state_res.is_nested and state_res.nested_fsm_res:
				list.append(state_res)
				list += state_res.nested_fsm_res.get_all_nested_state_res()
	return list
