extends CanvasLayer

signal start_stop
signal go_back
signal help_selected

# Declare member variables here. 
var life_size_y = 120 #pixels
# preload textures
var start_texture = load("res://Icons/PlayWhiteSquare.png")
var stop_texture = load("res://Icons/StopWhiteSquare.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	# adjust the sprite sizes
	adjust_lives_sizes($LivesBox/Life)
	adjust_lives_sizes($LivesBox/Life2)
	adjust_lives_sizes($LivesBox/Life3)
	adjust_lives_sizes($LivesBox/Life4)
	adjust_lives_sizes($LivesBox/Life5)
	adjust_lives_sizes($LivesBox/Life6)
	adjust_lives_sizes($LivesBox/Life7)
	$PlayButton.connect("button_up",self,"start_stop_switch")
	$BackButton.connect("button_up",self,"back_arrow")
	$HelpButton.connect("button_up",self,"help")
	$HelpButton.connect("button_up",self,"show_hide_help")
	$HelpPanel/CloseHelpPanel.connect("button_up",self,"show_hide_help")
	
func adjust_lives_sizes(life_sprite):
	var lt = life_sprite.texture
	var ts = lt.get_size().y
	life_sprite.scale = Vector2(life_size_y / ts, life_size_y/ts)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func display_instructions(instructions):
	$InstructionsLabel.text = instructions
	$InstructionsLabel.visible = true
	
func show_instructions():
	$InstructionsLabel.visible = true
	
func hide_instructions():
	$InstructionsLabel.visible = false
		
func show_message(text):
	$Message.text = text
	$Message.visible = true
	yield(get_tree().create_timer(2), "timeout")
	$Message.visible = false
#	$AnimationPlayer.seek(0)
#	$AnimationPlayer.play("show_message")
#	$AnimationPlayer.seek(0)
#	$AnimationPlayer.stop(true)
	
func lose_life():
	# gray out the next life image
	if $LivesBox/Life.modulate == Color(1,1,1,1):
		$LivesBox/Life.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life2.modulate == Color(1,1,1,1):
		$LivesBox/Life2.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life3.modulate == Color(1,1,1,1):
		$LivesBox/Life3.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life4.modulate == Color(1,1,1,1):
		$LivesBox/Life4.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life5.modulate == Color(1,1,1,1):
		$LivesBox/Life5.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life6.modulate == Color(1,1,1,1):
		$LivesBox/Life6.modulate = Color(0,0,0,.25)
	elif $LivesBox/Life7.modulate == Color(1,1,1,1):
		$LivesBox/Life7.modulate = Color(0,0,0,.25)
	
func reset_lives():
	$LivesBox/Life.modulate = Color(1,1,1,1)
	$LivesBox/Life2.modulate = Color(1,1,1,1)
	$LivesBox/Life3.modulate = Color(1,1,1,1)
	$LivesBox/Life4.modulate = Color(1,1,1,1)
	$LivesBox/Life5.modulate = Color(1,1,1,1)
	$LivesBox/Life6.modulate = Color(1,1,1,1)
	$LivesBox/Life7.modulate = Color(1,1,1,1)

func hide_lives():
	$LivesBox/Life.visible = false
	$LivesBox/Life2.visible = false
	$LivesBox/Life3.visible = false
	$LivesBox/Life4.visible = false
	$LivesBox/Life5.visible = false
	$LivesBox/Life6.visible = false
	$LivesBox/Life7.visible = false
func hide():
	$ScoreBox.hide()

func show():
	$ScoreBox.show()

func update_score(value):
	$ScoreBox/Score.text = str(value)
	
func align_instr(atype):
	if atype == "bottom":
		$InstructionsLabel.valign = VALIGN_BOTTOM
		
func show_play_hint():
	$PlayHint.visible = true

func hide_play_hint():
	$PlayHint.visible = false
	
func start_stop_switch():
	if $PlayButton.texture_normal == start_texture: #$ScoreBox/VBoxContainer/StartButton.text == 'Start':
#		$ScoreBox/VBoxContainer/StartButton.text == 'Stop'
		$PlayButton.texture_normal = stop_texture
		hide_while_playing()
	elif $PlayButton.texture_normal == stop_texture: #$ScoreBox/VBoxContainer/StartButton.text == 'Stop':
#		$ScoreBox/VBoxContainer/StartButton.text == 'Start'
		$PlayButton.texture_normal = start_texture
		show_while_not_playing()
	emit_signal("start_stop")
	
func stop():
	$PlayButton.texture_normal = start_texture
	
func back_arrow():
	get_tree().change_scene("res://MainMenu.tscn")
	emit_signal('go_back')

func help():
	emit_signal("help_selected")

func hide_while_playing():
	# hide everything the user shouldn't see when the game is running
	var tf = false
	$HelpPanel.visible = false
	show_hide(tf)
	
func show_while_not_playing():
	# show everything the user shouldn't see when the game is running
	var tf = true
	show_hide(tf)

func show_hide(tf):
	$CopyrightLabel.visible = tf
	$BackButton.visible = tf
	$HelpButton.visible = tf
#	$InstructionsLabel.visible = tf
#	$PlayHint.visible = tf
#	$Message.visible = tf
#	$StreakLabel.visible = tf
#	$InfoButton.visible = tf

func show_hide_help():
	if $HelpPanel.visible == true:
		hide_help()
#		$HelpPanel.visible = false
#		octave.visible = true
	else:
		$HelpPanel.visible = true
#		octave.visible = false
		
func hide_help():
	$HelpPanel.visible = false
#	octave.visible = true
