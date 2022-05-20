extends Control

onready var parent = get_parent()
onready var gameplay# = parent.gameplay
onready var control_menu# = parent.control_menu
onready var titlescreen = self
onready var menu_camera = $menu_camera
onready var menubox = $menubox
onready var pause_menu
onready var hud
onready var credits

func ready():
	$menubox/Startbutton.grab_focus()
	
	pause_menu = parent.pause_menu
	gameplay = parent.gameplay
	hud = parent.hud
	credits = parent.credits
	control_menu = parent.control_menu
	
	gameplay.exit()
	pause_menu.visible = false
	titlescreen.enter()
	menubox.rect_position = Vector2(0, 0) - menubox.rect_size/2

func _process(delta):
	if self.visible == true:
		gameplay.visible = false
		hud.visible = false

func enter():
	gameplay.in_titlescreen = true
	gameplay.check_titlescreen()
	self.visible = true
	menu_camera.make_current()
	pause_menu.exit()
	$menubox/Startbutton.grab_focus()

func exit():
	visible = false



func _on_Startbutton_pressed():
	titlescreen.exit()
	gameplay.enter()
	hud.enter()


func _on_Optionsbutton_pressed():
	control_menu.enter()
	exit()

func _on_Quitbutton_pressed():
	get_tree().quit()


func _on_Creditsbutton_pressed():
	exit()
	credits.enter()
