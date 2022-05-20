extends Node2D

onready var children = get_children()
onready var gameplay = $gameplay
onready var titlescreen = $Titlescreen
onready var pause_menu = $pause_menu
onready var control_menu = $control_menu
onready var hud = $hud
onready var credits = $credits
onready var logo = $logo_animation

#func _ready():
	#logo.ready()


func _ready():
	logo.ready()
	for child in children:
		child.ready()
	
	gameplay.enter()
	pause_menu.exit()
	hud.exit()
	credits.exit()
	titlescreen.enter()
	titlescreen.menu_camera.make_current()

func _process(_delta):
	pass #print(pause_menu.visible)
