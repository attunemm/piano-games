extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# constants for the different types of game play
const NATURAL = 0 # only practice natural (white) keys
const SHARP = 1 # only practice sharp notes
const FLAT = 2 # only practice flat notes
const ALL = 3 # practice a random mix of natural, sharp and flat notes
const USER_SELECT = 4 # let the user toggle between natural, sharp, flat and all as desired
var mode = USER_SELECT #ALL #FLAT #SHARP #NATURAL # change this to set what type of notes are practiced
var octave
var player
var defender 
var score = 0
var streak = 0 # keep track of the # of correct selections in a row
var score_increment = 10
var screenWidth = ProjectSettings.get_setting("display/window/size/width")
var screenHeight = ProjectSettings.get_setting("display/window/size/height")
var max_x_offset = screenWidth*2/5 # can move up to 6 keys right out of 15 keys displayed at a time
var scale_factor = screenHeight/504 #2 # original numbers were all based on 896x504 pixel window
var oct_scale = 0.585 # * scale_factor # scale to fit 2 octaves on the screen
var octave_y_offset = 100 * scale_factor
var octave_x_offset = 0
var white_notes = ['A','B','C','D','E','F','G']
var sharp_notes = ['A_sharp','B_sharp','C_sharp','D_sharp','E_sharp','F_sharp','G_sharp']
var flat_notes = ['A_flat','B_flat','C_flat','D_flat','E_flat','F_flat','G_flat']
var all_notes = white_notes + sharp_notes + flat_notes
var notes # keep track of the notes currently in use
var is_running = false
var speed_up_by = 5 * scale_factor # controls how many pixels to increase the player fall speed by when they select the right key
var color_mode_sel = 7 # default to seven colors
var nlives_remaining # track how many lives are left
var nlives_initial = 7 # initial number of lives
var off_screen_pixels = 500 # number of pixels to ensure a play is offscreen - could make this a calculation
var move_octave = false
#var can_select_key = true # controls whether the user can select a key (one key at a time)
#var sel_key = ''

export (PackedScene) var Keyboard # link to an Octave scene reference
export (PackedScene) var Players # link to a PlayerSprite scene reference
export (PackedScene) var SettingsControl # link to a Settings scene reference
export (PackedScene) var OptionsGrp # link to a ButtonWithIcon scene reference
var set_panel # a SettingsControl instance

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(true)
	# based on the mode, set the radiobuttons and hide options
#	$HUD.hide_settings()
	var instructions = 'Select the correct key before the player falls off the screen.'
	var inset
#	TODO: replace set_mode_selected with updated code with setting panel
	if mode == NATURAL:
#		$HUD.set_mode_selected('white')
		inset = '- Natural Notes'
#		notes = white_notes
	elif mode == SHARP:
#		$HUD.set_mode_selected('sharps')
		inset = '- Sharp Notes'
#		notes = sharp_notes
	elif mode == FLAT:
#		$HUD.set_mode_selected('flats')
		inset = '- Flat Notes'
#		notes = flat_notes
	elif mode == ALL:
#		$HUD.set_mode_selected('all')
		inset = '- All Notes'
#		notes = all_notes
	elif mode == USER_SELECT:
		inset = ''#(adjust settings below)'
#		$HUD.show_settings()
	$HUD.display_instructions(instructions) # % inset)
	
	# connect to the signal emitted by the start button
	$HUD.connect('start_stop',self,'start_game')
#	$HUD/ScoreBox/VBoxContainer/StartButton.connect('button_up', self, 'start_game')
#	$HUD/KeyOptionsBox/HBoxContainer/StartButton.connect('button_up', self, 'start_game')

	# load the settings
	set_panel = SettingsControl.instance()
	# create the settings groups
	var og1 = OptionsGrp.instance()
	og1.init('Notes:',['Natural','Sharp','Flat','All'],50,'All')
	var og2 = OptionsGrp.instance()
	og2.init('Colors:',['7','2'],50,'7')
	var og3 = OptionsGrp.instance()
	og3.init('Keyboard:',['Fixed','Moving'],50,'Fixed')
	set_panel.add_setting(og1)
	set_panel.add_setting(og2)
	set_panel.add_setting(og3)
	add_child(set_panel)
	
	# listen for changed signal
	og1.connect("selection_changed", self, "change_notes",[og1])
	og2.connect("selection_changed", self, "change_color",[og2])
	og3.connect("selection_changed", self, "change_keyboard",[og3])
	change_notes(og1)
	change_color(og2)
	change_keyboard(og3)
	
	# load the octave
	octave = Keyboard.instance()
