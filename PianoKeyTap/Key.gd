extends StaticBody2D
#test
signal clicked(node)

# Declare member variables here. Examples:
var note = ''
var SIZE = [0,0,0,0]
var scale_factor = 2 # original sizes were based on 896 x 504 pixels
var orig_color 
var colorscale = 1
var y_snaptopoint_shift = 2/3 # amount down a key to place a player
var A_rgb = Color8(7,129,230)
var B_rgb = Color8(75,25,75)
var C_rgb = Color8(250,64,2)
var D_rgb = Color8(1,161,40)
var E_rgb = Color8(20,50,140)
var F_rgb = Color8(220,55,95)
var G_rgb = Color8(220,210,75)
var highlight_when_play = true # true = highlight when playing the audio; use when playing notes outside the game
var is_playing = false
#var alt_note = '' # for keys that can be called by more than 1 name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# overload the following 3 functions in the subclasses
func set_size():
	pass

func get_size():
	return SIZE
	
func set_color():
	pass
	
func set_collision_shape():
	pass
	
func init(notename):
	# set the note parameter
	note = notename
	
	set_size()
	set_color()
	draw_key()
	set_collision_shape()
	var audio_file = "res://AudioFiles/Middle_" + note + ".wav"#".ogg"#".wav"
	if File.new().file_exists(audio_file):
		var sfx = load(audio_file) 
#		sfx.set_loop(false)
		$KeySound.stream = sfx
#		print('loaded ' + audio_file)
	else:
		print('cannot find audio file')
	#speech_player.play()
	
static func other_name(orig_note):
	var alt_note = ''
	if orig_note == 'A_sharp':
		alt_note = 'B_flat'
	elif orig_note == 'C_sharp':
		alt_note = 'D_flat'
	elif orig_note == 'D_sharp':
		alt_note = 'E_flat'
	elif orig_note == 'F_sharp':
		alt_note = 'G_flat'
	elif orig_note == 'G_sharp':
		alt_note = 'A_flat'
	elif orig_note == 'C':
		alt_note = 'B_sharp'
	elif orig_note == 'B':
		alt_note = 'C_flat'
	elif orig_note == 'E':
		alt_note = 'F_flat'
	elif orig_note == 'F':
		alt_note = 'E_sharp'
	elif orig_note == 'B_flat':
		alt_note = 'A_sharp'
	elif orig_note == 'D_flat':
		alt_note = 'C_sharp'
	elif orig_note == 'E_flat':
		alt_note = 'D_sharp'
	elif orig_note == 'G_flat':
		alt_note = 'F_sharp'
	elif orig_note == 'A_flat':
		alt_note = 'G_sharp'
	elif orig_note == 'B_sharp':
		alt_note = 'C'
	elif orig_note == 'C_flat':
		alt_note = 'B'
	elif orig_note == 'F_flat':
		alt_note = 'E'
	elif orig_note == 'E_sharp':
		alt_note = 'F'
	
	return alt_note
	
func draw_key():
	# set the rectangle shape, size and color
	# [0,0]
	var rect = $KeyShape.polygon
	rect[0][0] = 0
	rect[0][1] = 0
	# [width,0]
	rect[1][0] = SIZE[0] * scale_factor
	rect[1][1] = 0
	# [width,height]
	rect[2][0] = SIZE[0] * scale_factor
	rect[2][1] = SIZE[1] * scale_factor
	# [0,height]
	rect[3][0] = 0
	rect[3][1] = SIZE[1] * scale_factor
	
#	print('rect: ', rect)
	$KeyShape.set_polygon(rect)
	$ColorOverlay.set_polygon(rect)
	#$KeyShape.set_color(COLOR) # white
	$KeyShape/SnapToPoint.set_point_position(0,Vector2(SIZE[0]/2 * scale_factor,SIZE[1]*5/6 * scale_factor))
#	$KeyShape/SnapToPoint.position.y = SIZE[1]*2/3
	
