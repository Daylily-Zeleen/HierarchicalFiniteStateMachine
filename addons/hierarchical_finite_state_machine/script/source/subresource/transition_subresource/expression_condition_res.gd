tool
extends Resource

export(String)var expression_text :String =""
export(String)var expression_comment :String =""
		
func _get_property_list():
	var properties :Array
#			properties.push_back({name = "ExpressionConditionRes",type = TYPE_NIL,usage = PROPERTY_USAGE_CATEGORY  })
	
	properties.push_back({name = "expression_text",type = TYPE_STRING })
	properties.push_back({name = "expression_comment",type = TYPE_STRING })
	
	return properties
	
func _init(_expression_string :String ="" ,_expression_comment :String =""):
	expression_text = _expression_string
	expression_comment = _expression_comment
