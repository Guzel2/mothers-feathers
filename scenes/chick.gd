extends Node2D

onready var player
onready var ani = $animation
onready var shadow = $shadow

var target_position
var current_target
var speed
var max_speed
var dir

func _ready():
	ani.playing = true

func _process(delta):
	current_target = player.position + (target_position.rotated(player.animation.rotation)*player.scale)
	ani.scale = Vector2(.2, .2) * player.scale
	
	if player.animation.animation == 'flapping':
		ani.animation = 'flapping'
	else:
		ani.animation = 'gliding'
	
	adjust_shadow()
	
	dir = (current_target - position).normalized()
	
	speed = clamp(position.distance_to(current_target)*.05, 0, max_speed)
	position += dir*speed*delta*60
	
	ani.rotation = dir.angle() + PI/2

func adjust_shadow():
	shadow.animation = ani.animation
	shadow.frame = ani.frame
	shadow.scale = player.shadow.scale * ani.scale * Vector2(5, 5)
	shadow.modulate = player.shadow.modulate
	shadow.rotation = ani.rotation
	shadow.position = (player.shadow.position) * ani.scale * Vector2(5, 5)
