extends KinematicBody2D

var velocity:Vector2 = Vector2.ZERO
var gravity:= 400
var accel := 15.0
var jump_speed = -300
var move_speed = 150

onready var hfsm = get_node("HFSM")
onready var state_label :Label=get_node("StateLabel")
onready var velocity_length_label :Label = get_node("VelocityLengthLabel")

func _on_HFSM_physics_updated(state, delta:float, fsm_path:Array):
	var dir := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if state != "jump":
		velocity.x = lerp(velocity.x , dir * move_speed ,delta*accel)
	velocity = move_and_slide_with_snap(velocity,Vector2.DOWN , Vector2.UP)
	hfsm.set_float("velocity_length" ,velocity.length())

func _on_HFSM_transited(from, to,fsm_path):
	#print the transit infomation.
	print("transit from '%s' to '%s',path :" % [from if from else "null" , to if to else "null"] , fsm_path)


func _on_HFSM_updated(state, delta, fsm_path):
	#to demostrate the feature,change the state label by using 'transited' signal is mor better.
	if state_label:
		state_label.text = state


func _on_HFSM_entered(state:String, fsm_path:Array):
	#just to demonstrate the feature
	print("entry :" , fsm_path)