#	octave.set_scale_factor(scale_factor)
	octave.init(3) # 3 octaves
	octave.set_scale(Vector2(oct_scale,oct_scale))
	octave.set_position(Vector2(octave_x_offset,octave_y_offset))
#	var oct_ext = octave.get_extents()
#	print('octave size: ', oct_ext)
	#octave.connect("keysel", self, "set_sel_key")
	add_child(octave)
	
	# listen to the octave keysel signal
	octave.connect("key_selected", self, "compare_key_to_player")
	# determine the size of the octave
	var oct_pixels = octave.get_pixels()
#	print('oct_pixels = ', oct_pixels)

	#locate the settings panel based on the size of the octave
	
	set_panel.position.y = screenHeight - set_panel.get_height() #oct_pixels.y
	
	# set the size of the players to be 1/4 as tall as the white key
	var player_height = oct_pixels[1]/2 * oct_scale * scale_factor
#	print('player height =', player_height)
	# create the player that tells which note to tap
	player = Players.instance()
	player.set_height(player_height)
	var collision_scale_factor = 0.33 # needs to be <0.5 so players don't collide before they touch
	player.set_coll_factor(collision_scale_factor) 
	# place off screen
	player.position.x = 0
	player.position.y = -off_screen_pixels
	add_child(player)
	# create the defender to defend the key if the wrong note is tapped
	defender = Players.instance()
	defender.set_height(player_height)
	defender.set_coll_factor(collision_scale_factor)
	# place off screen
	defender.position.x = 0
	defender.position.y = -off_screen_pixels
	
	player.velocity = Vector2(0,0)
	defender.velocity = Vector2(0,0)
	add_child(defender)
	
	# load the HUD
	$HUD.show()
#	$HUD.show_message("Go!")

func stop_game():
	is_running = false
	player.visible = false
	defender.visible = false
	# stop game and display the options
#	if mode == USER_SELECT:
#		$HUD.show_settings()
#	# change text to Start
#	$HUD/ScoreBox/VBoxContainer/StartButton.set_text('Start')
	# hide the player and defender
	player.state = 'unset'
	player.velocity = Vector2(0,0)
	player.position = (Vector2(100,-off_screen_pixels))
	defender.state = 'unset'
	defender.velocity = Vector2(0,0)
	defender.position = (Vector2(100,-off_screen_pixels))
	# reset the octave position
	octave.position.x = 0
	octave_x_offset = 0
	# reset the keys
	octave.reset_all_keys()
	
	# display game over / hide clef
	octave.visible = false
	var go_label = add_label('Game Over', Vector2(430,300),200, Color(0,0,1))
	yield(get_tree().create_timer(2), "timeout")
	go_label.queue_free()
	# show clef
	octave.visible = true
	
func add_label(txt,pos,sz,clr = Color(1,1,1),par=self):
	
	var label0 = Label.new()
	label0.text = txt
	var df = DynamicFont.new()
	df.font_data = load('res://Fonts/Roboto-Medium.ttf')
	label0.set("custom_fonts/font",df)
	label0.set("custom_colors/font_color",clr)
	label0.get("custom_fonts/font").set_size(sz)
	label0.rect_position.x = pos.x
	label0.rect_position.y = pos.y
	par.add_child(label0)
	return label0
func start_game():
	if is_running:
		# user hit "Stop"
		stop_game()
		octave.highlight_when_play(true)
