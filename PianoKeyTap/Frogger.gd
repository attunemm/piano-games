extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var note_bg
var playing = false # set to false to stop the game
var clef_x_offset = 150 # control the location of the clef on the screen
var clef_y_offset = 120
var clef_scale = 2.5 # make the clef larger
var perc_offset_add_note = 0.8# percent of the way across the clef to add a note
var player_y_offset # control up-down location of players
var settings_panel
# variables to hold the sub-scenes
var clef
var clef_new_width
var result_notes = Array() # hold pointers to the notes displaying results - so they can be deleted
export (PackedScene) var Staff
export (PackedScene) var Player # PlayerSprite.tscn
export (PackedScene) var Note # Note.tscn
export (PackedScene) var Btn # ButtonWithIcon.tscn
export (PackedScene) var SettingsControl
export (PackedScene) var HUD
var notes = ['C','D','E','F','G','A','B']
var numnotes = notes.size()
var sel_player # store the handle to the selected player sprite
var sel_note # store the handle to the selected note
var sel_note_idx # the index of sel_note within notes_array
var notes_array = Array() # holds an array of handles for all of the note objects
var players = Array() # holds an array of handles for all the player objects
var note_starting_x # x location to start the notes at
var notes_velocity0 = 30# initial velocity of the notes; will speed up with correct selections
var notes_velocity = notes_velocity0 # initially set to notes_velocity0 increases with correct selection
var x_to_add_new_note
var correct_sel_made = false # change this to true when the user selects the correct player
var first_try = true # change this to false if the user selects an incorrect player
var num_on_first_try = Array() # keep track of how many times the user gets it right on their first try TODO: make this an array the size of the number of notes
var num_of_times = Array() # keep track of the total number of times this note was the selected note
var lives = Array() # array of notes objects that displays how many lives are remaining
# labels for the % correct lines
var lbl0
var lbl50
var lbl100
#start_stop game button
var play_game_button
#var lbl_score
var score = 0 # store the score
var num_pts
#var pg_label # handle to the label displaying "Play Game" or "stop game"
var lives_remaining = Array() # holds pointers to lives in the lives Array - remove as die
# handles to the radio buttons for user selected options
var but_treble # select for treble clef
var but_bass # select for bass clef
var but_high # select for only high notes on clef (treble C to high C or bass C to middle C)
var but_low # select for only low notes on clef (middle C to treble C or low C to bass C)
var but_staff # select for only notes on the staff
var but_leger # select for only notes above or below the staff
var but_all # select for all notes (bass A to high D or Low A to middle F)
var but_lines # select for only notes that are on a line
var but_spaces # select for only notes that are not on a line
var but_allnotes # select for all notes, lines adn spaces
var region_bg
var clef_bg
var lbl_instructions
var dynamic_font = DynamicFont.new()
var arrow_rt
var arrow_lt
var set_panel # instance of the settings panel
var hud # instance of the HUD scene
#print(numnotes)
#var selected_texture=load("res://Icons/FilledSquareBlue.svg")
#var unsel_texture = load('res://Icons/OpenSquareBlue.svg')
#var selected_texture=load("res://Icons/FilledCircleGreenSmall.png")
#var unsel_texture = load('res://Icons/UnfilledCircleGreenSmall.png')
var selected_texture=load("res://Icons/HatWhiteFilled.png")
var unsel_texture = load('res://Icons/HatWhiteUnfilled.png')
var note_option_sel # string to track which option is selected
var region_option_sel # string to track which option is selected


# Called when the node enters the scene tree for the first time.
func _ready():
	# add HUD
	hud = HUD.instance()
	# hide the lives that look like players - will add note lives
	hud.hide_lives()
	add_child(hud)
	# listen for play/stop and back signals
	hud.connect("start_stop",self,'play_stop')
#	hud.connect("go_back",self,'go_to_main_menu') # this is now in HUD
	# connect the settings expand/collapse button to code
#	$ExpandCollapse.connect("pressed", self, 'show_hide_settings')
#	arrow_rt = load('res://Icons/RightBlack.svg')
#	arrow_lt = load('res://Icons/LeftBlack.svg')
	dynamic_font.font_data = load("res://Fonts/Roboto-Medium.ttf")
	# load the clef
	clef = Staff.instance()
#	octave.set_scale_factor(scale_factor)
	clef.set_type('treble')
