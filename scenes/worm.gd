extends Area2D

onready var ani = $AnimatedSprite

func _ready():
	ani.frame = randi() % 4
