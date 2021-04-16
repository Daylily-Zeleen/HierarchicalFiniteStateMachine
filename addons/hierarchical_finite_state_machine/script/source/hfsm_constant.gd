#状态类型
enum {
	STATE_TYPE_NORMAL , 
	STATE_TYPE_ENTRY ,
	STATE_TYPE_EXIT , 
}
#TansitionConditionType
enum {
	TRANSITION_TYPE_AUTO ,
	TRANSITION_TYPE_VARIABLE , 
	TRANSITION_TYPE_EXPRESSION ,
}
enum {
	AUTO_TRANSIT_MODE_DELAY_TIMER ,
	AUTO_TRANSIT_MODE_NESTED_FSM_EXIT ,
	AUTO_TRANSIT_MODE_MANUAL ,
	AUTO_TRANSIT_MODE_UPDATE_TIMES ,
	AUTO_TRANSIT_MODE_PHYSICS_UPDATE_TIMES ,
}
#变量条件运算类型
enum{
	VARIABLE_CONDITION_OP_MODE_AND ,
	VARIABLE_CONDITION_OP_MODE_OR ,
}
#变量类型
enum {
	VARIABLE_TYPE_TRIGGER ,
	VARIABLE_TYPE_BOOLEAN , 
	VARIABLE_TYPE_INTEGER ,
	VARIABLE_TYPE_FLOAT ,
	VARIABLE_TYPE_STRING ,
}
#触发器类型
enum {
	TRIGGER_MODE_FORCE , 
	TRIGGER_MODE_NORMAL , 
}
#变量条件比较类型
enum {
	COMPARATION_EQUEAL , 
	COMPARATION_UNEQUEAL ,  
	COMPARATION_GREATER_THAN , 
	COMPARATION_GREATER_THAN_OR_EQUAL , 
	COMPARATION_LESS_THAN , 
	COMPARATION_LESS_THAN_OR_EQUAL , 
}
#布尔
enum {
	BOOL_TRUE , 
	BOOL_FALSE ,
}
#
const AutoTransitionTipText :={
	DELAY_TIMER = "Once entry the 'from_state',it will use delay time which you setted to creat a timer,and transit if the timer timeout." ,
	NESTED_FSM_EXIT = "It will transit if the nested fsm exited.",
	MANUAL = "It will transit after execute manual_exit() in state script manual,ensure this method is called in below override method:\n\t entry()\n\t update()\n\t physics_update()\n\t.",
	UPDATE_TIMES = "It will begin to count the times of hfsm update after entry the 'from_state',and transit if the times reach the preset times which you setted.(i.e. update()'s called times equal your perset times)",
	PHYSICS_UPDATE_TIMES = "It will begin to count the times of hfsm physics update after entry the 'from_state',and transit if the times reach the preset times which you setted.(i.e. physics_update()'s called times equal your perset times)" ,
}

const template_target_path = "res://script_templates/hfsm_state_template.gd"
const ignore_target_path = "res://script_templates/.gdignore"
const template_folder_path = "res://script_templates"
const template_default_path = "res://addons/hierarchical_finite_state_machine/script_templates/hfsm_state_template.gd"
const ignore_default_path = "res://addons/hierarchical_finite_state_machine/script_templates/.gdignore"

const TemplateName :String = "Hfsm State Template"
const ExpressionCommentDefaultText :String = "Here is comment: \n"\
		+ "you can code a condition expression for this transition.However,the identifiers which are used in you expression must be included in below:\n\t"\
		+ "1.'hfsm' :the hierarchical finite state machines. \n\t"\
		+ "2.'from_state' : the state which is this transition connected from.\n\t"\
		+ "3.'to_state' : the state which is this transition connected to.\n\t"\
		+ "4.objects which are define in 'agent' :they are defined by youself. \n\t"\
		+ "5.build-in singletons which define by Godot engine ,such as 'Input' and so on.You can browse then in  '@GlobalScope' ,the second item in Godot document."
#------------------Script Verify----------------------------
const AgentsStartMark :String = "###agents list-start# please not modify this line.\n"
const AgentsEndMark :String = "###agents list-end# please not modify this line.\n"
const NestedFsmStateStartMark :String = "###nested fsm state-start# please not modify this line.\n"
const NestedFsmStateEndMark :String = "###nested fsm state-end# please not modify this line.\n"
const Extends :String = "extends\"res://addons/hierarchical_finite_state_machine/script/source/state.gd\""
const Extends_ :String = "extends'res://addons/hierarchical_finite_state_machine/script/source/state.gd'"
const ExtendsPath:String = "\"res://addons/hierarchical_finite_state_machine/script/source/state.gd\""

enum ProcessMode{
	IDLE , 
	PHYSICS ,
	IDLE_AND_PHYSICS , 
	MAMUAL , 
}