func get_point_postion():
	return $KeyShape/SnapToPoint.get_position_in_parent()
	
func _input_event(object, event, idx):
	var mouse_click = event as InputEventMouseButton
	var touch_screen = event as InputEventScreenTouch

	if mouse_click and mouse_click.button_index == 1:
		if mouse_click.pressed:
			play_note()
		else:
			stop_play_note()
	elif touch_screen:
		if touch_screen.pressed:
			play_note()
		else:
			stop_play_note()
		
func set_pitch_scale(ps):
	$KeySound.set_pitch_scale(ps)
	
func stop_play_note():
	if is_playing:
		is_playing = false
		if highlight_when_play:
			reset_color()
		# pause for a little bit before stopping the sound
		yield(get_tree().create_timer(0.5), "timeout")
		if is_playing == false: #could have been set to true by another tap on the key play_count == 0:
			$KeySound.stop()
	
		

# play the note
func play_note():
	if !is_playing:
		$KeySound.bus = "Master" #"DeNoise"
#		set_physics_process_internal(true);
#		notification(NOTIFICATION_INTERNAL_PHYSICS_PROCESS); # HACK - force position update before audio driver tries to process this.
		$KeySound.play(1) # play starting 1 second in to avoid audio artifacts at beginning of clip
		#print('play')
		is_playing = true
		emit_signal("clicked", self)
		if highlight_when_play:
			highlight(note)
	# uncomment this to distort incorrect keys
#	if iscorrect:
#		$KeySound.bus = 'Master' #AudioServer.get_bus_index("Master")
#	else:
#		$KeySound.bus = 'Distort'
#	$KeySound.play(0.3)
#	yield(get_tree().create_timer(0.9), "timeout")
#	$KeySound.stop()
#	$KeySound.bus = 'Master'
	
	
func get_position():
	return position + $KeyShape/SnapToPoint.get_point_position(0)
	
func get_color():
	return $KeyShape.get_color()

func highlight(note_name_for_color): #(iscorrect):
		# change color of key
#	var orig_color = COLOR
	# first color for correct answers (blueish) - second for wrong (grayish)
	var r = [.82, .7]
	var g = [.98, .7]
	var b = [.82, .7]
	var i
	var cs
	var highlight
#	if iscorrect:
#		i = 0
#		cs = colorscale[i]
##		highlight = Color(r[i]*.8, g[i]*.8, b[i]*.8, 1)
#	else:
#		i = 1
#		cs = colorscale[i]
##		highlight = Color(r[i]*colorscale, g[i]*colorscale, b[i]*colorscale, 1)
#		print('r = ', r[i])
	# test changing pitch scale
	var c
	var alpha = .8
	if note_name_for_color.find('correct') == 0:
		c = [r[0],g[0],b[0]]
	elif note_name_for_color.find('incorrect') == 0:
		c = [r[1],g[1],b[1]]
	elif note_name_for_color.find('A') == 0:
		c = A_rgb
	elif note_name_for_color.find('B') == 0:
		c = B_rgb
	elif note_name_for_color.find('C') == 0:
		c = C_rgb
	elif note_name_for_color.find('D') == 0:
		c = D_rgb
	elif note_name_for_color.find('E') == 0:
		c = E_rgb
	elif note_name_for_color.find('F') == 0:
		c = F_rgb
	elif note_name_for_color.find('G') == 0:
		c = G_rgb
		
#	highlight = Color(r[i]*cs, g[i]*cs, b[i]*cs, 1)
#	$KeyShape.set_color(highlight)
	
#	var c = F_rgb # replace with logic to select correct color
	$ColorOverlay.set_color(Color(c[0],c[1],c[2],alpha))
	$ColorOverlay.set_visible(true)
	
func is_highlighted():
	return $ColorOverlay.visible
	
func reset_color():
#	$KeyShape.set_color(orig_color)
	$ColorOverlay.visible = false
#	print('orig color set: ', orig_color)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
