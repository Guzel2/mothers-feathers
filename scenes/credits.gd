extends Control

onready var parent = get_parent()
# Called when the node enters the scene tree for the first time.

func _ready():
	exit()

func ready():
	pass # Replace with function body.

func enter():
	self.visible = true
	$credit_ui/ReturntoMenu.grab_focus()

func exit():
	self.visible = false

func _on_ReturntoMenu_pressed():
	exit()
	parent.titlescreen.enter()
