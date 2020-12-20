extends "res://Key.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#SIZE = [105,520]
	y_snaptopoint_shift = 5/6
#	pass # Replace with function body.

func set_size():
	SIZE = [105,520]
	

func set_color():
	orig_color = Color(1,1,1)
	colorscale = [.9, .9] # correct, incorrect
#func init(notename):
#
#	# set the note parameter
#	note = notename
#
#	draw_key()
	
func set_collision_shape():
	# set the collision shape
	var yperc = 0.67
	var xpercL = 0
	var xpercR = 0
	# set the collision object shape based on the note
	if note == 'A':
		xpercL = 0.28
		xpercR = 0.17
	elif note == 'B':
		xpercL = 0.38
		xpercR = 0.01
	elif note == 'C':
		xpercL = 0.01
		xpercR = 0.37
	elif note == 'D':
		xpercL = 0.2
		xpercR = 0.2
	elif note == 'E':
		xpercL = 0.37
		xpercR = 0.01
	elif note == 'F':
		xpercL = 0.01
		xpercR = 0.41
	elif note == 'G':
		xpercL = 0.2
		xpercR = 0.28
	
	# var keyshape = $WhiteKeyRect.polygon
	# print('keyshape: ', keyshape)
	var width = SIZE[0] * scale_factor #- keyshape[0][0]
	var height = SIZE[1] * scale_factor #keyshape[2][1] - keyshape[1][1]
#	print('height: ', height)
	var new_polygon = $KeyCollision.polygon
	
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
#	print(' new polygon: ', new_polygon)
#	print(' new polygon: ', new_polygon)
	$KeyCollision.set_polygon(new_polygon)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


#var matrix = []
#for x in range(width):
#    matrix.append([])
#    for y in range(height):
#        matrix[x].append(0)