#	clef.set_type('bass')
	clef.set_position(Vector2(clef_x_offset,clef_y_offset))
	clef.set_scale(Vector2(clef_scale,clef_scale))
	# figure out the new clef width to height ratio to fill the screen
	clef_new_width = ProjectSettings.get_setting("display/window/size/width") - 2*clef_x_offset
	var wtoh = clef_new_width / clef.get_height() / clef_scale 
	print('new width to height = ', wtoh)
	clef.change_width(wtoh)
	# find the x location to place the players
	note_starting_x = clef.get_width()*0.9 # clef.position.x + clef.get_width()*0.9*clef.scale.x
	# calculate the player y offset
	player_y_offset = clef.get_height() * clef_scale + clef_y_offset
	var player_spacing_x = clef.get_width() * clef_scale / 7.5
	# place the %ile vertical lines for displaying accuracy results when game is over
	var x0 = clef.get_collision_x_bound()
	var clef_x_range = clef.get_width() - x0*2 # clef_width - x0
	print('x0 = ', x0)
	print('clef_x_range = ', clef_x_range)
	# place lines at 0 and 50 %
	var x50 = x0+clef_x_range/2
	var x100 = x0+clef_x_range
	clef.set_0perc_line_x(x0)
	clef.set_50perc_line_x(x50)
	clef.set_100perc_line_x(x100)
#	clef.hide_perc_lines()
	add_child(clef)
	# connect the clef signal to a listening function
	clef.connect("object_entered_clef", self, 'note_reached_end')
	# add labels at 0%, 50%, 100% lines on clef
	
#	lbl_instructions = add_label('Select the correct player before the note slides off the staff.',Vector2(clef_x_offset,50),50)
	hud.display_instructions('Select the correct player before the note reaches the clef mark.')
	var fontsz = 50
	lbl0 = add_label('0%',Vector2(x0*clef_scale + clef_x_offset,clef_y_offset - fontsz),fontsz)
	lbl50 = add_label('50%',Vector2(x50*clef_scale + clef_x_offset,clef_y_offset - fontsz),fontsz)
	lbl100 = add_label('100%',Vector2(x100*clef_scale + clef_x_offset,clef_y_offset - fontsz),fontsz)
	clear_results()
	
	# create the players
	var player
	var x_1stplayer
	#	var px = clef_x_offset
	var dx = clef_x_offset
	var player_scale = 30
	var sprite_size
	for p in range(numnotes):
		player = Player.instance()
		add_child(player)
		player.switch_texture(notes[p])
#		player.modulate = Color(1,1,1,.5) # start grayed out
		sprite_size = player.get_sprite_size()
#		print('sprite size  = ', sprite_size.x, ' ', sprite_size.y)
		if p == 0: #loopct == 0:
			dx += sprite_size.x * player_scale
			x_1stplayer = dx
		player.visible = true
		player.connect("clicked", self, "set_sel_player")
		players.append(player)
		# set player position and velocity
		player.position = Vector2(dx,player_y_offset+sprite_size.y * player_scale/2+5)
		player.scale = Vector2(player_scale,player_scale)
		player.velocity = Vector2(0,0)
		dx += player_spacing_x
#		dx += sprite_size.x * player_scale + 10

	# add user controlled options
	clef_bg = Btn.instance() #ButtonGroup.new()
	# treble or bass clef
	clef_bg.init('Clef:',['Treble','Bass'],fontsz,'Treble') #init(['Opt 1','Opt 2', 'Opt 3'], 50, true)
	
	region_bg = Btn.instance() #ButtonGroup.new()
	region_bg.init('Region:',['Staff','Leger','All'],fontsz,'All') #init(['Opt 1','Opt 2', 'Opt 3'], 50, true)
	
	note_bg = Btn.instance() #ButtonGroup.new()
	note_bg.init('Notes:',['Lines','Spaces','All'],fontsz,'All') #init(['Opt 1','Opt 2', 'Opt 3'], 50, true)
	
	# listen for changed signal
	clef_bg.connect("selection_changed", self, "change_clef",[clef_bg])
	region_bg.connect("selection_changed", self, "change_notes",[region_bg])
	note_bg.connect("selection_changed", self, "change_notes",[note_bg])
	
	# add the buttons to hbox and vbox containers
	var clefbox = VBoxContainer.new() #HBoxContainer.new()
	var regionbox = VBoxContainer.new() #HBoxContainer.new()
	var notesbox = VBoxContainer.new() #HBoxContainer.new()
	var settingsbox = HBoxContainer.new()
	
