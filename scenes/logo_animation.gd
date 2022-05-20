extends AnimatedSprite

onready var parent = get_parent()
var kill_next_time = false

func ready():
	animation = 'animation'
	playing = true

func _on_logo_animation_animation_finished():
	animation = 'static_image'
	playing = false
	self.visible = false
	queue_free()
	if kill_next_time:
		queue_free()
	kill_next_time = true
