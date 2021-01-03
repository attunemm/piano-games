extends Node2D

signal selection_changed

	
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var bbox # box to hold the group of buttons
var sel_texture = load('res://Icons/HatWhiteFilled.svg')
var unsel_texture = load('res://Icons/HatWhiteUnfilled.svg')
var icon_texture = sel_texture
var sprite_sel
var sprite_unsel
var h = 168.0/255.0
var s = 90.0/255.0
var v1 = 82.0/255.0
var v2 = 58.0/255.0
var r = 20.0/255.0
var g = 209.0/255.0
var b = 172.0/255.0
var sel_text
var butgrp = ButtonGroup.new()
#var color_sel = Color.from_hsv(h, s, v1, 1.0)  # (h,s,v,a)
#var color_unsel =  Color.from_hsv(h, s, v2, 1.0) 
var color_unsel = Color(r,g,b,0.5)
var color_sel = Color(r,g,b,1)
var color_icon = Color(r,g,b,0)
var scene_size = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
#	init('Label:',['Opt 1','Opt 2', 'Opt 3'], 50, true)
#	get_scene_size()
	pass # Replace with function body.
	

func sel_changed():
	for but in butgrp.get_buttons():
		if but.pressed:
#			but.pressed = false
			but.icon = sel_texture
			but.modulate = color_sel
			sel_text = but.text
#			for c in but.get_children():
#				if c.name == 'Selected':
#					c.visible = true
#				elif c.name == 'Unselected':
#					c.visible = false
#	#		but/Selected.visible = true
#	#		but/Unselected.visible = false
		else:
			but.pressed = false
			but.icon = unsel_texture
			but.modulate = color_unsel
#			for c in but.get_children():
#				if c.name == 'Selected':
#					c.visible = false
#				elif c.name == 'Unselected':
#					c.visible = true
#	#		but/Selected.visible = false
#	#		but/Unselected.visible = true
	emit_signal("selection_changed")
	print('emitted selection changed')
		
func init(lbl,txt,sz,issel):
	bbox = VBoxContainer.new()
	# txt is an array of strings holding the text for each button
	var but
	var sprt
	var df = DynamicFont.new()
	df.font_data = load('res://Fonts/Roboto-Medium.ttf')
	df.size = sz
	# add the label
	lbl = add_label(lbl,Vector2(0,0),sz, color_sel, self) #bbox)
#	self.add_child(lbl)
	var control_size = lbl.rect_size
	var control_loc = Vector2(0,0)
	var y_gap = 0 #control_size.y / 10
	var new_y = 0
#	but.set("custom_colors/font_color",clr)
#	$OptionBtn.get("custom_fonts/font").set_size(sz)
	var sprt_sz
#	var butszx = 0.0
#	var butszy = 0.0
	for t in txt:
		but = Button.new() #add_option(note_bg,'Low',true)
		but.set("custom_fonts/font",df)
		but.text = t
		but.flat = true
		but.toggle_mode = true
		but.align = Label.ALIGN_LEFT
		but.pressed = false
#		but.expand_icon = true
		but.icon = unsel_texture
		but.modulate = color_unsel
		but.connect('pressed',self,'sel_changed')
	# select the final button TODO: have input determining which to select
	
#		var but_pos = but.rect_size
#		print('button size = ', but_pos.y)
#
#		# add two sprites
#		sprt = Sprite.new()
#		sprt.centered = true
#		sprt.texture = sel_texture
#		sprt_sz = get_sprite_size(sprt)
##		sprt.offset = Vector2(-sprt_sz.x/2,sprt_sz.y/4) #but_pos.y)
#		sprt.position = Vector2(-sprt_sz.x/2,sprt_sz.y/4) #but_pos.y)
#		sprt.modulate = color_sel
#		sprt.set_name('Selected')
#		but.add_child(sprt)
#		sprt = Sprite.new()
#		sprt.texture = unsel_texture
#		sprt_sz = get_sprite_size(sprt)
#		sprt.offset = Vector2(-sprt_sz.x/2,sprt_sz.y/4)#,but_pos.y)
#		sprt.modulate = color_unsel
#		sprt.set_name('Unselected')
#		but.add_child(sprt)
#		but.rect_position = Vector2(sprt_sz.x,0)
		but.group = butgrp
		self.add_child(but)
		new_y = new_y + control_size.y + y_gap
#		control_loc.y = control_loc.y + control_size.y + y_gap
#		control_size = but.rect_size
#		print('but pos = ', but.rect_size)
		but.rect_position.y = new_y #control_loc
	but.pressed = true
#		bbox.add_child(but)
#
#
##		but.add_child(pg)
#	self.add_child(bbox)
#	boxsz = bbox.rect_size
#	var pts = $Polygon2D.polygon
#	pts[0][0] = -sprt_sz.x/2
#	pts[0][1] = 0
#	pts[1][0] = butszx
#	pts[1][1] = 0
#	pts[2][0] = butszx
#	pts[2][1] = butszy
#	pts[3][0] = -sprt_sz.x/2
#	pts[3][1] = butszy
#	$Polygon2D.polygon = pts
#	bbox.rect_position = Vector2(0,0)
		
#	if issel:
#		$OptionBtn/Selected.visible = true
#		$OptionBtn/Unselected.visible = false
#	else:
#		$OptionBtn/Selected.visible = false
#		$OptionBtn/Unselected.visible = true
##	var df = DynamicFont.new()
##	df.font_data = load('res://Fonts/Roboto-Medium.ttf')
##	Button.set("custom_fonts/font",df)
##	but.set("custom_colors/font_color",clr)
#	$OptionBtn.get("custom_fonts/font").set_size(sz)
##	dynamic_font.size = 50
##	var but_scale = 0.5
##	but_high.font = font #get_font("string_name", "")
##	but.add_font_override("font", df) #dynamic_font)
##	but.connect("pressed",self,'change_notes',[butgrp])
##	but.align = HALIGN_LEFT
##	but.icon = unsel_texture
#
###	but_high.pressed = false
##	but.group = butgrp
##	return but

func get_scene_size():
	var max_width = 0.0
	var max_height = 0.0
	for b in butgrp.get_buttons():
		max_width = max(max_width,b.rect_size.x)
		max_height = max(max_height,b.rect_global_position.y)
	print('max width = ', max_width)
	print('max height = ', max_height)
	scene_size = Vector2(max_width,max_height)
	return scene_size
		
func get_button():
	return $OptionBtn
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_sprite_size(sprt):
	# sprt must be a Sprite object
	var unscaled_size = sprt.texture.get_size()
	var scale_factors = sprt.get_scale()
	var ss = Vector2(unscaled_size.x * scale_factors.x, unscaled_size.y * scale_factors.y)
	return ss

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

func get_vbox_size():
	return bbox.rect_size
