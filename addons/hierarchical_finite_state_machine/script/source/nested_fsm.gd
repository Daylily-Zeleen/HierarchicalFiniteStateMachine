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
		
