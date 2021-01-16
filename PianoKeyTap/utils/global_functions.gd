extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_dyn_font(sz = 50,clr = Color(1,1,1)):
	var df = DynamicFont.new()
	df.font_data = load('res://Fonts/Roboto-Medium.ttf')
	df.size = sz
	df.outline_color = clr
	return df
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