#	fontsz = 50
#	# Clef options
#	add_label('Clef:            ',Vector2(0,0),fontsz, Color(1,1,1),clefbox)
#	clefbox.add_child(but_treble)
#	clefbox.add_child(but_bass)
#	add_label(' ',Vector2(0,0),fontsz, Color(1,1,1),clefbox)
#
#	# Region Options
#	add_label('Region:       ',Vector2(0,0),fontsz, Color(1,1,1),regionbox)
##	regionbox.add_child(clef_lbl)
##	regionbox.add_child(but_high)
##	regionbox.add_child(but_low)
#	regionbox.add_child(but_staff)
#	regionbox.add_child(but_leger)
#	regionbox.add_child(but_all)
#
#	# Note options
#	add_label('Notes:       ',Vector2(0,0),fontsz, Color(1,1,1),notesbox)
#	notesbox.add_child(but_lines)
#	notesbox.add_child(but_spaces)
#	notesbox.add_child(but_allnotes)
	
#	settingsbox.add_child(clefbox)
#	settingsbox.add_spacer(true)
#	settingsbox.add_spacer(true)
#	settingsbox.add_child(regionbox)
#	settingsbox.add_spacer(true)
#	settingsbox.add_child(notesbox)
#	var pn = PanelContainer.new()
#	pn.add_child(clef_bg)
#	settingsbox.add_child(pn)
#	settingsbox.add_child(clef_bg)
#	var sz = clef_bg.get_scene_size() #clef_bg.get_vbox_size()
##	settingsbox.add_spacer(true)
##	settingsbox.add_spacer(true)
#	settingsbox.add_child(region_bg)
#	var delta = 50
#	var xn = sz.x + delta
#	region_bg.position.x = sz.x 
#	sz = region_bg.get_scene_size() #get_vbox_size()
##	settingsbox.add_spacer(true)
#	settingsbox.add_child(note_bg)
#	note_bg.position.x = xn + sz.x + delta
	
#	settings_panel = Polygon2D.new() #PanelContainer.new()
	set_panel = SettingsControl.instance()
	# connect to callback
	set_panel.connect("show_hide", self, 'show_hide_settings')
	var pg_pts = set_panel.get_polygon_pts() #$SettingsPanel.polygon
#	var xpanel = clef_x_offset
#	var y
#	for i in range(4):
#		for j in range(2):
#			pg_pts.append()
	var sp_x0 = clef_x_offset
	var sp_x1 = clef_x_offset + clef.get_width()*clef_scale # TODO: offset by clef width
	var sp_y0 = clef_y_offset + clef.get_height()*clef_scale # TODO: offset by clef height
	var sp_y1 = sp_y0 + 600
	set_panel.position.y = sp_y0
	if 0:
		pg_pts[0][0] = sp_x0
		pg_pts[0][1] = sp_y0
	
		pg_pts[1][0] = sp_x0
		pg_pts[1][1] = sp_y1
	
		pg_pts[2][0] = sp_x1
		pg_pts[2][1] = sp_y1
	
		pg_pts[3][0] = sp_x1
		pg_pts[3][1] = sp_y0
		print('pg_pts = ', pg_pts)
		set_panel.set_polygon_pts(pg_pts) #$SettingsPanel.polygon = pg_pts
#	$CanvasLayer.add_child(settings_panel)
#	$SettingsPanel.add_child(settingsbox)
#	settings_panel.add_child(settingsbox)

	set_panel.add_setting(clef_bg) #$SettingsPanel.add_child(clef_bg)
#	var sz = clef_bg.get_scene_size() #clef_bg.get_vbox_size()
#	var delta = 50
#	var xdelta = 100
#	var xn = sp_x0 + xdelta
#	clef_bg.position.x = xn
#	clef_bg.position.y = delta #sp_y0 + delta
##	settingsbox.add_spacer(true)
##	settingsbox.add_spacer(true)
	set_panel.add_setting(region_bg) #$SettingsPanel.add_child(region_bg)
