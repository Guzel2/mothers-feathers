extends Control

onready var parent = get_parent()
onready var gameplay
onready var titlescreen
onready var pause_menu = self
onready var menu_camera
onready var hud

func ready():
	titlescreen = parent.titlescreen
	menu_camera = pause_menu.menu_camera
	gameplay = parent.gameplay
	hud = parent.hud

func exit():
	self.visible = false

func enter():
	self.visible = true
	$pauseBox/ResumeGame.grab_focus()

func _on_ResumeGame_pressed():
	gameplay.enter()
	exit()

func _on_ReturntoMenu_pressed():
	titlescreen.enter()
	exit()
