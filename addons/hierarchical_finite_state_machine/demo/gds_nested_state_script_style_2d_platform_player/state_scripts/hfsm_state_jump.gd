extends "res://addons/hierarchical_finite_state_machine/script/source/state.gd"

#You can use 'hfsm' to call the HFSM which contain this state , and call it's menbers.
#Please browse document to find API.

###agents list-start# please not modify this line.
const Player = preload("res://addons/hierarchical_finite_state_machine/demo/gds_nested_state_script_style_2d_platform_player/Player.gd")
var player : Player
###agents list-end# please not modify this line.
###nested fsm state-start# please not modify this line.
###nested fsm state-end# please not modify this line.
#======================================================
#--------------------Custom Signals--------------------
#======================================================

#======================================================
#-------------------Custom Properties------------------
#======================================================

#======================================================
#--------------------Custom Mechods--------------------
#======================================================

#======================================================
#--------------------Override Mechods------------------
#======================================================
#This funcion will be called just once when the hfsm is generated.
func init()->void:
	pass

#Will be called every time when entry this state.
func entry()->void:
	# Show current state.
	player.state_label.text = state_name
	# Apply jump vertical velocity
	if Input.is_action_just_pressed("ui_select"):
		player.velocity.y += player.jump_speed
		hfsm.set_float("velocity_length" ,player.velocity.length())

#Will be called every frame if the hfsm's process_type is setted at "Idle" or "Idle And Physics",
#and will be called every physics frame if the hfsm's process_type is setted at "Physics".
#(In order to ensure the function completeness)
#Note that this method will not be called if this state is an exit state
func update(delta:float)->void:
	# Move control, different state's move logic are controlled at here.
	var dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	player.velocity.x = lerp(player.velocity.x , dir * player.move_speed, delta *player. float_horizon_accel)
	player.velocity.y += player.gravity * delta
	player.velocity = player.move_and_slide(player.velocity,Vector2.UP)

	# Set hfsm's variable for transtion condition check.
	# Just for the transitions between "move" and "idle".
	# Others transitions is controlled by expression conditions, please refer the hfsm's graph for more.
	hfsm.set_float("velocity_length" ,player.velocity.length())

#Will be called every physics frame if the hfsm's process_type is setted at "Physics" or "Idle And Physics",
#and will be called every frame if the hfsm's process_type is setted at "Idle".
#(In order to ensure the function completeness)
#Note that this method will not be called if this state is an exit state
func physics_update(delta:float)->void:
	# Display the velocity length.
	player.velocity_length_label.text = str(player.velocity.length())

#Will be called every time when exit this state.
#Note that this method will be called immediatly after entry() if this state is an exit state.
func exit()->void:
	pass
