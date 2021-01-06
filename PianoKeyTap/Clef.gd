extends Node2D

signal object_entered_clef(body)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var Note
var nnotes = 0 # number of notes 
var noteidcs
var clef_type = 'treble' # can be 'treble' or 'bass'
var notes = Array()
#var settings_notes = Array() # array holding the notes displayed to show the user the settings
var note_pos_array = Array() # array to hold each note with its y position [ypos, note] - for sorting
var tot_time = 0
var note_idx = 0
# notes from top down on staves
var notes_treble = ['D','C','B','A','G','F','E','D','C','B','A','G','F','E','D','C','B','A','G']
var notes_bass = ['F','E','D','C','B','A','G','F','E','D','C','B','A','G','F','E','D','C','B']
var sel_array = Array() # holds T/F for which notes to pick from
# keep track of which notes are on a line, top to bottom
var on_line = [false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false]
var on_space
# keep track of which notes are on the staff
var on_staff = [false,false,false,false,false,true,true,true,true,true,true,true,true,true,false,false,false,false,false]
var on_leger
var all_notes_bool = [true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true,true]
# ledger lines are listed from top to bottom with 2 above, 1 above, mid, 1 below, 2 below for each note
var ledger_lines = [[false,false,false,false,true,false,true],\
[false,false,false,true,false,true,false],\
[false,false,false,false,true,false,false],\
[false,false,false,true,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,false,false,false,false],\
[false,false,false,true,false,false,false],\
[false,false,true,false,false,false,false],\
[false,true,false,true,false,false,false],\
[true,false,true,false,false,false,false]]
#[true,false,true,false,false,false],\
var staff_points = Array() # array to hold position and handle to staff points - for locating notes
var settings_notes = Array() # array to notes displayed to show the user their selected settings

func set_type(newtype):
	if newtype == 'bass':
		clef_type = 'bass'
	else:
		clef_type = 'treble' # default to treble clef
	# show/hide the corresponding clef symbol
	show_clef()
	
func change_width(wtoh):
	# wtoh is the new, desired width to height ratio
	# first, see what the current height is
	var rect = $Staff.polygon
	var h = rect[1][1] - rect[0][1]
	var w = rect[2][0] - rect[0][0]
	print('height = ', h)
	print('width = ', w)
	#  calculate new width
	var wnew = h*wtoh
	print('new_width = ', wnew)
	rect[3][0] = wnew
	rect[2][0] = wnew
	$Staff.set_polygon(rect)
	# adjust all of the staff lines also
	$Staff/StaffLine1.points[1][0] = wnew
	$Staff/StaffLine2.points[1][0] = wnew
	$Staff/StaffLine3.points[1][0] = wnew
	$Staff/StaffLine4.points[1][0] = wnew
	$Staff/StaffLine5.points[1][0] = wnew
	# move the end line
	$Staff/VertLine2.points[0][0] = wnew
	$Staff/VertLine2.points[1][0] = wnew
	
func show_clef():
#	change_width(3) # test - remove this eventually
	if clef_type == 'bass':
		$Staff/TrebleClef.visible = false
		$Staff/BassClef.visible = true
	else:
		$Staff/TrebleClef.visible = true
		$Staff/BassClef.visible = false
		
	# hide the ledger lines
	$Staff/LegerLineAbove1.visible = false
	$Staff/LegerLineAbove2.visible = false
	$Staff/LegerLineBelow1.visible = false
	$Staff/LegerLineBelow2.visible = false
# Called when the node enters the scene tree for the first time.
func _ready():
	on_leger = inverse_array(on_staff)
	on_space = inverse_array(on_line)
	var n
	var y = 0
	var dy = 12.5
#	var note_scale = $Staff/WholeNote.scale
	var count = 0
	var staff_offset = $Staff.position
	var pos
	var nodepos
	print('hello')
	show_clef()
	for node in $Staff.get_children():
#		print(node.get_class())
		pos = Vector2(0,0)
		if node.get_class() == 'Line2D': # if it is a line
			if 'Vert' in node.name: # skip over vertical lines
				continue
			nodepos = node.position
			# also get the points for the spaces between lines
			for pt in node.get_children():
				if pt.get_class() == 'Position2D': # add a note on this space
					staff_points.append([nodepos.y + staff_offset.y + pt.position.y, nodepos.x + staff_offset.x + pt.position.x, pt])
#					n = Note.instance()
#					n.scale = note_scale #scale down to fit in between 2 lines on the staff
#					pos = pt.position
#					n.position = Vector2(nodepos.x + pos.x + staff_offset.x, nodepos.y + pos.y + staff_offset.y)
#					add_child(n)
#					notes.append(n)
#					note_pos_array.append([n.position.y, n])
					nnotes += 1
#					n.visible = false
#			n = Note.instance() # add a note on this horizontal line
#			n.scale = note_scale
#			n.position = Vector2(pos.x + staff_offset.x, nodepos.y+staff_offset.y)
#			add_child(n)
#			notes.append(n)
#			nnotes += 1
#			note_pos_array.append([n.position.y, n])
#			n.visible = false
#	note_pos_array.sort_custom(self,'sort_ascending')
	staff_points.sort_custom(self,'sort_ascending')
#	print(staff_points)
#	print(note_pos_array)
	# set the note value for each note based on the clef

static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false

