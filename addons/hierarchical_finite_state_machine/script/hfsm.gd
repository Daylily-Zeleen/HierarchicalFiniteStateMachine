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
#  Remark         : this is the HFSM class's script,you can see it API in this script。
#					这是HFSM类的脚本，您可以在此脚本中查看HFSM类的API。
#----------------------------------------------------------------------------
#  Change History :
#  <Date>     | <Version> | <Author>       | <Description>
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file
#  2021/04/15 | 0.1   | Daylily-Zeleen       | Change update behavior and trigger flush behavoir
#  2021/04/16 | 0.1   | Daylily-Zeleen       | Change fix the force entry behavoir

#----------------------------------------------------------------------------
#
##############################################################################
tool
extends Node


#======================================================
#--------------------Signals---------------------------
#======================================================

#------------------------------------------------------------------------------
#@description : emitted when hfsm generate over.
#------------------------------------------------------------------------------
signal inited()

#------------------------------------------------------------------------------
#@description : emitted when entered a State
#@param1 : (String) state
#		the entered State's name.
#@param2 : (Array) fsm_path
#		the path of FSM,which occured this entry behavior.
#------------------------------------------------------------------------------
signal entered(state,fsm_path)

#------------------------------------------------------------------------------
#@description : emitted when exited a State
#@param1 : (String) state
#		the exited State's name.
#@param2 : (Array) fsm_path
#		the path of FSM,which occured this exit behavior.
#------------------------------------------------------------------------------
signal exited(state,fsm_path)

#------------------------------------------------------------------------------
#@description : emitted when updated a State
#@param1 : (String) state
#		the updated State's name.
#@param2 : (float) delta
#		the updated frame time ,in second.
#@param3 : (Array) fsm_path
#		the path of FSM,which occured this update behavior.
#------------------------------------------------------------------------------
signal updated(state, delta ,fsm_path)

#------------------------------------------------------------------------------
#@description : emitted when physics updated a State
#@param1 : (String) state
#		the physics updated State's name.
#@param2 : (float) delta
#		the physics updated frame time ,in second.
#@param3 : (Array) fsm_path
#		the path of FSM,which occured this physics update behavior.
#------------------------------------------------------------------------------
signal physics_updated(state, delta ,fsm_path)

#------------------------------------------------------------------------------
#@description : emitted when physics transited a State
#@param1 : (String) from
#		the start State's name.
#@param2 : (String) to
#		the target State's name.
#@param3 : (Array) fsm_path
#		the path of FSM,which occured this transition behavior.
#------------------------------------------------------------------------------
signal transited(from , to , fsm_path)
#-----expose property---------
#======================================================
#-------------------Properties-------------------------
#======================================================

#------------------------------------------------------------------------------
#@description : Read only.If true,the hfsm is generated.
#------------------------------------------------------------------------------
var is_inited:bool =false setget _set_inited , is_inited

#------------------------------------------------------------------------------
#@description : The HFSM is avtive if true.
#------------------------------------------------------------------------------
var active : bool = true setget set_active, get_active

#------------------------------------------------------------------------------
#@description : Read only. key is agnet node name,
#				If 'is_inited' is false,value is it's NodePath(relative).
#				If 'is_inited' is true,value is it's instance.
#------------------------------------------------------------------------------
var agents :Dictionary = {"null" : NodePath("")} setget _set_agents , get_agents

#------------------------------------------------------------------------------
#@description : If true,it will show a simple debugger at bottom left when running
#				window.
#------------------------------------------------------------------------------

#======================================================
#--------------------Methods---------------------------
#======================================================

#------------------------------------------------------------------------------
#@description : update manually,
#@note : only work when 'Process Type' is "Manual" and 'avtive' is true,
#		otherwise it will print a error.
#------------------------------------------------------------------------------
func manual_update()->void:
	if active and process_type == 3:
		_process(get_process_delta_time())
		return
	if not active :
		printerr("HFSM : manual_update() faild ,trying to manual update a inactive HFSM.")
	else:
		printerr("HFSM : manual_update() faild ,trying to manual update a not manual process HFSM.")

