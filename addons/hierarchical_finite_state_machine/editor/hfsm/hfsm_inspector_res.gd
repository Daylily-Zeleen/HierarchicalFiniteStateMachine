extends Resource
const HfsmConstant = preload("../../script/source/hfsm_constant.gd")
signal script_reload_request
var hfsm
func _init(_hfsm):
	hfsm = _hfsm


enum ProcessTypes {
	IDLE_AND_PHYSICS , 
	IDLE ,
	PHYSICS ,
	MANUAL ,
}
enum ResetOption {
	NOT_FORCE , 
	FORCE_RESET ,
	FORCE_PERSIST , 
}
var active : bool = true setget set_active, get_active
func set_active(v:bool)->void :
	hfsm.active = v
func get_active()->bool :
	return hfsm.active

var process_type :int = ProcessTypes.IDLE_AND_PHYSICS setget set_process_type , get_process_type
func set_process_type(type :int)->void:
	hfsm.process_type = type
func get_process_type()->int:
	return hfsm.process_type
	
var agents :Dictionary = {"null" : NodePath("")} setget _set_agents , _get_agents
func _set_agents(a:Dictionary)->void:
	for p in hfsm.agents.values():
		var obj:Node = hfsm.owner.get_node_or_null(String(p))
		if not obj:
			obj = hfsm.get_node_or_null(p) 
		if obj:
			if obj.is_connected("renamed",self,"_on_Agents_node_renamed"):
				obj.disconnect("renamed",self,"_on_Agents_node_renamed")
	var obj_to_path :Dictionary
	for k in a.keys():
		var obj = hfsm.owner.get_node_or_null(String(a[k]))
		if not obj:
			obj = hfsm.get_node_or_null(a[k])
		if not obj:
			a.erase(k)
		elif not obj in obj_to_path.keys():
			obj_to_path[obj] = a[k]
			obj.connect("renamed",self,"_on_Agents_node_renamed")
	var new_agents :Dictionary 
	for obj in obj_to_path.keys():
		var node_name :String = obj.name
		if not self._disable_rename_to_snake_case :
			node_name = node_name.capitalize().to_lower().replace(" " ,"_")
		while node_name in new_agents.keys():
			push_warning("HFSM : The name of node '%s' already exist in 'agents' ,and be rename by append '_' ,recommend to rename the target node name." % obj.name)
			node_name += "_"
		new_agents[node_name] = obj_to_path[obj]
	new_agents["null"] = NodePath()
	hfsm.agents = new_agents
	_change_script_agents()
	yield(hfsm.get_tree(),"idle_frame")
	yield(hfsm.get_tree(),"idle_frame")
	property_list_changed_notify()
func _get_agents()->Dictionary:
	var a :Dictionary = hfsm.agents.duplicate()
	for k in a.keys():
		if k == "null":
			 a.erase(k)
	a["null"] = NodePath()
	return a

var _disable_rename_to_snake_case :bool = false setget _set_disable_rename_to_snake_case
func _set_disable_rename_to_snake_case(b:bool)->void:
	_disable_rename_to_snake_case = b
	self.agents = self.agents


var _force_all_state_entry_behavior :int = 0 setget _set_force_all_state_reset_behavior , _get_force_all_state_reset_behavior
func  _set_force_all_state_reset_behavior(v:int):
	hfsm._force_all_state_entry_behavior = v
func  _get_force_all_state_reset_behavior():
	return hfsm._force_all_state_entry_behavior
var _force_all_fsm_entry_behavior :int = 0 setget _set_force_all_fsm_auto_reset_behavior , _get_force_all_fsm_auto_reset_behavior
func _set_force_all_fsm_auto_reset_behavior(v:int):
	hfsm._force_all_fsm_entry_behavior = v
func _get_force_all_fsm_auto_reset_behavior():
	return hfsm._force_all_fsm_entry_behavior
	
