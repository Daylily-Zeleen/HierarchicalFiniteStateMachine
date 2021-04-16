tool
extends HBoxContainer

onready var hfsm_editor = get_parent().get_parent()
onready var tip :Label = get_node("Tip")
onready var history :Label = get_node("History")

const Tip:Dictionary = {
	DEFAULT = "Right click: popup mune | Shift+Left click: creat transition | Ctrl+Left click: multiple select | Delete : delete | Esc: cancel current opereation",
	CONNECT = "Click to state to connect.",
	CREATE_CONNECT_SUCCESS = "Creat Transition success.",
	CANCEL_CONNECT = "Cancel connect.",
	CANCEL_RECONNECT = "Cancel reconnect.",
	ADD_STATE = "Add State.",
	ADD_VARIABLE_EXPRESSION_SUCCESS = "Add Variable Expression success.",
	ALREADY_EXIST_ENTRY_STATE = "Already exist entry state,but set at this state."
}
const Error:Dictionary = {
	NOT_AT_VARIABLE_CONDITION_MODE = "Can't drag to add variable expression,please set at vaiable condition mode.",
	VARIABLE_EXPRESSION_ALREADY_EXIST = "Can't drag to add variable expression,this variable already exist in this transition.",
	TRANSITION_ALREADY_EXIST = "Can't connect to this state,already exist a equivalent transition.",
	NOT_ENTRY_STATE = "Current State Machine has not a entry state."
}
const History:Dictionary = {
	DRAG_OBJECTS = "Drag Objects",
	DRAG_VARIABLE_LIST = "Drag Variable List",
	CONVERT_TO_NESTED_STATE_MACHINE = "Conver to Nested State Machine",
	SWITCH_CURRENT_STATE_MACHINE = "Switch current State Machine",
	ENTER_NESTED_STATE_MACHINE = "Enter nested State Machine",
	SWITCH_TRANSITION_COMMENT_VISIBLE = "Switch Transition comment visible",
	DELETE_OBJECT = "Delete Objects",
	
	COPY = "Copy",
	PASTE = "Paste" , 
	DUPLICATE = "Duplicate" ,
	
	SWITCH_VARIABLE_LIST_VISIBLE = "Switch Variable List visible",
	
	MOVE_VARIABLE_UP = "Move Variable up" ,
	MOVE_VARIABLE_DOWN = "Move Variable down",
	
	ADD_VARIABLE = "Add variable" , 
	SET_VARIABLE_TYPE = "Set Variable type",
	EDIT_VARIABLE_NAME = "Edit Variable name",
	EDIT_VARIABLE_COMMENT = "Edit Variable comment",
	DELETED_VARIABLE = "Delete Variable",
	 
	ADD_STATE = "Add State",
	SET_STATE_NAME = "Set State name",
	SET_STATE_TYPE = "Set State type",
	SET_STATE_IS_NESTED = "Set State is nested",
	SET_STATE_SCRIPT = "Set State script",
	SET_STATE_AUTO_RESET = "Set State auto reset when entry",
	SET_STATE_NESTED_FSM_AUTO_RESET = "Set State'Nested Fsm auto reset when entry",
	CREATE_TRANSITION = "Create Transition",
	RECONNECT_TRANSITION = "Rconnect Transition",
	
	SWITCH_VARIABLE_LIST_FOLDING_STATE = "Set Variable List foling state",
	
	SET_TRANSITION_TYPE = "Set Transition type",
	
	SET_AUTO_CONDITION_MODE = "Set Auto Condition mode",
	SET_AUTO_CONDITION_DELAY_TIME = "Set Auto Condition delay time",
	SET_AUTO_CONDITION_TIMES = "Set Auto Condition times",
	
	EDIT_EXPRESSTION_CONDITION_TEXT = "Edit Expression Condition text",
	EDIT_EXPRESSTION_CONDITION_COMMENT = "Edit Expression Condition Comment",
	
	MOVE_VARIABLE_EXPRESSION_UP = "Move Variable Expression up",
	MOVE_VARIABLE_EXPRESSION_DOWN = "Move Variable Expression down",
	SET_VARIABLE_CONDITION_OPERATION_MODE = "Set Variable Condition operation mode",
	ADD_VARIABLE_EXPRESSION = "Add Varibale Expression",
	SET_VARIABLE_EXPRESSION_TRIGGET_MODE = "Set  Variable Expression trigger mode",
	SET_VARIABLE_EXPRESSION_COMPARATION = "Set Variable Expression comparation",
	EDIT_VARIABLE_EXPRESSION_VALUE = "Edit Variable Expression value",
	DELETE_VARIABLE_EXPRESSION = "Delete Variable Expression",
}


func _ready():
	set_tip(Tip.DEFAULT)
	set_history("")
	
var reset_to_default_timer :float= 0
func _process(delta):
	if tip.text == Error.NOT_ENTRY_STATE :
		if hfsm_editor.has_entry_state():
			set_tip(Tip.DEFAULT)
			set_process(false)
	reset_to_default_timer -= delta 
	if reset_to_default_timer <= 0 :
		set_tip(Tip.DEFAULT)
		set_process(false)
		
func set_tip(text:String):
	tip.self_modulate = Color.white
	tip.text = text
	if text != Tip.DEFAULT :
		reset_to_default_timer = 5
		set_process(true)

func set_error(text:String):
	tip.self_modulate = Color.crimson
	tip.text = text
	reset_to_default_timer = 5 
	set_process(true)
	
func set_history(text :String):
	history.text = text
func set_undo_history(text:String):
	history.text = "Undo: " + text
func set_redo_history(text:String):
	history.text = "Redo: " + text
	