#	xn = sz.x + xn + xdelta
#	region_bg.position.x = xn
#	region_bg.position.y = delta #sp_y0 + delta
#	sz = region_bg.get_scene_size() #get_vbox_size()
##	$SettingsPanel.add_spacer(true)
	set_panel.add_setting(note_bg) #$SettingsPanel.add_child(note_bg)
#	note_bg.position.x = xn + sz.x + xdelta
#	note_bg.position.y = delta #sp_y0 + delta
	
	add_child(set_panel)

	# get the vbox size, to help position the panel
#	var vbox_size = settingsbox.rect_size
#	settings_panel.rect_position = Vector2(clef_x_offset,clef_y_offset+clef.get_height()*clef_scale)
#	vbox.position = Vector2(20,100)
#	# add the start-stop game button
#	play_game_button = Button.new()
#	dynamic_font.font_data = load("res://Fonts/Roboto-Medium.ttf")
#	play_game_button.set("custom_fonts/font",dynamic_font)
#	play_game_button.set("custom_colors/font_color",Color(1,1,1))
#	play_game_button.get("custom_fonts/font").set_size(fontsz+5)
##	play_game_button.text = 'Play'
	var lbl_dx = 10
	var lbl_y = player.position.y
#	pg_label = add_label('Play\nGame',Vector2(lbl_dx,0),fontsz,Color(1,1,1),play_game_button)
#	pg_label.align = Label.ALIGN_CENTER
#	add_child(play_game_button)
#	var but_size = play_game_button.get_size() #rect_size.x # = (Vector2(but_width,20))
#	var pg_size = pg_label.rect_size
##	play_game_button.rect_position = (Vector2(x_1stplayer/2-but_size.x/1.2,lbl_y+but_size.y))
#	play_game_button.set_size(pg_size+Vector2(2*lbl_dx,0))
#	but_size = play_game_button.get_size()
#	#lbl_y -= pg_size.y/2 # place higher on screen
##	play_game_button.rect_position = (Vector2(x_1stplayer/2-pg_size.x,lbl_y))
#	play_game_button.rect_position = (Vector2(ProjectSettings.get_setting("display/window/size/width") - but_size.x - 20,20))
#	# connect the button mouse pressed signal to a callback function
#	play_game_button.connect("pressed", self, 'play_stop')
	
	# add the score label
	var lbl_x = player.position.x + player.get_sprite_size().x*player.scale.x/2
	var rt_margin = 20
#	lbl_y = lbl_y - player.get_sprite_size().y*player.scale.y/2
#	var lbl_s = add_label('Score:',Vector2(lbl_x+lbl_dx,lbl_y),fontsz-10,Color(1,1,1))
#	lbl_s.rect_size.x = ProjectSettings.get_setting("display/window/size/width")-lbl_x-lbl_dx-rt_margin
#	lbl_s.align = Label.ALIGN_RIGHT
#	lbl_score = add_label('0',Vector2(lbl_x+lbl_dx,lbl_y + fontsz + 10),fontsz+5,Color(1,1,1))
#	lbl_score.rect_size.x = ProjectSettings.get_setting("display/window/size/width")-lbl_x-lbl_dx-rt_margin
#	lbl_score.align = Label.ALIGN_RIGHT
#	lbl_score2.set_align(Label.ALIGN_RIGHT)

	
	# add notes to the bottom of the page to show how many lives remain
	var numlives = 14
	var life
	var lifex = clef_x_offset
	var lifey = ProjectSettings.get_setting("display/window/size/height") - 60
	var dxlife = clef_new_width / (numlives-1)
	var nnotes = notes.size()
	for n in range(numlives):
		life = Note.instance()
		life.scale = Vector2(0.3,0.3)
		life.position = Vector2(lifex,lifey)
		life.set_name(notes[n%nnotes])
		life.highlight()
		add_child(life)
		lives.append(life)
		lifex += dxlife
	# set the initial spacing between subsequent notes
	set_note_offset()
	clef.show_sel_notes(note_option_sel,region_option_sel)
#	# begin the game
#	level1()
	
func change_clef(bgrp):
	if bgrp.sel_text == 'Treble': #but_treble.pressed:
		clef.set_type('treble')
	else:
		clef.set_type('bass')
	clear_results()
	