func add_note(idx,xloc = -1701): # idx is integer, 0 being top note of staff
	var n = Note.instance()
	n.scale = $Staff/WholeNote.scale #scale down to fit in between 2 lines on the staff
	if xloc == -1701:
		xloc = staff_points[idx][1]
	n.position = Vector2(xloc,staff_points[idx][0])
	if clef_type == 'treble':
		n.set_name(notes_treble[idx])
	elif clef_type == 'bass':
		n.set_name(notes_bass[idx])
	# show ledger lines
	n.show_ledger_lines(ledger_lines[idx])
	#	n.position = Vector2(nodepos.x + pos.x + staff_offset.x, nodepos.y + pos.y + staff_offset.y)
	add_child(n)
	return n
#var my_items = [[5, "Potato"], [9, "Rice"], [4, "Tomato"]]
#my_items.sort_custom(MyCustomSorter, "sort_ascending")
#print(my_items) # Prints [[4, Tomato], [5, Potato], [9, Rice]].

#			return count
#	for i in range(nnotes):
#		n = Note.instance()
##			n.init(self.NOTES[i])
#			#wkeys[i].note = self.NOTES[i]
#		n.connect("clicked", self, "play_key")
#		n.scale = note_scale
##			n.set_pitch_scale(pitch_scale)
#		add_child(n)
#		notes.append(n)
	
			# Set the key's position to 
#		n.position = Vector2(0,y) #round(xw),y)
#		y += dy
#			xw += round(white_x_offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	pass
	var slow_display = false # set to true to display notes one at a time
	if slow_display:
		if note_idx < nnotes:
			if tot_time - 3 > 0:
				tot_time = 0
				note_pos_array[note_idx][1].visible = true
				note_idx += 1
			else:
				tot_time += delta

func set_50perc_line_x(newx):
	$Staff/Perc50_VertLine.position.x = newx
	
func set_0perc_line_x(newx):
	$Staff/Perc0_VertLine.position.x = newx

func set_100perc_line_x(newx):
	$Staff/Perc100_VertLine.position.x = newx
	
func get_0perc_line_x():
	return $Staff/Perc0_VertLine.position.x

func get_100perc_line_x():
	return $Staff/Perc100_VertLine.position.x
	
func get_collision_x_bound():
	# return the x-value of the right edge of the collision shape
	return $CollisionShape2D.position.x * 2
	
func _on_Clef_body_entered(body):
	# when a moving note gets close to the bass or treble clef sign, make it disappear
	body.visible = false # disappear
	# wait a few seconds, then delete from the queue - this way other code that calls this object won't crash
#	yield(get_tree().create_timer(4), "timeout")
	emit_signal("object_entered_clef", body)
#	get_tree().queue_delete(body)# body.name == "Player":
#		get_tree().queue_delete(self)pass # Replace with function body.

func get_width():
	return $Staff.polygon[2][0] - $Staff.polygon[0][0]

func get_height():
	return $Staff.polygon[1][1] - $Staff.polygon[0][1]

func show_perc_lines():
	$Staff/Perc0_VertLine.visible = true
	$Staff/Perc50_VertLine.visible = true
	$Staff/Perc100_VertLine.visible = true

func hide_perc_lines():
	$Staff/Perc0_VertLine.visible = false
	$Staff/Perc50_VertLine.visible = false
	$Staff/Perc100_VertLine.visible = false
		
func set_trebleclef_xscale(sc):
	$Staff/TrebleClef.scale.x = sc # for use when scaling the whole clef in the x-dir
	
func get_polygon():
	return $Staff.polygon
	
func set_polygon(pts):
	$Staff.polygon = pts

func show_sel_notes(notes_sel,region_sel):
#	settings_notes.clear()
	clear_settings_notes()
#	sel_array
	
	# Region
	if region_sel == 'Staff':
		sel_array = on_staff
	elif region_sel == 'Leger':
		sel_array = on_leger
#		sel_array = !on_staff
	else: # 'All'
		sel_array = all_notes_bool
			
	# Notes
	if notes_sel == 'Lines':
		sel_array = merge_arrays(on_line, sel_array)
	elif notes_sel == 'Spaces':
		sel_array = merge_arrays(on_space, sel_array)
#	else: # 'All'
#		keep the current selection
	
	print('sel array = ', sel_array)
	var nt
	var xline = 400
	var xspace = xline + 50
	var i = 0
	for n in sel_array:
		if n:
			if on_line[i]:
				nt = add_note(i,xline)
			else:
				nt = add_note(i,xspace)
			nt.disable_collision()
			settings_notes.append(nt)
		i+=1
		
	noteidcs = get_sel_note_idcs()
	print('noteidcs  = ', noteidcs)
	nnotes = noteidcs.size()
	print('# notes = ', nnotes)

func merge_arrays(a1,a2):
	var a3 = Array()
	var i = 0
	for ai in a1:
		a3.append(ai and a2[i])
		i+=1
	return a3

func inverse_array(a1):
	var a2 = Array()
	var i = 0
	for ai in a1:
		a2.append(!ai)
		i+=1
	return a2
	
func clear_settings_notes():
	for n in settings_notes:
		n.queue_free()
		
	settings_notes.clear()

func hide_sel_notes():
	for n in settings_notes:
		n.visible = false
		
func get_sel_note_idcs():
	var nidcs = Array()
	var i = 0
	for n in sel_array:
		if n:
			nidcs.append(i)
		i += 1
	return nidcs
