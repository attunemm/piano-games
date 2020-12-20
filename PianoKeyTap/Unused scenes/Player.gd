extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var screenHeight = ProjectSettings.get_setting("display/window/size/height")
var screenWidth = ProjectSettings.get_setting("display/window/size/width")
var direction = Vector2(-5,-2.3)

# Called when the node enters the scene tree for the first time.
func _ready():
	print('screen height = ', screenHeight)
	print('screen width - ', screenWidth)
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += direction
	if position.x >= screenWidth or position.x <= 0:
		direction.x = -(direction.x)
		print('out in x')
	if position.y >= screenHeight or position.y <= 0:
		direction.y = -(direction.y)
		print('out in y')
