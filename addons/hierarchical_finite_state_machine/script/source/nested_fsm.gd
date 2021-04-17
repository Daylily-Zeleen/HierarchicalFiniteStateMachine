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
extends Reference

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
				_current_state._exit()
			_hfsm._transited(_current_state.state_name , transition.to_state.state_name ,_path)
			_current_state = transition.to_state
			_current_state._entry()
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
		