#------------------------------------------------------------------------------
#@description : physics update manually
#@note : only work when 'Process Type' is "Manual" and 'avtive' is true,
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func manual_physics_update()->void:
	if active and process_type == 3:
		_physics_process(get_physics_process_delta_time())
		return
	if not active :
		printerr("HFSM : manual_physics_update() faild ,trying to manual physics update update a inactive HFSM.")
	else:
		printerr("HFSM : manual_physics_update() faild ,trying to manual physics update update a not manual process HFSM.")

#------------------------------------------------------------------------------
#@description : restart the HFSM.
#------------------------------------------------------------------------------
func restart()->void:
	_root_fsm._restart()
	self.active = true
	_root_fsm._entry()

#------------------------------------------------------------------------------
#@description : to get HFSM current running state's path.
#@return : (Array) HFSM current running state's path.
#		@example : [ "root" , "state" , "current_state"]
#------------------------------------------------------------------------------
func get_current_path()->Array:
	return _current_path

#------------------------------------------------------------------------------
#@description : to get HFSM previous run state's path.
#@return : (Array) HFSM previous run state's path.
#		@example : [ "root" , "state" , "previous_state"]
#------------------------------------------------------------------------------
func get_previous_path()->Array:
	return _previous_path

#------------------------------------------------------------------------------
#@description : to get a value of specific variable
#@param1 : (String) variable_name
#		the target variable's name,should has been created in editor.
#@return : (Variant) value of variable
#@note : only work if the variable is in HFSM .otherwise it will print a error tip.
#------------------------------------------------------------------------------
func get_variable(variable_name :String ):
	if variables[variable_name]:
		return variables[variable_name][1]
	else :
		printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "" , name ,variable_name])

#------------------------------------------------------------------------------
#@description : to get all variable
#@return : (Dictionary) value of variable
#		@example :{
#		​	“variable_trigger” : false,
#		​	"variable_boolean" : true ,
#		​	"variable_integer" : 2 ,
#		​	"variable_float" : 3.14 ,
#		​	"variable_string" : "test_string" ,
#			}
#------------------------------------------------------------------------------
func get_variable_list()->Dictionary:
	var name_to_value :Dictionary
	for v_name in variables.keys():
		name_to_value[v_name] = variables[v_name][1]
	return name_to_value

#------------------------------------------------------------------------------
#@description : to set a specific variable's value
#@param1 : (String) variable_name
#		the target vairable's name,should has been created in editor.
#@param2 : (Variant) value
#		the new value of target variable,should match the type of target variable
#		only be ignore if the type of target variable is trigger.
#@note : only work when variable in HFSM and the type of target value is match to the varibale's type,
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_variable(variable_name :String ,value )->void:
	if variables[variable_name]:
		var value_type :int = typeof(value)
		if value_type == TYPE_BOOL:
			if variables[variable_name][0] == 0 :
				set_trigger(variable_name)
			else:
				set_boolean(variable_name , value)
		elif value_type == TYPE_INT:
			if variables[variable_name][0] == 2 :
				set_integer(variable_name,value)
			else :
				set_float(variable_name,float(value))
		elif value_type == TYPE_REAL :
			set_float(variable_name , value )
		elif value == TYPE_STRING :
			set_string(variable_name , value )
		else :
			printerr("HFSM: the value to set is not an expected type.")
	else:
		printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "", name ,variable_name])

#------------------------------------------------------------------------------
#@description : to trigger a trigger variable
#@param1 : (String) trigger_name
#		the target trigger variable's name,should has been created in editor.
#@note : only work when the target triggrer variable in HFSM.
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_trigger(trigger_name :String)->void:
	if variables[trigger_name] and variables[trigger_name][0] == 0:
		variables[trigger_name][1] = true
	else:
		printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "" , name ,trigger_name])

#------------------------------------------------------------------------------
#@description : to set the value of boolean variable
#@param1 : (String) boolean_name
#		the target boolean variable's name,should has been created in editor.
#@param2 : (bool) value - target value
#		the new value of target variable.
#@note : only work when the target boolean variable in HFSM.
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_boolean(boolean_name:String , value:bool)->void:
	if variables[boolean_name] and variables[boolean_name][0] == 1:
		variables[boolean_name][1] = value
	else :
		if not variables[boolean_name] :
			printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "", name ,boolean_name])
		else :
			printerr("HFSM: the type of %s/%s's variable '/s' is not Boolean. " % [owner.name if owner else "", name ,boolean_name])

