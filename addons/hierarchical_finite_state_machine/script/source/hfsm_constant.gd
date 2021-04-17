##############################################################################
#	Copyright (C) 2021 Daylily-Zeleen  735170336@qq.com. 
#                                                  
#	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
#	Hirerarchical Finite State Machine - Trial Version(HFSM - Trial Version)   
#     
#                 
#	This file is part of HFSM - Trial Version.
#                                                                
#	HFSM -Triabl Version is free Godot Plugin: you can redistribute it and/or 
#modify it under the terms of the GNU Lesser General Public License as published 
#by the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#	HFSM -Triabl Version is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU Lesser General Public License for more details.
#
#	You should have received a copy of the GNU Lesser General Public License
#along with HFSM -Triabl Version.  If not, see <http://www.gnu.org/licenses/>.                                                                          *
#
#	HFSM -Triabl Version是一个自由Godot插件，您可以自由分发、修改其中的源
#代码或者重新发布它，新的任何修改后的重新发布版必须同样在遵守LGPL3或更后续的
#版本协议下发布.关于LGPL协议的细则请参考COPYING、COPYING.LESSER文件，
#	您可以在HFSM -Triabl Version的相关目录中获得LGPL协议的副本，
#如果没有找到，请连接到 http://www.gnu.org/licenses/ 查看。
#
#
#	This is HFSM‘s triable version ,but it contain almost features of the full version
#(please read the READEME.md to learn difference.).If this plugin is useful for you,
#please consider to support me by getting the full version.
#
#	虽然这是HFSM的试用版本，但是几乎包含了完整版本的所有功能(请阅读README.md了解他们的差异)。如果这个
#插件对您有帮助，请考虑通过获取完整版本来支持我。
#	
# Sponsor link (赞助链接): 
#	https://afdian.net/@Daylily-Zeleen
#	https://godotmarketplace.com/?post_type=product&p=37138   
#
#                                    
#	@author   Daylily-Zeleen                                                      
#	@email    735170336@qq.com                                              
#	@version  0.1(版本号)                                                       
#	@license  GNU Lesser General Public License v3.0 (LGPL-3.0)                                
#                                                                      
#----------------------------------------------------------------------------
#  Remark         :                                            
#----------------------------------------------------------------------------
#  Change History :                                                          
#  <Date>     | <Version> | <Author>       | <Description>                   
#----------------------------------------------------------------------------
#  2021/04/14 | 0.1   | Daylily-Zeleen      | Create file                     
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