func _get_property_list()->Array:
	var process_types_hint_string :String
	for i in range(ProcessTypes.size()):
		for enum_key in ProcessTypes.keys():
			if i == ProcessTypes[enum_key]:
				if process_types_hint_string != "":
					process_types_hint_string += ","
				process_types_hint_string += (enum_key as String).capitalize()
				
	var reset_option_hint_string :String
	for i in range(ResetOption.size()):
		for enum_key in ResetOption.keys():
			if i == ResetOption[enum_key]:
				if reset_option_hint_string != "":
					reset_option_hint_string += ","
				reset_option_hint_string += (enum_key as String).capitalize()
	var properties :Array
	properties.push_back({name = "HFSM",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })

	properties.push_back({name = "active",type = TYPE_BOOL })
	properties.push_back({name = "process_type",type = TYPE_INT , hint = PROPERTY_HINT_ENUM ,hint_string = process_types_hint_string })
	properties.push_back({name = "agents",type = TYPE_DICTIONARY })
	
	properties.push_back({name = "Advanced Setting" , type = TYPE_NIL , usage = PROPERTY_USAGE_GROUP})
	
	properties.push_back({name = "_disable_rename_to_snake_case",type = TYPE_BOOL })
	properties.push_back({name = "_force_all_state_entry_behavior",type = TYPE_INT,hint = PROPERTY_HINT_ENUM , hint_string = reset_option_hint_string })
	properties.push_back({name = "_force_all_fsm_entry_behavior",type = TYPE_INT,hint = PROPERTY_HINT_ENUM  , hint_string = reset_option_hint_string})
	properties.push_back({name = "_root_fsm_res",type = TYPE_OBJECT , hint = PROPERTY_HINT_RESOURCE_TYPE ,hint_string ="Resource" ,usage = PROPERTY_USAGE_STORAGE})
	
	return properties

func _change_script_agents():
	var agents_text :String = HfsmConstant.AgentsStartMark
	for custom_class in self._custom_class_list.keys() :
		if self._custom_class_list[custom_class].is_abs_path():
			agents_text += "const %s = preload(\"%s\")\n" %[custom_class.substr(0 ,custom_class.find(".")) , self._custom_class_list[custom_class]]
	for agent_name in self.agents.keys():
		var obj:Node = hfsm.owner.get_node_or_null(String(self.agents[agent_name]))
		if not obj:
			obj = hfsm.get_node_or_null(self.agents[agent_name])
		var obj_class :String 
		if obj:
			for custom_class in self._custom_class_list.keys() :
				if obj .get_script() and obj.get_script().resource_path == self._custom_class_list[custom_class]:
					obj_class = custom_class
			if not obj_class :
				obj_class = obj.get_class()
			agents_text += "var %s : %s \n"%[agent_name , obj_class]
	agents_text += HfsmConstant.AgentsEndMark
	
	var state_script_to_state:Dictionary = hfsm._root_fsm_res.get_state_script_to_state()
	for s_s in state_script_to_state.keys() :
		var code_text:String = s_s.source_code
		if HfsmConstant.Extends in code_text.replace(" ","") or HfsmConstant.Extends_ in code_text.replace(" ",""):
			if HfsmConstant.AgentsStartMark in code_text and HfsmConstant.AgentsEndMark in code_text:
				var start_index :int = code_text.find(HfsmConstant.AgentsStartMark) 
				var end_index :int = code_text.find(HfsmConstant.AgentsEndMark) + HfsmConstant.AgentsEndMark.length()
				var replace_text = code_text.substr(start_index , end_index-start_index)
				code_text = code_text.replace(replace_text , agents_text)
		var tmp_script
		if s_s is GDScript:
			tmp_script = GDScript.new()
		elif s_s is CSharpScript :
			tmp_script = CSharpScript.new()
		tmp_script.source_code = code_text
		
		var tmp :Resource = Resource.new()
		tmp.take_over_path(s_s.resource_path)
		tmp.resource_path = ""
		ResourceSaver.save(s_s.resource_path, tmp_script)
			
	emit_signal("script_reload_request")

func _on_Agents_node_renamed():
	var size:int = self.agents.size()
	self.agents = self.agents
	if size > self.agents.size() :
		printerr("HFSM :the agent node has been renamed and lost reference , consider to add it again.")

