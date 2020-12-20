extends StaticBody2D
signal clicked(node)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var picked = false
var note = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("clicked", self, "handle_click")
	#pass # Replace with function body.

func _input_event(object, event, idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		emit_signal("clicked", self)


func handle_click( event):
	#print('in input')	
	print(note," clicked")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