#		
	else:
		player.visible = true
		defender.visible = true
		# hide the settings panel
		hide_settings()
		octave.highlight_when_play(false)
		# hide the instructions
		$HUD/InstructionsLabel.visible = false
		# start the game
		$HUD.reset_lives()
		is_running = true
		# hide the options box
#		$HUD/KeyOptionsBox.visible = false
		# change text to Stop
#		$HUD/ScoreBox/VBoxContainer/StartButton.set_text('Stop')
		# reset the score and player velocity
		score = 0
		$HUD.update_score(score)
		player.fall_speed = 20 * scale_factor
		# reset the lives
		nlives_remaining = nlives_initial
#		velocity = Vector2(0,player.fall_speed)
		# call the function to start the game
		level1()
		
func hide_settings():
	set_panel.hide_settings()

func show_settings():
	set_panel.show_settings()
	
func level1():

#	# if there is already a key selected, don't let them select another
#	if !octave.can_select_key:
#		print('could not select key')
	octave.can_select_key = true
#		return
		
	# might not need next 2 lines of code bc of !canselectkey test above
	# test to see if either player / defender is dancing or attacking; if so, skip
#	if !player.state.begins_with('unset') or !defender.state.begins_with('unset'):
#		print('player state: ', player.state)
#		print('defender state: ', defender.state)
#		return
		
	# reset the octave to all white and black and no selected key
	octave.selkey = ''
	octave.reset_all_keys()
	
	if nlives_remaining < 1:
		$HUD.stop() #start_stop_switch() # change button to "start"
		# let the user know the game is over
#		$HUD.show_message('Game Over')
		stop_game() # this will end the game
		# TODO: display settings menu
		return # stop code
		
	randomize() # reseed random number generator
	var min_speed = 2
	var max_speed = 10
#	var notes = ['A','B','C','D','E','F','G']
	
	# move the octave if this option is selected
#	var move_octave = $HUD.get_move_octave_setting()
	if move_octave:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var cur_offset = octave_x_offset
		octave_x_offset = rng.randi_range(-max_x_offset,0)
		# octave.position.x = octave_x_offset # use this to immediately move
		var dx
		if cur_offset > octave_x_offset:
			dx = -1
		else:
			dx = 1
		while abs(octave_x_offset - cur_offset) >1:
			cur_offset += dx
			octave.position.x = cur_offset
#			yield(get_tree().create_timer(0.001), "timeout")
#			print(cur_offset)
	
	yield(get_tree().create_timer(0.01), "timeout")	
#	var mode_sel = $HUD.get_mode_selected()
#	if mode_sel == 'white':
#		notes = white_notes
#	elif mode_sel == 'sharps':
#		notes = sharp_notes
#	elif mode_sel == 'flats':
#		notes = flat_notes
#	elif mode_sel == 'all':
#		notes = all_notes
	
#	color_mode_sel = $HUD.get_color_mode_selected()
	
	var numnotes = notes.size()
#	print('number of notes: ', numnotes)
	
	# randomly select a player
	player.switch_texture(notes[randi()%numnotes-1])
	player.state = 'unset'
	player.rotation = 0
	# Set the player's position 
	# pick a random x
	var player_size = player.get_sprite_size()
	var xrange = (int(screenWidth-player_size.x*2))
	var xpos = randi()%xrange