#------------------------------------------------------------------------------
#@description : to set the value of integer variable
#@param1 : (String) integer_name
#		the target integer variable's name,should has been created in editor.
#@param2 : (int) value
#		the new value of target variable.
#@note : only work when the target integer variable in HFSM.
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_integer(integer_name:String , value:int)->void:
	if variables[integer_name] and variables[integer_name][0] == 2:
		variables[integer_name][1] = value
	else :
		if not variables[integer_name]:
			printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "", name ,integer_name])
		else:
			printerr("HFSM: the type of %s/%s's variable '/s' is not Integer. " % [owner.name if owner else "", name ,integer_name])

#------------------------------------------------------------------------------
#@description : to set the value of float variable
#@param1 : (String) float_name
#		the target float variable's name,should has been created in editor.
#@param2  : (float) value - target value
#		the new value of target variable.
#@note : only work when the target float variable in HFSM.
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_float(float_name:String , value:float)->void:
	if variables[float_name] and variables[float_name][0] == 3:
		variables[float_name][1] = value
	else :
		if not  variables[float_name] :
			printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "", name ,float_name])
		else :
			printerr("HFSM: the type of %s/%s's variable '/s' is not Float. " % [owner.name if owner else "", name ,float_name])

#------------------------------------------------------------------------------
#@description : to set the value of String variable
#@param1 : (String) String_name
#		the target String variable's name,should has been created in editor.
#@param2  : (String) value
#		the new value of target variable.
#@note : only work when the target String variable in HFSM.
#		otherwise it will print a error tip.
#------------------------------------------------------------------------------
func set_string(string_name:String , value:String)->void:
	if variables[string_name] and variables[string_name][0] == 4:
		variables[string_name][1] = value
	else :
		if not variables[string_name]:
			printerr("HFSM: %s/%s has not contain variable which be named '%s'" % [owner.name if owner else "", name ,string_name])
		else :
			printerr("HFSM: the type of %s/%s's variable '/s' is not Sring. " % [owner.name if owner else "", name ,string_name])
















#======================================================
#--------------------Internal--------------------------
#======================================================
func _get_configuration_warning():
	if not _root_fsm_res :
		return ""
	elif _root_fsm_res.state_res_list.size() == 0 :
		return "The HFSM need at least one state."
	else :
		return ""

const NestedFsm = preload("source/nested_fsm.gd")

enum ProcessTypes {
	IDLE_AND_PHYSICS ,
	IDLE ,
	PHYSICS ,
	MANUAL ,
}

func _set_inited(v:bool):
	if not is_inited:
		is_inited = v
func is_inited()->bool:
	return is_inited
func set_active(v:bool)->void :
	active = v
	if active :
		self.process_type = process_type
	else :
		set_process(false)
		set_physics_process(false)
func get_active()->bool :
	return active





func _set_agents(a:Dictionary)->void:
	if Engine.editor_hint or not is_inside_tree() or agents.values()[0] is NodePath:
		agents = a
func get_agents()->Dictionary:
	return agents

#var _custom_class_list:Dictionary = {"Null":""}


var process_type :int = ProcessTypes.IDLE_AND_PHYSICS setget set_process_type , get_process_type
func set_process_type(type :int)->void:
	process_type = type
	if not Engine.editor_hint:
		if type == ProcessTypes.IDLE :
			set_physics_process(false)
			set_process(true)
		elif type == ProcessTypes.PHYSICS :
			set_process(false)
			set_physics_process(true)
		elif type == ProcessTypes.IDLE_AND_PHYSICS :
			set_process(true)
			set_physics_process(true)
		else :
			set_process(false)
			set_physics_process(false)
func get_process_type()->int:
	return process_type


var _disable_rename_to_snake_case :bool = false

var _force_all_state_entry_behavior :int = 0
var _force_all_fsm_entry_behavior :int = 0

var _inspector_res
var _root_fsm_res
func _init():
	set_process(false)
	set_physics_process(false)
	if Engine.editor_hint:
		_inspector_res = preload("../editor/hfsm/hfsm_inspector_res.gd").new(self)
	else :
		connect("tree_entered" , self , "_on_Self_tree_entered")


