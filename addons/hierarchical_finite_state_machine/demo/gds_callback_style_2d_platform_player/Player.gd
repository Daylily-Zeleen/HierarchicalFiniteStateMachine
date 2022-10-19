extends KinematicBody2D

var velocity:Vector2 = Vector2.ZERO
var gravity:= 400
var accel := 15.0
var jump_speed = -300
var move_speed = 150
var float_horizon_accel = 50

onready var hfsm = get_node("HFSM")
onready var state_label :Label=get_node("StateLabel")
onready var velocity_length_label :Label = get_node("VelocityLengthLabel")




func _on_HFSM_updated(state:String, delta:float, fsm_path:Array) -> void:
	# Move control, different state's move logic are controlled at here.
	var dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	match state:
		"idle", "move":
			velocity.x = lerp(velocity.x , dir * move_speed ,delta*accel)
			velocity = move_and_slide_with_snap(velocity,Vector2.DOWN if velocity.y >= 0 else Vector2.ZERO, Vector2.UP)
		"jump":
			velocity.x = lerp(velocity.x , dir * move_speed, delta * float_horizon_accel)
			velocity.y += gravity * delta
			velocity = move_and_slide(velocity,Vector2.UP)

	# Set hfsm's variable for transtion condition check.
	# Just for the transitions between "move" and "idle".
	# Others transitions is controlled by expression conditions, please refer the hfsm's graph for more.
	hfsm.set_float("velocity_length" ,velocity.length())

func _on_HFSM_physics_updated(state:String , delta:float, fsm_path:Array) -> void:
	# Display the velocity length.
	velocity_length_label.text = str(velocity.length())

func _on_HFSM_entered(state:String, fsm_path:Array) -> void:
	# Print the entered state.
	print("enter: ", state)
	# Show current state.
	state_label.text = state
	# Apply jump vertical velocity
	if state == "jump":
		if Input.is_action_just_pressed("ui_select"):
			velocity.y += jump_speed
			hfsm.set_float("velocity_length" ,velocity.length())

func _on_HFSM_transited(from:String, to:String, fsm_path:Array) -> void:
	# Print the transit infomation for debug.
	print("transit from '%s' to '%s',path :" % [from if from else "null" , to if to else "null"] , fsm_path)


func _on_HFSM_exited(state: String, fsm_path: Array) -> void:
	print("exited :" , state)
