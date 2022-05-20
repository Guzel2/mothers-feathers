extends AnimatedSprite

onready var parent = get_parent()
onready var tree_log = $log
onready var tree_branches = $branch
onready var leaves = $leaves

var animation_timer = 0
var base_time = 180
var added_time = 180

func _ready():
	randomize()
	rotation_degrees = randi() % 360
	leaves.rotation_degrees = -rotation_degrees
	leaves.position = Vector2(200, 200).rotated(-rotation)
	for child in get_children():
		child.animation = animation
	#	child.rotation_degrees = randi() % 360
	
	animation_timer = base_time + randi() % added_time
	
	if frame == 1:
		tree_log.frame = 1
		tree_branches.frame = 1
		leaves.animation = leaves.animation + '_autumn'

func _process(_delta):
	if animation_timer > 1:
		animation_timer -= 1
	elif animation_timer == 1:
		leaves.playing = true
		leaves.visible = true
		animation_timer -= 1


func _on_leaves_animation_finished():
	leaves.playing = false
	leaves.visible = false
	animation_timer = base_time + randi() % added_time
