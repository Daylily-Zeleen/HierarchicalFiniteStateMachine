extends Reference


var condition 
var from_state setget _set_from_state
func _set_from_state(new_state):
	from_state = new_state
var to_state setget _set_to_state
func _set_to_state(new_state):
	to_state = new_state
var _hfsm
func _init(hfsm:Node)->void:
	_hfsm = hfsm
	
func check()->bool:
	return false
	
func refresh()->void:
	return


