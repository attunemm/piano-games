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
var label_size
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
		else:
			but.pressed = false
			but.icon = unsel_texture
			but.modulate = color_unsel
	emit_signal("selection_changed")
		
func init(lbl,txt,sz,seloption):
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
	label_size = lbl.rect_size
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
		if t == seloption: #t.nocasecmp_to(seloption) == 0: # t == seloption:
#			print('sel option = ', seloption)
			but.pressed = true
	# select the final button TODO: have input determining which to select
		but.group = butgrp
		self.add_child(but)
		new_y = new_y + label_size.y + y_gap
		but.rect_position.y = new_y #control_loc
	sel_changed()

func get_scene_size():
	var max_width = 0.0
	var max_height = 0.0
	for b in butgrp.get_buttons():
		max_width = max(max_width,b.rect_size.x)
		max_height = max(max_height,b.rect_global_position.y)
	max_width = max(max_width, label_size.x)
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
