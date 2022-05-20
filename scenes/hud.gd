extends Control

onready var parent = get_parent()
onready var gameplay
onready var titlescreen
onready var hud = self
onready var ui = $ui
onready var partner_hud = $ui/partner_hud
onready var count = $ui/count
onready var mission = $ui/mission

func ready():
	exit()
	gameplay = parent.gameplay
	titlescreen = parent.titlescreen
	partner_hud.ready()

func _process(delta):
	rect_position = gameplay.camera.position
	rect_scale = gameplay.camera.zoom

func enter():
	self.visible = true

func exit():
	self.visible = false