#	var xpos = randi_range(player_size.x,screenWidth-player_size.x)
	player.position = Vector2(xpos+player_size.x/2,player_size.y/2)
	player.velocity = Vector2(0,player.fall_speed)
	defender.position = Vector2(-500,-off_screen_pixels) # off screen
	defender.velocity = Vector2(0,0)
	defender.state = 'unset'
	# Add some randomness to the direction.
	#direction += rand_range(-PI / 4, PI / 4)
	#mob.rotation = direction
	# Set the velocity (speed & direction).
	#player.linear_velocity = Vector2(rand_range(min_speed, max_speed), 0)
	#player.linear_velocity = player.linear_velocity.rotated(direction)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta): #_physics_process(delta): # trying _physics_process instead of _process to see if it fixes jitter
	if is_running:
		var psize = player.get_sprite_size()
		if player.position.y + psize.y < 0: # above the screen 
			# handle this in the next if statement that lets the defender dance
			pass #level1()
		elif player.position.x - psize.x >= screenWidth or player.position.x + psize.x < 0:
			level1()
		elif player.position.y - psize.y/2 >= screenHeight: # below the screen - did not touch a key in time
			# stop the player and reset its position to be above
			player.velocity = Vector2(0,0)
			player.position.y = -off_screen_pixels
			# show correct key
			highlight_correct_keys()
			yield(get_tree().create_timer(1.8), "timeout")
			#play sound (maybe this is in lose life)?
			lose_life()
			if is_running:
				level1()
			
		if typeof(octave.selkey) == TYPE_OBJECT:
			var key_pt =  oct_scale * octave.get_snap_point() + Vector2(octave_x_offset, octave_y_offset)
			# if the defender hit the player, stop the defender on the key and dance
			if defender.state == 'post_attack' and defender.position.y < key_pt.y: # stop and dance
				defender.velocity = Vector2(0,0)
				defender.state = 'dance_right' # TODO: call fn to pause and have defender dance
				yield(get_tree().create_timer(1.5), "timeout")
				defender.state = 'unset'
				yield(get_tree().create_timer(0.2), "timeout")
				defender.rotation = 0
				defender.position.y = -off_screen_pixels
				if is_running:
					level1()
				
			
func lose_life():
	nlives_remaining -= 1
	streak = 0
	$HUD.lose_life()
#	octave.can_select_key = true
#	player.state = 'unset'
#	defender.state = 'unset'
#	level1()
	
func change_notes(butgrp):
	var mode_sel = butgrp.sel_text #get_mode_selected()
	if mode_sel == 'Natural':
		notes = white_notes
	elif mode_sel == 'Sharp':
		notes = sharp_notes
	elif mode_sel == 'Flat':
		notes = flat_notes
	elif mode_sel == 'All':
		notes = all_notes
	
#	color_mode_sel = $HUD.get_color_mode_selected()
#
#	var numnotes = notes.size()
#	print('number of notes: ', numnotes)
	

#func _input(event):
func compare_key_to_player():
#	print('connection worked')
	if is_running:
		# change the octave setting to not allow key selection 
		# will change this back after correct key selected or lose_life()
		octave.can_select_key = false
#		print('is running')
		
	# Mouse in viewport coordinates
		if typeof( octave.selkey) == TYPE_OBJECT:
#			octave.allow_key_selection(false)
#			print('made it here')
#			pass
#		else:
#			var mouse_click = event as InputEventMouseButton
#			if mouse_click and mouse_click.button_index == 1 and !mouse_click.pressed:
			
#			player.position.y = octave.get_snap_point() # .selkey.SnapToPoint.position.y #event.position.y
			
			# determine if the correct key was clicked
			# first check if this note was previously selected - if so, do nothing
			if !octave.selkey.is_highlighted(): # TODO: delete this if? think it is handled by can_select_key get_color() == octave.selkey.orig_color:
			# check if can select a key?
					# stop the player from moving
				player.velocity[0] = 0
				player.velocity[1] = 0 
				player.rotation = 0
				# place the player on the clicked key
				player.position = oct_scale * octave.get_snap_point() + Vector2(octave_x_offset, octave_y_offset)#selkey.SnapToPoint.position.x #event.position.x
				# if correct, play "ding", do a little dance and increase the score
				if octave.selkey.note == player.notename or octave.selkey.other_name(octave.selkey.note) == player.notename:
	#				print('correct')
					streak += 1
					if color_mode_sel == 7:
						octave.selkey.highlight(player.notename)#(true)
					elif color_mode_sel == 2:
						octave.selkey.highlight('correct')