func add_option(but_group,but_string,is_sel):
	var but_new = CheckBox.new()
	but_new.set_button_group(but_group) 
	but_new.text = but_string
	var but_font = DynamicFont.new()
	but_font.font_data = load("res://Fonts/Roboto-Medium.ttf")
	but_new.set("custom_fonts/font",but_font)
	but_new.set("custom_colors/font_color",Color(1,1,1))
	but_new.get("custom_fonts/font").set_size(32)
	but_new.pressed = is_sel
	return but_new
	
func play_stop():
	# called when user selects the play / stop button
	# set the playing variable and change the label name
#	lbl_instructions.visible = false
	hud.hide_instructions()
	clef.clear_settings_notes()
	if playing:
		end_game()
	else:
		playing = true
#		pg_label.text = 'Stop\nGame'
		# hide the settings
		show_hide_settings()
		level1()
	
# these are in show_hide_settings
#func hide_settings():
#	$SettingsPanel.visible = false
#	# make the arrow point left
#	$ExpandCollapse.texture = arrow_rt
#
#func show_settings():
#	$SettingsPanel.visible = true
#	# make the arrow point left
#	$ExpandCollapse.texture = arrow_lt
		
func clear_results():
	# hide % labels
	lbl0.visible = false
	lbl50.visible = false
	lbl100.visible = false
	# hide the lines
	clef.hide_perc_lines()
	
	# delete any results that were shown
	for r in result_notes:
		r.queue_free()
		
	# clear out notes array
	for n in notes_array:
		n.queue_free()

	# reset the results arrays
	result_notes.clear()
	notes_array.clear()
	num_of_times.clear()
	num_on_first_try.clear()
	# initialize arrays to the size of the number of notes
	for n in range(clef.notes_treble.size()):
		num_of_times.append(0) # TODO need to set this index, not append once array is first made
		num_on_first_try.append(0)
	
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
	
func update_score(new_score):
	hud.update_score(new_score)
#	lbl_score.text = str(new_score)
	score = new_score
	
func reset_lives():
	lives_remaining = lives.duplicate(true)
	for l in lives:
		l.highlight()
		l.modulate = Color(1,1,1,1)
		
func level1():
	if playing:
		# reset the note velocity
		notes_velocity = notes_velocity0
		
		# reset the lives
		reset_lives()
		
		# reset the score
		update_score(0)
		
		# clear out previous results
		clear_results()
		
		# hide settings
		set_panel.hide_settings()
		
		# randomly show a player - this is repeated code from Main.gd - should move elsewhere
		randomize() # reseed random number generator
	#	var min_speed = 2
	#	var max_speed = 10
		
#		var x = 0
		sel_note_idx = -1 # increment this to keep track of which note is selected
		# add note and set it as the selected note (the one for the user to match the player to)
		add_note()
		sel_next_note()
	

func note_reached_end(note_handle):
	if correct_sel_made: # selected the correct player just before this note went off the edge
		return
	else: # this note was never selected correctly
		first_try = false
		lose_life()
		reset_players()
		# pop this handle from the array
		if lives_remaining.size() > 0:
			var notetodel = notes_array.pop_front()
			notetodel.queue_free()
			sel_next_note()
	
func lose_life():
	if playing:
		var life_lost = lives_remaining.pop_front()
		if life_lost != null:
			life_lost.unhighlight()
			life_lost.modulate = Color(1,1,1,0.5)
		if lives_remaining.size() == 0:
			end_game()
		
func end_game():
	# set playing to false and change the button to say "Play Game"
#	play_stop()
	playing = false
	# change the stop button to play
	hud.stop()
#	pg_label.text = 'Play\nGame'
	
	# delete notes, reset players, stop all note creation
	reset_players()
	for n in notes_array:
		n.queue_free()
	notes_array.clear()
	
	# display game over / hide clef
	clef.visible = false
	var go_label = add_label('Game Over', Vector2(430,300),200, Color(0,0,1))
	yield(get_tree().create_timer(2), "timeout")
	go_label.queue_free()
	# show clef
	clef.visible = true
	# show statistics
	# loop over all of the notes tested
	# TODO: move this into a get function within Clef.gd
	var na
	var note_x
#	var clef_width = clef.get_width()
	if clef.clef_type == 'clef_treble':
		na = clef.notes_treble
	else:
		na = clef.notes_bass
	var note_inst
	var x0 = clef.get_0perc_line_x()
	var clef_x_range = clef.get_100perc_line_x() - x0 # clef_width - x0
	# show lines at 0 and 50 and 100 %
	clef.show_perc_lines()
	# show % labels
	lbl0.visible = true
	lbl50.visible = true
	lbl100.visible = true
	
	for ntid in range(na.size()):
		# add a note to the clef in an x-location that correspond to the % correct on the first try
		if num_of_times[ntid] > 0:
			var perc_first_try = float(num_on_first_try[ntid]) / float(num_of_times[ntid])
