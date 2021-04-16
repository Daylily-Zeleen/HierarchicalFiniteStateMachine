extends "res://addons/hierarchical_finite_state_machine/script/source/state.gd"

#You can use 'hfsm' to call the HFSM which contain this state , and call it's menbers.
#Please browse document to find API.

###agents list-start# please not modify this line.
###agents list-end# please not modify this line.
###nested fsm state-start# please not modify this line.
const NestedFsmState = preload("res://addons/hierarchical_finite_state_machine/demo/hfsm_test/hfsm_state_nested_fsm.gd")
var fsm_nested_fsm : NestedFsmState
###nested fsm state-end# please not modify this line.

#---------Custom signals------------

#--------Custom Properties---------

#-------Custom Mechods-----------

#-------override-----------
#This funcion will be called just once when the hfsm is generated.
func init()->void:
	pass

#Will be called every time when entry this state.
func entry()->void:
	#to demostrate how to call custom method which in fsm,whcih contain this state.
	#you can call custom property in fsm,too.
	fsm_nested_fsm.test_func(get_state_name())

#Will be called every frame if the hfsm's process_type is setted at "Idle" or "Idle And Physics",
#and will be called every physics frame if the hfsm's process_type is setted at "Physics".
#(In order to ensure the function completeness)
#Note that this method will not be called if this state is an exit state
func update(delta:float)->void:
	pass

#Will be called every physics frame if the hfsm's process_type is setted at "Physics" or "Idle And Physics",
#and will be called every frame if the hfsm's process_type is setted at "Idle".
#(In order to ensure the function completeness)
#Note that this method will not be called if this state is an exit state
func physics_update(delta:float)->void:
	pass

#Will be called every time when exit this state.
#Note that this method will be called immediatly after entry() if this state is an exit state.
func exit()->void:
	pass