func _get_property_list()->Array:
	var properties :Array
	properties.push_back({name = "HFSM",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "active",type = TYPE_BOOL })
	properties.push_back({name = "process_type",type = TYPE_INT  })
	properties.push_back({name = "agents",type = TYPE_DICTIONARY })
	properties.push_back({name = "_custom_class_list",type = TYPE_DICTIONARY })
	properties.push_back({name = "debug",type = TYPE_BOOL })

	properties.push_back({name = "Advance Setting" , type = TYPE_NIL , usage = PROPERTY_USAGE_GROUP})
	properties.push_back({name = "_disable_rename_to_snake_case",type = TYPE_BOOL })
	properties.push_back({name = "_force_all_state_entry_behavior" , type = TYPE_INT})
	properties.push_back({name = "_force_all_fsm_entry_behavior" , type = TYPE_INT})
	properties.push_back({name = "_root_fsm_res",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string ="Resource" ,usage = PROPERTY_USAGE_STORAGE})

	return properties

func _ready()->void:
	if not _root_fsm_res:
		_root_fsm_res = load("res://addons/hierarchical_finite_state_machine/script/source/nested_fsm_res.gd").new()
	else:
		_root_fsm_res.is_deleted_state_script()


var _current_path :Array = ["root"] setget , get_current_path
var _previous_path :Array = ["root"] setget , get_previous_path
var _root_fsm : NestedFsm
var _trigger_list:Array
var variables :Dictionary
func _generate_hfsm()->void:
	_trigger_list.clear()
	_root_fsm = NestedFsm.new(self)
	for variable_res in _root_fsm_res.variable_res_list:
		if variable_res.variable_type == _root_fsm_res.HfsmConstant.VARIABLE_TYPE_TRIGGER:
			_trigger_list.append(variable_res.variable_name)
			variables[variable_res.variable_name] = [ variable_res.variable_type , false]
		else:
			if variable_res.variable_type in [_root_fsm_res.HfsmConstant.VARIABLE_TYPE_FLOAT , _root_fsm_res.HfsmConstant.VARIABLE_TYPE_INTEGER]:
				variables[variable_res.variable_name] = [ variable_res.variable_type , 0]
			else :
				variables[variable_res.variable_name] = [ variable_res.variable_type , null]

	if Engine.editor_hint :
		_root_fsm_res = null

func _flush_trigger()->void:
	for trigger in _trigger_list:
		variables[trigger][1] = false

var _active_fsm_list:Array
func _process(delta:float)->void:
	if active and is_inited():
		if process_type in [1,3] :
			_active_fsm_list = _root_fsm._check_transit_and_get_update_queue()
			_flush_trigger()
		for fsm in _active_fsm_list:
			fsm._update(delta)
			if process_type == 1 :
				fsm._physics_update(delta)
func _physics_process(delta:float)->void:
	if active and is_inited():
		_active_fsm_list = _root_fsm._check_transit_and_get_update_queue()
		_flush_trigger()
		for fsm in _active_fsm_list:
			fsm._physics_update(delta)
			if process_type == 2:
				fsm._update(delta)

#------------signal emitter-------------
func _updated(state:String, delta:float ,fsm_path:Array )->void:
	if process_type in [0,1]:
		emit_signal("updated" ,state , delta ,fsm_path)
func _physic_updated( state :String,delta:float, fsm_path:Array )->void:
	if process_type in [0,3]:
		emit_signal( "physics_updated" , state, delta ,fsm_path )
func _transited(from , to ,fsm_path:Array )->void:
	_previous_path = _current_path.duplicate()
	_current_path = fsm_path.duplicate()
	if from :
		_current_path.append(from)
	else: from = ""
	if to :
		_current_path.append(to)
	else: to = ""
	emit_signal("transited" , from , to ,fsm_path )
func _entered(state:String , fsm_path:Array)->void:
	emit_signal("entered", state , fsm_path)
func _exited(state:String , fsm_path:Array)->void:
	emit_signal("exited", state ,fsm_path)


func _on_Self_tree_entered():
	if is_inited: return # 整个生命周期不会重复初始化
	if owner :
		yield(owner,"ready")
	else:
		yield(self,"ready")
	for agent in agents.keys():
		var obj = owner.get_node_or_null(agents[agent]) if owner else get_node_or_null(agents[agent])
		if not obj:
			obj = get_node_or_null(agents[agent])
		if obj :
			agents[agent] = obj
		else :
			agents.erase(agent)
	_generate_hfsm()
	yield(get_tree(),"idle_frame")
	if active:
		restart()
	is_inited = true
	emit_signal("inited")
