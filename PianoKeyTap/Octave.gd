extends Polygon2D
signal key_selected()

var screenHeight = ProjectSettings.get_setting("display/window/size/height")
var scale_factor = screenHeight/504 #01 # 1 for 896x504 just adjust the scale of the object
const NOTES = ['C','D','E','F','G','A','B']
#const BLK_OFFSETS = [70, 194, 400, 518, 635]
const BLK_OFFSETS = [70, 124, 206, 118, 117] 
const SHARPS = ['C_sharp', 'D_sharp', 'F_sharp', 'G_sharp', 'A_sharp']
const FLATS = ['D_flat', 'E_flat', 'G_flat', 'A_flat', 'B_flat']

# Declare member variables here. Examples:
var y = 0
var x0 = 0
var xw = x0 # x loc of white keys
var xb = xw #+ 76 # x loc of black keys
var wkeys = Array()
var bkeys = Array()
var white_x_offset = round(110 * scale_factor)
var black_x_offset = round(25 * scale_factor) + white_x_offset
var nwkeys = 7
var nbkeys = 5
var noctaves = 3
var selkey = '' # hold a pointer to the selected Key
var can_select_key = true # set to false to not allow a change in key selected

# var b = "text"
export (PackedScene) var BlackKey
export (PackedScene) var WhiteKey
#export (PackedScene) var KeyWhite
#export (PackedScene) var KeyBlack

func set_scale_factor(sf):
	scale_factor = sf

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(numoctaves):
	noctaves = numoctaves
#	wkeys.resize(nwkeys)
	# find index of middle octave
	var mid_oct = int(noctaves/2) # truncates, so if only 1 octave, gives first index (0)
#	print('middle octave index: ', mid_oct)
	var oct_dif = 0
	var pitch_scale = 1.0
	var wk
	var bk
	# loop over the number of octaves
	for oct in range(noctaves):
		# set the pitch scale, with the middle octave being 1
		oct_dif = oct - mid_oct
#		print('oct_dif = ', oct_dif)
		if oct_dif == 0:
			pitch_scale = 1
		elif oct_dif < 0: # divide by factors of 2
			pitch_scale = 1.0/(2.0*abs(oct_dif))
		else: # multiply by factors of 2
			pitch_scale = 2*oct_dif
#		print('pitch_scale = ', pitch_scale)
		# multiply/divide by factors of 2 as you move away from middle
		# Create a white key instances and add to the scene.
		for i in range(nwkeys):
			wk = WhiteKey.instance()
			#wkeys[i] = KeyWhite.instance()
			wk.init(self.NOTES[i])
			#wkeys[i].note = self.NOTES[i]
			wk.connect("clicked", self, "play_key")
			wk.set_pitch_scale(pitch_scale)
			add_child(wk)
			wkeys.append(wk)
	
			# Set the key's position to 
			wk.position = Vector2(round(xw),y)
			xw += round(white_x_offset)

#		bkeys.resize(nbkeys)
		
		#x = x0 #black_x_offset
		for i in range(nbkeys):
			bk = BlackKey.instance()
			bk.init(self.SHARPS[i])
			#bkeys[i] = KeyWhite.instance()
			#bkeys[i].note = self.SHARPS[i]
			bk.connect("clicked", self, "play_key")
			bk.set_pitch_scale(pitch_scale)
			add_child(bk)
			bkeys.append(bk)
			# Set the key's position to 
			xb += BLK_OFFSETS[i] * scale_factor
			bk.position = Vector2(xb ,y)
		xb += black_x_offset
#			x += white_x_offset
#			if i == 1: # change to 2 to have group of 3 on left
#				x += white_x_offset # extra gap to create group of 2 black keys
# Called every frame. 'delta' is the elapsed time since the previous frame.

#func _process(delta):
#	pass

func play_key(key):
#	print('play key fn')
#	print(key.note, " clicked")
#	print(" ")
	if can_select_key:
		selkey = key
		emit_signal("key_selected")
		# play the audio file with this note
	# this is handled by the key
	
func allow_key_selection(tf):
	can_select_key = tf
	
func get_pixels():
	var white_key_size = wkeys[0].get_size()
	return white_key_size

func reset_all_keys():
	for wk in wkeys:
		wk.reset_color()
	for bk in bkeys:
		bk.reset_color()
	can_select_key = true
		
func get_snap_point():
	if typeof(selkey) == TYPE_OBJECT:
		return selkey.get_position()

func highlight_when_play(tf):
	# loop over keys to set highlight when play
	for bk in bkeys:
		bk.highlight_when_play = tf
	for wk in wkeys:
		wk.highlight_when_play = tf
