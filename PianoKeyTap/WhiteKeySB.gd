extends StaticBody2D
#extends Key
signal clicked(node)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var picked = false
var note = ""


func _input_event(object, event, idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		emit_signal("clicked", self)

# Called when the node enters the scene tree for the first time.
func _ready():
	#connect("clicked", self, "handle_click")
#	init('A') # uncomment to view the shape of a given note
	pass # Replace with function body.

func handle_click( event):
	#print('in input')
	print(note, " clicked")
	
func init(notename):
	# set the note parameter
	note = notename
	
	var yperc = 0.67 # % of vertical dimension that the black key overlaps
	var xpercL = 0
	var xpercR = 0
	# set the collision object shape based on the note
	# the decimals are the exact fit percentages; 
	# use this constant > 0 to give the black key more clickable area
	# THESE CONSTANTS DON'T SEEM TO CHANGE THE SHAPE?
	var perc_decrease = 0.01
	if notename == 'A':
		xpercL = 0.29 + perc_decrease
		xpercR = 0.21 + perc_decrease
	elif notename == 'B':
		xpercL = 0.38 + perc_decrease
		xpercR = 0.01 + perc_decrease
	elif notename == 'C':
		xpercL = 0.01 + perc_decrease
		xpercR = 0.37 + perc_decrease
	elif notename == 'D':
		xpercL = 0.22 + perc_decrease
		xpercR = 0.22 + perc_decrease
	elif notename == 'E':
		xpercL = 0.37 + perc_decrease
		xpercR = 0.01 + perc_decrease
	elif notename == 'F':
		xpercL = 0.01 + perc_decrease
		xpercR = 0.55 + perc_decrease
	elif notename == 'G':
		xpercL = 0.22 + perc_decrease
		xpercR = 0.28 + perc_decrease
	
	var keyshape = $WhiteKeyRect.polygon
	print('keyshape: ', keyshape)
	var width = keyshape[1][0] - keyshape[0][0]
	var height = keyshape[2][1] - keyshape[1][1]
	print('height: ', height)
	var new_polygon = $WKCollision.polygon
	
	new_polygon[0][0] = round( xpercL * width);
	new_polygon[0][1] = round( 0);
	new_polygon[1][0] = round( (1-xpercR) * width);
	new_polygon[1][1] = round( 0);
	new_polygon[2][0] = round( (1-xpercR) * width);
	new_polygon[2][1] = round( yperc * height);
	new_polygon[3][0] = round( width);
	new_polygon[3][1] = round( yperc * height);
	new_polygon[4][0] = round( width);
	new_polygon[4][1] = round( height);
	new_polygon[5][0] = round( 0);
	new_polygon[5][1] = round( height);
	new_polygon[6][0] = round( 0);
	new_polygon[6][1] = round( yperc * height);
	new_polygon[7][0] = round( xpercL * width);
	new_polygon[7][1] = round( yperc * height);
	#var newshape = ConcavePolygonShape2D(polygon)
	#shape_owner_add_shape ( $WKCollision,  polygon)
	print(' new polygon: ', new_polygon)
	$WKCollision.set_polygon(new_polygon)
	

## code from online
#var area = Area.new()
#	var collision_shape_node = CollisionShape.new();
#	var rect_shape = RectangleShape2D.new();
#	rect_shape.
#	var sphere_shape = SphereShape.new()
#	sphere_shape.radius = 1.0
#	collision_shape_node.set_shape(sphere_shape);
#	area.add_child(collision_shape_node)
#	add_child(area)



#func _input(event):
#	print('in input')
#	var mouse_click = event as InputEventMouseButton
#	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
#		print("clicked")
#		var bodies = WKInput
#		for b in bodies:
#			if b.name == "WhiteKey":
#				picked = true
#
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
