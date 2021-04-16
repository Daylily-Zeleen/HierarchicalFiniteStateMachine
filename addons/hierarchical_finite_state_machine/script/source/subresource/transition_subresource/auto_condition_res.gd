tool
extends Resource

const HfsmConstant = preload("../../../../script/source/hfsm_constant.gd")

var auto_transit_mode :int= HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER
var delay_time :float = 1.0
var times :int = 5

func _get_property_list():
	var properties :Array
#			properties.push_back({name = "AutoConditionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "auto_transit_mode",type = TYPE_INT })
	properties.push_back({name = "delay_time",type = TYPE_REAL })
	properties.push_back({name = "times",type = TYPE_INT})
	
	return properties

func _init(_auto_transit_mode :int= HfsmConstant.AUTO_TRANSIT_MODE_DELAY_TIMER ,_delay_time :float = 1.0 ,_times :int = 5):
	auto_transit_mode = _auto_transit_mode
	delay_time = _delay_time
	times = _times
