##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  735170336@qq.com.                                                   
#
#	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#	Hirerarchical Finite State Machine(HFSM - Full Version).   
#     
#                 
#	This file is part of HFSM - Full Version.
#                                                                                                                       *
#	HFSM - Full Version is a Godot Plugin that can be used freely except in any 
#form of dissemination, but the premise is to donate to plugin developers.
#Please refer to LISENCES.md for more information.
#                                                                   
#	HFSM - Full Version是一个除了以任何形式传播之外可以自由使用的Godot插件，前提是向插件开
#发者进行捐赠，具体许可信息请见 LISENCES.md.
#
#	This is HFSM‘s full version ,But there are only a few more unnecessary features 
#than the trial version(please read the READEME.md to learn difference.).If this 
#plugin is useful for you,please consider to support me by getting the full version.
#If you do not want to donate,please consider to use the trial version.
#
#	虽然称为HFSM的完整版本，但仅比试用版本多了少许非必要的功能(请阅读README.md了解他们的差异)。
#如果这个插件对您有帮助，请考虑通过获取完整版本来支持插件开发者，如果您不想进行捐赠，请考虑使
#用试用版本。
#
# Trail version link : 
#	https://gitee.com/y3y3y3y33/HierarchicalFiniteStateMachine
#	https://github.com/Daylily-Zeleen/HierarchicalFiniteStateMachine
# Sponsor link : 
#	https://afdian.net/@Daylily-Zeleen
#	https://godotmarketplace.com/?post_type=product&p=37138    
#                                    
#	@author   Daylily-Zeleen                                               
#	@email    daylily-zeleen@qq.com                                              
#	@version  0.8(版本号)                                                               
#	@license  Custom License(Read LISENCES.TXT for more details)
#                                                                      
#----------------------------------------------------------------------------
#  Remark         :                                             
#----------------------------------------------------------------------------
#  Change History :                                                          
#  <Date>     | <Version> | <Author>       | <Description>                   
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file           
#  2022/07/02 | 0.8   | Daylily-Zeleen      | Add C# script template code
#----------------------------------------------------------------------------
#                                                                            
##############################################################################
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

const gd_state_template_target_path = "res://script_templates/hfsm_state_template.gd"
const cs_state_template_target_path = "res://script_templates/hfsm_state_template.cs"
const gd_transition_templapte_target_path = "res://script_templates/hfsm_transition_template.gd"
const cs_transition_templapte_target_path = "res://script_templates/hfsm_transition_template.cs"
const ignore_target_path = "res://script_templates/.gdignore"
const template_folder_path = "res://script_templates"
const gd_state_template_default_path = "res://addons/hierarchical_finite_state_machine/script_templates/hfsm_state_template.gd"
const gd_transition_template_default_path = "res://addons/hierarchical_finite_state_machine/script_templates/hfsm_transition_template.gd"
#const cs_template_default_path = "res://addons/hierarchical_finite_state_machine/script_templates/hfsm_state_template.cs"
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


const CSStateTemplate ="""
/*
	You can use 'Hfsm' to call the HFSM which contain this state , and call it's menbers.
	Please browse document to find API.
	
	== Note!! == 
	C# template can't auto replace class name, because the Template PlaceHolder grammar will be recognaize as C# grammar errs.
	Please Repalce you state class name Manually!!!
	
	== 注意！！== 
	C# 模板不能自动替换类名，因为模板占位符在会被识别为C#语法错误。
	请在创建改脚本后手动替换类名！！！
*/
using Godot;

// public class %CLASS%: HFSM.State
public class PlaceHolder: HFSM.State
{
	/*
		CSharpScript State version unsupport auto append agents and the state which is nest this state.
		Because Godot can't get latest CSharpScript.source_code without reboot project( event if after build).
		This feature will be considered to add if godot fix this bug. 

		C# 状态脚本不支持自动添加 代理变量 和 内嵌该状态的状态变量。
		因为Godot不能获取最新的C#脚本代码，除非重启项目(即使在build之后)。
		只有Godot修复了这个bug，该特性才会被考虑添加进来。 

		You can add them mamually as follow:

		// "Node" can be replace as the class name of agent node.
		// "agent_node_name" must be a snake_case name of agent node, but it can be replace as agent node's name(usually it is PascalCase) if the HFSM is disable rename agent node name as snake_case.
		//     (HFSM -> Inspector-> Advanced Setting-> check Disable Rename To Snake Case)
		public Node agent_node_name{set;get;}
		public Node agent_node_name_other{set;get;}
		
		// "Reference" can be repalce as the class name of state which is nest this state if it is coded in C#, 
		// "fsm_nested_state_name" must be a name "'fsm_'+ the state name of state which is nest this state."
		public Reference fsm_nested_state_name{set;get;} 

		// "Node"可以被替换为代理节点的具体类名.
		// "agent_node_name"必须是代理节点的snake_case名称，但是当禁用HFSM重命名代理节点名称为snake_case的功能时，你可以将其替换为代理节点的名称（通常为PascalCase）。
		//     (HFSM -> 监视器 -> Advanced Setting-> 勾选 Disable Rename To Snake Case)
		public Node agent_node_name{set;get;}
		public Node agent_node_name_other{set;get;}
		
		// 如果嵌套该状态的状态附加了C#编写的脚本，"Reference"可以被替换为具体的类名。 
		// "fsm_nested_state_name"必须是 "'fsm_'+被该状态嵌套的父级状态名称."
		public Reference fsm_nested_state_name{set;get;} 
	*/
	
	
	/// <summary>
	/// This funcion will be called just once when the hfsm is generated.
	/// </summary>
	public override void Init(){
		// Your Init logic...
	}
	/// <summary>
	/// Will be called every time when entry this state.
	/// </summary>
	public override void Entry(){
		// Your Entry logic...
	}
	/// <summary>
	/// Will be called every frame if the hfsm's process_type is setted at "Idle" or "Idle And Physics",
	/// and will be called every physics frame if the hfsm's process_type is setted at "Physics".
	/// (In order to ensure the function completeness)
	/// Note that this method will not be called if this state is an exit state.
	/// </summary>
	/// <param name="delta">The interval between last update, in second.</param>
	public override void Update(float delta){
		// Your Update logic...
	}

	/// <summary>
	/// Will be called every physics frame if the hfsm's process_type is setted at "Physics" or "Idle And Physics",
	/// and will be called every frame if the hfsm's process_type is setted at "Idle".
	/// (In order to ensure the function completeness)
	/// Note that this method will not be called if this state is an exit state
	/// </summary>
	/// <param name="delta">The interval between last update, in second.</param>
	public override void PhysicsUpdate(float delta){
		// Your Physics Update logic...
	}
	/// <summary>
	/// Will be called every time when exit this state.
	/// Note that this method will be called immediatly after entry() if this state is an exit state.
	/// </summary>
	public override void Exit(){
		// Your Exit logic..
	}
}
"""
