extends KinematicBody2D

onready var parent = get_parent()
onready var animation = $animation
onready var shadow = $shadow
onready var arrow = $arrow
onready var collect_area = $collect_area
onready var music_summer = $music_summer
onready var music_autumn = $music_autumn
onready var flap_sound = $bird_flapping
onready var wind = $wind
onready var level

var dir = Vector2(0, 0)
var old_dir = Vector2(0, 0)
var hori_speed = 400

var height = 310
var new_height = height
var height_change = -1
var gravity = .22
var max_fall_speed = -10
var verti_speed = 6 #odl was 4

var swing_cooldown = 30
var swing_cooltimer = 0

var cloud_height_3 = 1400
var cloud_height_2 = 1250
var cloud_height_1 = 750
var treetop_height = 700
var branches_height = 500
var ground_height = 300

var collectables = []

var grounded = false

var shadow_offset = Vector2(-10, 10)

var mission_complete = false

var game_finished = false

func ready():
	level = parent.level
	
	music_summer.playing = true
	wind.playing = true

func _process(_delta):
	if parent.phase == 8:
		if position.y > 80000:
			game_finished = true
	inputs()
	
	horizontal_movement()
	vertical_movement()
	
	adjusting_shadow()
	
	if mission_complete:
		var angel = (position - level.nest.position).normalized()
		arrow.rotation = angel.angle() + PI/4 + PI
		arrow.position = angel * -120
	
	wind_volume()
	noise_volume()

func set_animation(ani):
	animation.animation = ani
	animation.frame = 0

func inputs():
	dir = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	
	if !(!(Input.is_action_pressed("ui_left")) 
	and !(Input.is_action_pressed("ui_right")) 
	and !(Input.is_action_pressed("ui_up")) 
	and !(Input.is_action_pressed("ui_down"))):
		old_dir = dir
		max_fall_speed = -3
	else:
		max_fall_speed = -15
	
	if swing_cooltimer <= 0:
		if Input.is_action_pressed("ui_accept"):
			height_change = verti_speed
			set_animation('flapping')
			swing_cooltimer = swing_cooldown
			flap_sound.pitch_scale = float(130 + randi() % 50)/100
			flap_sound.play(0)
			parent.parent.hud.exit()
			visible = false
	else:
		swing_cooltimer -= 1

func horizontal_movement():
	dir = dir.normalized()
	move_and_slide(dir * hori_speed  * height/100.0)
	animation.rotation = old_dir.angle() + PI/2

func vertical_movement():
	new_height += height_change
	
	if new_height < ground_height:
		new_height = ground_height
		
		var can_land = true
		for pos in level.cant_spawn_here:
			if (position.x > pos[0][0] and position.x < pos[1][0]) and (position.y > pos[0][1] and position.y < pos [1][1]):
				can_land = false
		
		if can_land == false:
			set_animation('gliding')
			grounded = false
		
		if grounded == false and can_land:
			set_animation('landing')
			grounded = true
	elif grounded == true:
		grounded = false
	
	if new_height > cloud_height_2:
		new_height = cloud_height_2
	
	if new_height > branches_height and collect_area.monitoring == true:
		collect_area.monitoring = false
	
	if new_height < branches_height and collect_area.monitoring == false:
		collect_area.monitoring = true
	
	height_change -= gravity
	if height_change < max_fall_speed:
		height_change = max_fall_speed
	
	scale = Vector2(1, 1) * height/100.0

func adjusting_shadow():
	var absolute_height = (height-ground_height)/4
	shadow.position = Vector2(-absolute_height, absolute_height) + shadow_offset
	var transparency = 1-(float(height)/float(cloud_height_1))
	shadow.modulate = Color(0, 0, 0, transparency)
	shadow.rotation = animation.rotation
	shadow.frame = animation.frame
	shadow.animation = animation.animation
	var height_scale = 1- (float(height-ground_height)/float(cloud_height_1-ground_height))
	shadow.scale = animation.scale * height_scale

func mission_completed():
	mission_complete = true
	arrow.visible = true

func wind_volume():
	var volume = -2 + (float(height-ground_height)/float(cloud_height_1-ground_height))*9
	wind.volume_db = clamp(volume, -2, 10)

func noise_volume():
	var volume = 0 - (float(height-ground_height)/float(cloud_height_1-ground_height))*9
	for noise in level.noises:
		noise.volume_db = volume

func _on_collect_area_area_entered(area):
	if area == level.nest and height < branches_height:
		if mission_complete:
			parent.branch_count = 0
			parent.fly_count = 0
			parent.worm_count = 0
			parent.next_phase()
	
	match parent.phase:
		0:
			if area in level.partners and height < branches_height:
				var need_to_remove = 0
				for noise in len(level.noises):
					if level.noises[noise].get_parent() == area:
						need_to_remove = noise
				level.noises.remove(need_to_remove)
				area.queue_free()
				parent.partner_count += 1
				parent.update_count()###########
				if parent.partner_count >= parent.partner_max:
					#for partner in level.partners:
					#	partner.queue_free()
					parent.next_phase()
		1, 2, 3:
			if area in level.branches and height < branches_height:
				if parent.branch_count < parent.branch_max:
					area.queue_free()
					parent.branch_count += 1
					set_animation('collecting')
					if parent.branch_count >= parent.branch_max:
						mission_completed()
					parent.update_count()
		4, 5:
			if area in level.flys and height < branches_height:
				if parent.fly_count < parent.fly_max:
					area.queue_free()
					parent.fly_count += 1
					set_animation('collecting')
					if parent.fly_count >= parent.fly_max:
						mission_completed()
					parent.update_count()
		6, 7:
			if area in level.worms and height < branches_height:
				if parent.worm_count < parent.worm_max:
					area.queue_free()
					parent.worm_count += 1
					set_animation('collecting')
					if parent.worm_count >= parent.worm_max:
						mission_completed()
					parent.update_count()

func _on_animation_animation_finished():
	if grounded:
		set_animation('walking')
	else:
		set_animation('gliding')