#			print('% first try: ', perc_first_try)
			note_x = float(num_on_first_try[ntid]) / float(num_of_times[ntid]) * clef_x_range + x0 
			note_inst = clef.add_note(ntid,note_x)#(clef.noteidcs[ntid],note_x)
			note_inst.highlight()
			note_inst.disable_collision() # make sure that overlapping notes don't bump each other out of position
			result_notes.append(note_inst)
	
func add_note():
	if playing:
		# randomly display a note, moving across the screen
#		var noteidcs = clef.get_sel_note_idcs()
#		print('noteidcs  = ', noteidcs)
#		var nnotes = noteidcs.size()
#		print('# notes = ', nnotes)
		var noteidx = randi()%clef.nnotes-1
		var note_inst = clef.add_note(clef.noteidcs[noteidx],note_starting_x) # pass in the x location of the note
		notes_array.append(note_inst)
		if notes_array.size() > 1: #!= sel_note_idx: # this note is not the one the user is identifying
			# gray out the note
			note_inst.modulate = Color(0,0,0,.5)
		
	#		note_inst.visible = true
		note_inst.idx = clef.noteidcs[noteidx] #noteidx # use this idx to keep track of counts for correct/incorrect selections
		note_inst.velocity = Vector2(-notes_velocity,0) # move to the right (increase speed as game goes on?)
	
	
func sel_next_note():
	# reset first_try and corr_sel
	first_try = true # the user can get this note right on the first try
	correct_sel_made = false # the user hasn't yet made the correct selection
	num_pts = 12 # reset number of points for getting it right on first try - will subtract for each miss
	# reset all the players
	reset_players()
	
	# set the next note, if one is displayed, to sel_note & show as black
#	print('note array size = ', notes_array.size())
#	sel_note_idx += 1
	if notes_array.size() == 0: #<= sel_note_idx: # add a new note if there isn't another note yet
		add_note()
#		sel_note = notes_array[notes_array.size()-1]
#		sel_note.modulate = Color(1,1,1,1) # make it black
#	elif notes_array.size() > sel_note_idx:
		
	sel_note = notes_array[0] #[sel_note_idx] # set as the selected note
	sel_note.modulate = Color(1,1,1,1) # make it black
	
	# add to the count of how many times this note was the active note
	num_of_times[sel_note.idx] += 1
#		add_note()
#		sel_note = notes_array[sel_note_idx]
#	else: # otherwise, create the next note and set as sel_note
#		add_note()
		

func set_sel_player(player_ref):
	# called when user clicks on a player
#	print('in_set_sel_player')
#	# gray out previously selected player
#	if is_instance_valid(sel_player) and typeof(sel_player) == TYPE_OBJECT:
#		sel_player.modulate = Color(1,1,1,0.5)
	# called when user clicks on a player
	sel_player = player_ref
#	# highlight
#	player_ref.modulate = Color(1,1,1,1)
	compare_selections()

func set_sel_note(note_ref):
#	print('in_set_sel_note')
	# called when user clicks on a player
	sel_note = note_ref
	sel_note.modulate = Color(0,0,0,0.7) # grayed out
	
	compare_selections()
	
func compare_selections():
#	print('in_compare_selections')
	# see if the selected note matches the selected player
	if is_instance_valid(sel_note) and is_instance_valid(sel_player) and typeof(sel_note) == TYPE_OBJECT and typeof(sel_player) == TYPE_OBJECT:
#		print(sel_note.notename)
#		print(sel_player.notename)
		if sel_note.notename == sel_player.notename:
			# match!
			correct_pairing()
		else:
			# wrong!
			incorrect_pairing()
		# clear out selections
#		sel_player.modulate = Color(1,1,1,.5) # grayed out
		
#		sel_note = ''
		sel_player = ''
	
