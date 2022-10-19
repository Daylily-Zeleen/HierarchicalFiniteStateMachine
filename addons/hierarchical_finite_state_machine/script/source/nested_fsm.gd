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
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Bug fix
#----------------------------------------------------------------------------
#
##############################################################################
extends Reference

#const State = preload("state.gd")
const Transition = preload("transition.gd")

var _hfsm
var _path:Array = []
var _state_list:Array

var is_running:bool = false

var _current_state

var _current_entry_state
var _current_exit_state_list :Array
var _default_entry_state
var _default_exit_state_list :Array
var _reset_when_entry :bool

func _init(hfsm:Node,nested_fsm_res = null,parent_path:Array =[],nested_state = null):
	_hfsm = hfsm

	if not nested_fsm_res:
		nested_fsm_res = _hfsm._root_fsm_res

	_path = parent_path.duplicate()
	_path.append(nested_fsm_res.fsm_name)


	_state_list = nested_fsm_res.generate_state_list(hfsm,_path,nested_state)
	if not _state_list.empty():
		for state in _state_list:
			if state._state_type == 1:
				_default_entry_state = state
				_current_entry_state = _default_entry_state
			elif state._state_type == 2:
				_default_exit_state_list.append(state)

		_current_exit_state_list = _default_exit_state_list.duplicate()



func _restart()->void:
	_current_entry_state = _default_entry_state
	_current_exit_state_list = _default_exit_state_list.duplicate()
	_current_state = _current_entry_state
	for state in _state_list :
		state._reset()
		if state._nested_fsm :
			state._nested_fsm._restart()

func _entry(entry_state = null)->void:
	if _reset_when_entry:
		_current_entry_state  = _default_entry_state
		_current_exit_state_list = _default_exit_state_list.duplicate()
		for state in _state_list :
			state._reset()
	if entry_state:
		_current_state = entry_state
	else :
		_current_state =_current_entry_state
	if _current_state:
		_current_state._entry()
		is_running = true
		_hfsm._transited(null , _current_state.state_name ,_path.duplicate())
		_hfsm._entered(_current_state.state_name,_path.duplicate())

func _check_transit_and_get_update_queue()->Array:
	var update_queue:Array
	for transition in _current_state._transition_list:
		if transition.check():
			if not _current_state.is_exited :
				assert(_current_state.has_method("_exit"))
				_current_state._exit(false)
			_hfsm._transited(_current_state.state_name , transition.to_state.state_name ,_path)
			_current_state = transition.to_state
			_current_state._entry()
			_hfsm._entered(_current_state.state_name,_path.duplicate())
			if _current_state in _current_exit_state_list:
				_exit()
			break
	if not _current_state.is_exited:
		update_queue.append(self)
		if _current_state._nested_fsm and _current_state._nested_fsm.is_running:
			for fsm in _current_state._nested_fsm._check_transit_and_get_update_queue():
				update_queue.append(fsm)
	return update_queue

func _update(delta:float)->void:
	_current_state._update(delta)
	_hfsm._updated( _current_state.state_name , delta , _path.duplicate())

func _physics_update(delta:float)->void:
	_current_state._physics_update(delta)
	_hfsm._physic_updated( _current_state.state_name , delta , _path.duplicate())

func _force_transit(target_state:String)->bool:
	var target = _get_state(target_state)
	if target :
		if _current_state and not _current_state.is_exited:
			_current_state._exit()
		_hfsm._transited(_current_state.state_name , target_state , _path.duplicate())
		_current_state = target
		_current_state._entry()
		_hfsm._entered(_current_state.state_name,_path.duplicate())
		return true
	return false

func _is_valid_path(path:Array , index :int = 0 ) ->bool:
	if path[index] == _path.back() :
		index += 1
		if path[index] != "":#未达终点
			var next_state = _get_state(path[index])
			if next_state :
				var next_fsm = next_state._nested_fsm
				if next_fsm:
					return next_fsm._is_valid_path(path ,index)
				elif next_state.state_name == path[index + 1]:
					return true
		else :
			return true
	return false

func _exit()-> void:
	_current_state._exit()
#	if _current_state._nested_fsm and _current_state._nested_fsm.is_running:
#		_current_state._nested_fsm._exit()
	is_running = false
	_hfsm._exited(_current_state.state_name , _path.duplicate())
	_hfsm._transited(_current_state.state_name , null , _path.duplicate())


func _exit_by_state()->void:
	is_running = false
	_hfsm._exited(_current_state.state_name , _path.duplicate())
	_hfsm._transited(_current_state.state_name , null , _path.duplicate())

func _get_state(state_name:String) :
	for state in _state_list:
		if state.state_name == state_name:
			return state
	return null

func _set_entry_state(state_name:String)->bool :
	for state in _state_list :
		if state.state_name == state_name :
			_current_entry_state = state
			return true
	return false

func _set_exit_state(state_name:String)->bool :
	if _current_entry_state.state_name == state_name:
		return false
	for state in _state_list :
		if state.state_name == state_name :
			if not state in _current_exit_state_list:
				_current_exit_state_list.append(state)
			return true
	return false

func _set_normal_state(state_name:String) -> bool:
	if _current_entry_state.state_name == state_name:
		return false
	var target_state = _get_state(state_name)
	if not target_state:
		return false
	if target_state in _current_exit_state_list:
		_current_exit_state_list.erase(target_state)
	return true

func _set_unique_exit_state(state_name:String)->bool :
	if _current_entry_state.state_name == state_name :
		return false
	for state in _state_list :
		if state.state_name == state_name :
			_current_exit_state_list.clear()
			_current_exit_state_list.append(state)
			return true
	return false
