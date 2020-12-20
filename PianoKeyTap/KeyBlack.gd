extends "res://Key.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var


# Called when the node enters the scene tree for the first time.
func _ready():
	y_snaptopoint_shift = 2/3
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_size():
	SIZE = [62,340] #* scale_factor
#	scale = Vector2(scale_factor,scale_factor)

func set_color():
	orig_color = Color(0, 0, 0)
	colorscale = [.8, 0.4] # correct, incorrect
#func draw_key():
#	pass
	
func set_collision_shape():
	var rect = $KeyShape.polygon
	# set the collision shape
	$KeyCollision.set_polygon(rect)
	
#func init(notename):
#
#	# set the note parameter
#	note = notename
#
#	# set the rectangle shape, size and color
#	draw_key()
	
