extends Control

onready var control_menu = self
onready var parent = get_parent()
onready var titlescreen

func ready():
	titlescreen = parent.titlescreen
	exit()

func enter():
	self.visible = true
	$control_box/ReturntoMenu.grab_focus()

func exit():
	self.visible = false

func _on_ReturntoMenu_pressed():
	exit()
	titlescreen.enter()
	
