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