func correct_pairing():
#	print('correct')
	correct_sel_made = true
	# highlight the note the correct color
	sel_note.disable_collision() # make it so this note can't collide with other objects
	sel_note.highlight()
	sel_note.modulate = Color(1,1,1,1) # not grayed out
	# show note name?
	
	# if this was the first selection for this note add 1 to the first_try_array for this note
	if first_try:
		num_on_first_try[sel_note.idx] += 1
		num_pts += 8 # bonus for getting it right
#	else:
#		update_score(score+5)
		
	update_score(score + num_pts)
	# increase note speed
	inc_note_speed()
	
	# player dance?
	sel_player.state = 'dance_right'
	# celebrate, then delete note
	var note_to_del = notes_array.pop_front() #sel_note # assign to temp variable, so another note can be selected
	sel_next_note() # reset everything and move on to the next note
	var prev_sel_player = sel_player # assign to temp variable, so another player can be selected
	yield(get_tree().create_timer(1), "timeout")
	if is_instance_valid(note_to_del): # != null: # was already deleted for reaching the end of its path
		note_to_del.queue_free()
	prev_sel_player.state = '' # player stop dance


func reset_players():
	# reset all players to not be grayed out
	for p in players:
		p.modulate = Color(1,1,1,1)
	
	
func set_note_offset():
		x_to_add_new_note = (clef.position.x + clef.get_width()*perc_offset_add_note*clef.scale.x - notes_velocity) # make the space between notes larger as notes_velocity increases
	
func inc_note_speed():
	notes_velocity += 2
	# space out notes more
	set_note_offset()
#	perc_offset_add_note = perc_offset_add_note * 0.99
	
	# TODO: loop over all of the notes, and update their x-velocity


func incorrect_pairing():
#	print('incorrect')
	# gray out the player
	sel_player.modulate = Color(1,1,1,.5)
	num_pts -= 2
	# set first_try to false, since the user can't get this correct on the first try any more
	if first_try:
		lose_life() # only lose a life on the first wrong selection
	first_try = false

func _physics_process(delta):
	if playing: # only do this if the game is being played
		
		if !is_instance_valid(sel_note): # note flew off end of staff
			if !correct_sel_made: # make sure this is only called if the user never selected the correct player for this note
				sel_next_note()
		if notes_array.size() > 0:
			var last_note = notes_array[notes_array.size()-1]
			if is_instance_valid(last_note) and typeof(last_note) == TYPE_OBJECT:
		#		print('note pos x = ', last_note.global_position.x)
		#		print('clef width = ', x_to_add_new_note)
				if last_note.global_position.x < x_to_add_new_note:
					add_note()
#	pass

func _input(event):
	pass

func change_notes(grp):
	# change the icon
#	var seltext
	if grp == note_bg:
		note_option_sel = grp.sel_text
	elif grp == region_bg:
		region_option_sel = grp.sel_text
	clef.show_sel_notes(note_option_sel,region_option_sel)
	
	
	
func add_button(butgrp,txt,sz):
	var new_code = true
	var but
	var btnscene
	if new_code:
		btnscene = Btn.instance()
		btnscene.init('Test',50,true)
		but = btnscene.get_button()
#		but.Button.connect("pressed",self,'change_notes',[butgrp])
#		but.Button.group = butgrp
	else:
		but = Button.new() #add_option(note_bg,'Low',true)
		but.text = txt
		but.flat = true
		var df = DynamicFont.new()
		df.font_data = load('res://Fonts/Roboto-Medium.ttf')
		but.set("custom_fonts/font",df)
	#	but.set("custom_colors/font_color",clr)
		but.get("custom_fonts/font").set_size(sz)
	#	dynamic_font.size = 50
	#	var but_scale = 0.5
	#	but_high.font = font #get_font("string_name", "")
	#	but.add_font_override("font", df) #dynamic_font)
		
		var exp_icons = false
		but.expand_icon = exp_icons #false #true
		but.align = HALIGN_LEFT
		but.icon = unsel_texture
		but.toggle_mode = true
	#	but_high.pressed = false
	but.connect("pressed",self,'change_notes',[butgrp])
	but.group = butgrp
	if new_code:
		return but #btnscene
	else:
		return but
	
func show_hide_settings():
#	set_panel.show_hide_settings()
#	# remove the notes from the clef
	if set_panel.panel_visible() == false:
		clef.clear_settings_notes()
	else:
		clef.show_sel_notes(note_option_sel,region_option_sel)

func go_to_main_menu():
	get_tree().change_scene("res://MainMenu.tscn")
