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
#  Remark         : this is the State class's script,you can see it API in this script。
#					这是HFSM类的脚本，您可以在此脚本中查看State类的API。
#----------------------------------------------------------------------------
#  Change History :
#  <Date>     | <Version> | <Author>       | <Description>
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Improve access safity.
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
#--------------------Overridable-----------------------
#======================================================
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
				self.set(agent, hfsm.agents[agent])
		init()
		for property in get_script().get_script_property_list():
			if not property.name in [ "_property_to_default_value" ,"state_name","_state_type","hfsm","_nested_fsm"] and not property.name in hfsm.agents.keys() :
				_property_to_default_value[property.name] = self[property.name]
	else :
		printerr("HFSM err: %s Can not set state property 'hfsm'.-gds"%state_name)

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
