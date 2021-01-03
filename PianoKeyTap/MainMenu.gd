extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var Keyboard # link to an Octave scene reference
export (PackedScene) var Staff # link to an Octave scene reference
var octave
var oct_scale = 0.25 # shrinks the octave down
var octave_x_offset = 330 # control the location of the octave on the screen
var octave_y_offset = 700
var staff
var staff_wtoh = 1.1
var staff_scale_y = 1.4
var staff_x_offset = 1220
var staff_y_offset = 650

# Called when the node enters the scene tree for the first time.
func _ready():
	# add the keyboard
	octave = Keyboard.instance()
	octave.init(1) # only 1 octave
#	octave.set_scale_factor(scale_factor)
	octave.set_scale(Vector2(oct_scale,oct_scale))
	octave.set_position(Vector2(octave_x_offset,octave_y_offset))
#	var oct_ext = octave.get_extents()
#	print('octave size: ', oct_ext)
	#octave.connect("keysel", self, "set_sel_key")
	add_child(octave)
	
	# add the staff
	staff = Staff.instance()
	staff.set_scale(Vector2(staff_scale_y,staff_scale_y))
	staff.change_width(staff_wtoh)
	staff.set_position(Vector2(staff_x_offset,staff_y_offset))
	# change the white box to be smaller in the y-direction
	var pg = staff.get_polygon()
	pg[0][1] = 40
	pg[1][1] = pg[1][1]-30
	pg[2][1] = pg[2][1]-30
	pg[3][1] = 40
#	print(pg)
	staff.set_polygon(pg)
	add_child(staff)
	
	# connect the buttons to go_to_game function
	for button in self.get_children(): #get_tree().get_nodes_in_group("my_buttons"):
		if button.get_class() == "Button":
			button.connect("pressed", self, "go_to_game", [button])

func go_to_game(button):
	print(button.name)
	if button.name == "Level1":
		get_tree().change_scene("res://Main.tscn")
	elif button.name == "Level2":
		get_tree().change_scene("res://Frogger.tscn")
	elif button.name == "Level3":
		pass
#		get_tree().change_scene("res://Main.tscn")

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
