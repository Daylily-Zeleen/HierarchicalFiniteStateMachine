extends Control

func _on_Button_pressed():
	get_node("HFSM").set_trigger("t_pressed")


func _on_HFSM_transited(from, to, fsm_path):
	get_node("Button").text = "'%s' -> '%s' ,the fsm path:%s" % [from if from else "null" , to if to else "null" , str(fsm_path)]


func _on_HFSM_entered(state, fsm_path):
	print(state, fsm_path)
