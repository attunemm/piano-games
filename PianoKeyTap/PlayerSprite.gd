#extends Sprite
extends KinematicBody2D
signal clicked(node)

var fall_speed = 20
var attack_speed = 500
var gravity = 2500
var velocity = Vector2(0,fall_speed) # controls player movement
var hit_velocity = Vector2(0,-attack_speed) # when player is hit by defender
var height = 8 # controls the height of the sprite TODO make this relative?
var state = 'unset' # used in logic to control the motion of the player
var scale_factor = 2 # to account for larger window in pixels than original design
var notename = ''
# if 0.5, will "collide" before any part of the sprites connect; make smaller
var coll_factor = 0.5 # 0.5 covers the entire sprite area; increase to cover more; decrease to cover less 0.33
# control the dance movement
var dance_rate = 6 # larger number moves slower
var dance_angle = 40 # larger number lowers total rotation pi/dance_angle limits the movement
var dance_disp = 0 # pixels to move in x dir
var max_disp = 8 # max pixels to move before moving back
# control player movement after being hit
var spin_rate = 4 # larger number spins faster
var pi = 3.14159

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var direction = Vector2(2,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	switch_texture('A')
	hide_label()
	#$Label.set_percent_visible(0) # hide
	#velocity.x = 20
#	pass # Replace with function body.

func _physics_process(delta): # commenting out to try _process
#func _process(delta):
	var collision = move_and_collide(velocity * delta) # multiply by delta for move_and_collide, not move_and_slide
	if collision:
		if state == 'incorrect':
			state = 'hit'
			velocity = hit_velocity
		elif state == 'attack':
			state = 'post_attack'
			velocity = Vector2(0,int(-attack_speed/10*scale_factor))
#			velocity = Vector2(0,0)
			rotation = 0
		#print("I collided with ", collision.collider.name)
	elif state == 'hit':
		rotation += pi*delta*spin_rate
	
	else:
		
		
		if state == 'dance_right':
			position.x -= dance_disp
			rotation += pi*delta/dance_rate
			if rotation > pi/dance_angle:
				state = 'dance_left'
		elif state == 'dance_left':
#			print('in dance stmt')
			position.x += dance_disp
			rotation -= pi*delta/dance_rate
			if rotation < -pi/dance_angle:
				state = 'dance_right'
		else:
			rotation = 0
		#velocity = collision.collider_velocity #velocity.bounce(collision.normal)
#		collision.
#		if velocity.x == 0 and velocity.y == 0:
#			velocity = collision.collider.velocity
#		else:
#			velocity = Vector2(0,0) #velocity.bounce(collision.normal)
#		if collision.collider.has_method("hit"):
#			collision.collider.hit()
	#print('motion = ', motion)

func hit():
	
	if state == 'hit':
		$Sprite.set_rotation_degrees($Sprite.rotation_degrees+10)
	else:
		$Sprite.set_rotation_degrees(0)
	move_and_slide(velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	position += direction
#
func upside_down():
	$Sprite.flip_v = true

func right_side_up():
	$Sprite.flip_v = false
	
func get_sprite_size():
	var unscaled_size = $Sprite.texture.get_size()
	var scale_factors = $Sprite.get_scale()
	var ss = Vector2(unscaled_size.x * scale_factors.x, unscaled_size.y * scale_factors.y)
	return ss
#	return $Sprite.texture.get_size()
#onready var bullet_sprite = get_node("bullet_sprite_node")
#
func switch_texture(note):
	$Sprite.set_scale(Vector2(1,1))
	notename = note
	if  (note == 'A'):
		$Sprite.set_texture(Textures.image_A)

	elif(note == 'B'):
		$Sprite.set_texture(Textures.image_B)

	elif(note == 'C'):
		$Sprite.set_texture(Textures.image_C)
		
	elif(note == 'D'):
		$Sprite.set_texture(Textures.image_D)
#
	elif(note == 'E'):
		$Sprite.set_texture(Textures.image_E)
#
	elif(note == 'F'):
		$Sprite.set_texture(Textures.image_F)
		
	elif(note == 'G'):
		$Sprite.set_texture(Textures.image_G)
	
	elif  (note == 'A_flat'):
		$Sprite.set_texture(Textures.image_A_flat)

	elif(note == 'B_flat'):
		$Sprite.set_texture(Textures.image_B_flat)

	elif(note == 'C_flat'):
		$Sprite.set_texture(Textures.image_C_flat)
		
	elif(note == 'D_flat'):
		$Sprite.set_texture(Textures.image_D_flat)
#
	elif(note == 'E_flat'):
		$Sprite.set_texture(Textures.image_E_flat)
#
	elif(note == 'F_flat'):
		$Sprite.set_texture(Textures.image_F_flat)
		
	elif(note == 'G_flat'):
		$Sprite.set_texture(Textures.image_G_flat)
	
	elif  (note == 'A_sharp'):
		$Sprite.set_texture(Textures.image_A_sharp)

	elif(note == 'B_sharp'):
		$Sprite.set_texture(Textures.image_B_sharp)

	elif(note == 'C_sharp'):
		$Sprite.set_texture(Textures.image_C_sharp)
		
	elif(note == 'D_sharp'):
		$Sprite.set_texture(Textures.image_D_sharp)
#
	elif(note == 'E_sharp'):
		$Sprite.set_texture(Textures.image_E_sharp)
#
	elif(note == 'F_sharp'):
		$Sprite.set_texture(Textures.image_F_sharp)
		
	elif(note == 'G_sharp'):
		$Sprite.set_texture(Textures.image_G_sharp)
	
	else:
		$Sprite.set_texture(Textures.image_C)
		
	# scale the image to the desired height
	var sprite_size = get_sprite_size()
	var imscale = height / sprite_size.y
#	print('scale: ', imscale)
	if imscale == 0:
		imscale = 1
	$Sprite.set_scale(Vector2(imscale,imscale))
	
	# set the collisionshape to match the image size
	set_coll_shape()
##	print('sprite size: ', sprite_size)
#	var transform = get_node("CollisionShape2D").get_shape()
#	var oldScale = transform.get_extents()
##	print('orig extents: ', oldScale)
##	print('scale = ', imscale)
#	# if 0.5, will "collide" before any part of the sprites connect; make smaller
##	coll_factor = 0.33
#	transform.set_extents(Vector2(imscale*sprite_size.x*coll_factor,imscale*sprite_size.y*coll_factor))
##	print('collision shape y = ', imscale*sprite_size.y/2)
	
	# move the label to above the image
	var label_size = $Label.get_size()
	$Label.set_position(Vector2(-label_size.x/2,-imscale*sprite_size.y+label_size.y/2))
#	$Label.set_position(Vector2(-label_size.x/2,-sprite_size.y/2-label_size.y/2))
	
func set_coll_factor(cf):
	coll_factor = cf
	set_coll_shape()
	
func set_coll_shape():
	var sprite_size = get_sprite_size()
	var imscale = height / sprite_size.y
	var transform = get_node("CollisionShape2D").get_shape()
	transform.set_extents(Vector2(imscale*sprite_size.x*coll_factor,imscale*sprite_size.y*coll_factor))
	
func show_label(txt):
	$Label.set_text(txt)
	$Label.set_visible(true)
	$Label.set_percent_visible(1)
	
func hide_label():
	$Label.set_percent_visible(0)
	$Label.set_visible(false)
	
func set_height(ht):
	height = ht
	
func get_resized_texture(t: Texture, width: int = 0, height: int = 0):
	var image = t.get_data()
	if width > 0 && height > 0:
		image.resize(width, height)
	var itex = ImageTexture.new()
	itex.create_from_image(image)
	return itex
# code to modify
#func _physics_process(delta):
#    var dir = (target - position).normalized()
#    var move_amount = Vector2(move_toward(position.x, target.x, dir.x * speed  * delta), move_toward(position.y, target.y, dir.y * speed * delta))
#    move_and_collide(move_amount) # or move_and_slide(move_amount / delta)
#
#
#func move_toward(orig : float, target : float, amount : float) -> float:
#        var result : float
#
#        if abs(orig - target) <= amount:
#            result = target
#        elif orig < target:
#            result = min(orig + amount, target)
#        elif orig > target:
#            result = max(orig - amount, target)
#        return result


func _on_KinematicBody2D_input_event(viewport, event, shape_idx):
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
#	print('clicked ',notename)
	emit_signal("clicked", self)
