extends CanvasLayer


# Declare member variables here. 
var life_size_y = 120 #pixels

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

func adjust_lives_sizes(life_sprite):
	var lt = life_sprite.texture
	var ts = lt.get_size().y
	life_sprite.scale = Vector2(life_size_y / ts, life_size_y/ts)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func display_instructions(instructions):
	$InstructionsLabel.text = instructions
	
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

func hide():
	$ScoreBox.hide()

func show():
	$ScoreBox.show()

func update_score(value):
	$ScoreBox/VBoxContainer/HBoxContainer/Score.text = str(value)

func start_stop_switch():
	if $ScoreBox/VBoxContainer/StartButton.text == 'Start':
		$ScoreBox/VBoxContainer/StartButton.text == 'Stop'
	elif $ScoreBox/VBoxContainer/StartButton.text == 'Stop':
		$ScoreBox/VBoxContainer/StartButton.text == 'Start'
