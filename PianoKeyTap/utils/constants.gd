extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# colors that correspond to each player
var A_rgb = Color8(7,129,230)
var B_rgb = Color8(110,25,110) #Color8(75,25,75)
var C_rgb = Color8(250,64,2)
var D_rgb = Color8(1,161,40)
var E_rgb = Color8(20,50,140)
var F_rgb = Color8(220,55,95)
var G_rgb = Color8(220,210,75)

# screen size in pixels
var screenWidth = ProjectSettings.get_setting("display/window/size/width")
var screenHeight = ProjectSettings.get_setting("display/window/size/height")

# colors for text label
var lblColorBright = Color8(20,210,170)
var lblColorDim = Color8(15,150,120)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
