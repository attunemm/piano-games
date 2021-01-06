extends KinematicBody2D
signal clicked(node)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var notename = "" # holds name of note, e.g., 'C
var pitch_offset = 0 # integer, 0 for middle C - middle B; 1 for 1 octave up, -1 for one octave down, etc
var accidental = 'natural' # can be 'natural', 'sharp', or 'flat'
var velocity = Vector2(0,0) # start with no velocity
var idx # assign an integer to keep track of which note this is, if selecting notes from an array of options in another scene
var mod_color = Color(0.8, 0.1, 0.3)
var A_rgb = Color8(7,129,230)
var B_rgb = Color8(110,25,110) #Color8(75,25,75)
var C_rgb = Color8(250,64,2)
var D_rgb = Color8(1,161,40)
var E_rgb = Color8(20,50,140)
var F_rgb = Color8(220,55,95)
var G_rgb = Color8(220,210,75)
var no_mod_color = Color(0,0,0,1) # black

# Called when the node enters the scene tree for the first time.
func _ready():
	set_accidental('natural')
	set_physics_process(true)
	unhighlight() # set to black as default color
	
func disable_collision():
	$NoteCollision.disabled = true
	
func enable_collision():
	$NoteCollision.disabled = false
	
func show_ledger_lines(ledger_lines):
	#ledger_lines is boolean array for lines to show
#	$Ledger_neg1p5.visible = ledger_lines[0]
#	$Ledger_neg1.visible = ledger_lines[1]
#	$Ledger_negp5.visible = ledger_lines[2]
#	$Ledger_0.visible = ledger_lines[3]
#	$Ledger_p5.visible = ledger_lines[4]
#	$Ledger_1.visible = ledger_lines[5]
#	$Ledger_1p5.visible = ledger_lines[6]
	
	$Ledger_neg1p5.visible = ledger_lines[6]
	$Ledger_neg1.visible = ledger_lines[5]
	$Ledger_negp5.visible = ledger_lines[4]
	$Ledger_0.visible = ledger_lines[3]
	$Ledger_p5.visible = ledger_lines[2]
	$Ledger_1.visible = ledger_lines[1]
	$Ledger_1p5.visible = ledger_lines[0]

func set_name(nname):
	notename = nname
	if nname.begins_with('A'):
		mod_color = A_rgb
	elif nname.begins_with('B'):
		mod_color = B_rgb
	elif nname.begins_with('C'):
		mod_color = C_rgb
	elif nname.begins_with('D'):
		mod_color = D_rgb
	elif nname.begins_with('E'):
		mod_color = E_rgb
	elif nname.begins_with('F'):
		mod_color = F_rgb
	elif nname.begins_with('G'):
		mod_color = G_rgb
		
#	$HighlightedNote.texture = load("res://Icons/WholeNote" + nname + ".png")
	
func set_pitch_offset(num_octaves):
	pitch_offset = num_octaves
	
func set_accidental(acc):
	if acc == 'sharp':
		accidental = acc
		# show the sharp symbol
		$NoteImage/Sharp.visible = true
		# hide the flat symbol
		$NoteImage/Flat.visible = false
	elif acc == 'flat':
		accidental = acc
		# hide the sharp symbol
		$NoteImage/Sharp.visible = false
		# show the flat symbol
		$NoteImage/Flat.visible = true
		
	else:
		accidental = 'natural'
		# hide the sharp symbol
		$NoteImage/Sharp.visible = false
		# hide the flat symbol
		$NoteImage/Flat.visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	#velocity.y += gravity * delta
	#get_input()
#	velocity = move_and_slide(velocity, Vector2(0, -1))
#	move_and_slide(velocity,Vector2(0, -1))
#	print('velocity = ', velocity)
	var spin_rate = 4 # larger number spins faster
	var pi = 3.14159
	move_and_slide(velocity)
#	var collision = move_and_collide(velocity * delta) # multiply by delta for move_and_collide, not move_and_slide
#	if collision:
#		print(collision.collider.name)
#		if collision.collider.name == 'test': # collided with the clef
#			# delete the note
#			pass
#			# lose a life
			
#		if state == 'incorrect':
#			state = 'hit'
#			velocity = hit_velocity
#		elif state == 'attack':
#			state = 'post_attack'
#			velocity = Vector2(0,int(-attack_speed/10*scale_factor))
##			velocity = Vector2(0,0)
#			rotation = 0
#		#print("I collided with ", collision.collider.name)
#	elif state == 'hit':
#		rotation += pi*delta*spin_rate

func _input_event(object, event, idx):
	# if the user selects the object
	var mouse_click = event as InputEventMouseButton
	var touch_screen = event as InputEventScreenTouch

	if mouse_click and mouse_click.button_index == 1:
		if mouse_click.pressed:
			handle_click()
			 #play_note()
		else:
			pass #stop_play_note()
#	elif touch_screen:
#		if touch_screen.pressed:
#			handle_click() #print('clicked ',notename) #play_note()
#		else:
#			pass #stop_play_note()
			
func handle_click():
	print('clicked ',notename)
	emit_signal("clicked", self)
	
func highlight():
	$NoteImage.modulate = mod_color
#	$HighlightedNote.visible = true
	
func unhighlight():
	$NoteImage.modulate = no_mod_color
#	$HighlightedNote.visible = false