#					octave.selkey.play_note(true)
					player.state = 'correct'
					player.rotation = 0
					score += score_increment
					$HUD.update_score(score)
	#					$HUD.show()
	#					$HUD.show_message('+10')
					player.show_label('+10')
					# increase the fall speed
					player.fall_speed += speed_up_by
				
					player.state = 'dance_right'
					# pause, then re-call level1
					yield(get_tree().create_timer(1.5), "timeout")
					if streak > 0 and streak % 5 == 0:
						score += streak
						$HUD/StreakLabel.set_text('Streak bonus: \n'+ str(streak) + ' points!!')
						$HUD/StreakLabel.visible = true
						$HUD.update_score(score)
						yield(get_tree().create_timer(1.5), "timeout")
						$HUD/StreakLabel.visible = false
					player.hide_label()
					player.state = 'unset'
	#					octave.selkey.reset_color()
					octave.can_select_key = true
					level1()
	#					octave.selkey = ''
		
				else:
					# if no, play uh-uh music and have the correct player kick the wrong player off the key
					# move way off screen to ensure no collision as changing 
					
					player.state = 'incorrect'
					defender.state = 'attack'
					var dsize = defender.get_sprite_size()
					defender.position.y = screenHeight + dsize.y
					var new_texture = octave.selkey.note
					if '_flat' in player.notename: # knock a flat off with a flat, not a sharp
						var key_alt_name = octave.selkey.other_name(octave.selkey.note)
						if '_flat' in key_alt_name:
							new_texture = key_alt_name #defender.switch_texture(key_alt_name)
					if '_sharp' in player.notename: # knock off sharps with sharps
						var key_alt_name = octave.selkey.other_name(octave.selkey.note)
						if '_sharp' in key_alt_name:
							new_texture = key_alt_name #defender.switch_texture(key_alt_name)
	#					else:
					highlight_correct_keys()
							
					if color_mode_sel == 7:
						octave.selkey.highlight(new_texture)#(true)
						# highlight correct key
					elif color_mode_sel == 2:
						octave.selkey.highlight('incorrect')
#					octave.selkey.highlight(new_texture)
#					octave.selkey.play_note(false)
					defender.switch_texture(new_texture)
						
					# start the defender from below the selected key
					defender.position.x = player.position.x
					var sprite_size = defender.get_sprite_size()
					defender.position.y = screenHeight + sprite_size.y/2
					# move the defender to knock the player of his key
	#					var nsteps = 50
					var dx = (player.position.x - defender.position.x) 
					var dy = (player.position.y - defender.position.y) 
					var dir = Vector2(dx,dy).normalized()
					defender.velocity[0] = dir.x * defender.attack_speed * scale_factor
					defender.velocity[1] = dir.y * defender.attack_speed * scale_factor
					
					# lose a life (and reset the streak)
					lose_life()
					
	#					for i in range(nsteps):
	#						defender.position.x += dx
	#						defender.position.y += dy
	#						yield(get_tree().create_timer(0.2), "timeout") # pause
#					print('incorrect')
	#					octave.selkey.reset_color()
#			octave.selkey = '' # reset so they can't click outside the keyboard?
#		octave.can_select_key = true
	else: 
		pass
		# not running; just highlight the note - this is handled in the key
#		var keyref = octave.selkey
##		keyref.play_note(true)
#		keyref.highlight(keyref.note)
#		yield(get_tree().create_timer(0.5), "timeout")
#		keyref.reset_color()
				# call level1() to try again with a new player
		#print("Mouse Click at: ", event.position)
func highlight_correct_keys():
	# loop over keys to find and highlight the correct notes
	for bk in octave.bkeys:
		if bk.note == player.notename or bk.other_name(bk.note) == player.notename:
			if color_mode_sel == 7:
				bk.highlight(player.notename)
			else:
				bk.highlight('correct')

	for wk in octave.wkeys:
		if wk.note == player.notename or wk.other_name(wk.note) == player.notename:
			if color_mode_sel == 7:
				wk.highlight(player.notename)
			else:
				wk.highlight('correct')
				
func change_keyboard(butgrp):
	if butgrp.sel_text == 'Moving':
		move_octave = true
	else:
		move_octave = false
	
func change_color(butgrp):
	if butgrp.sel_text == '7':
		color_mode_sel = 7
	else:
		color_mode_sel = 2
