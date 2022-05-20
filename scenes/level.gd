extends Node2D

onready var parent = get_parent()
onready var tilemap = $tilemap
var player

var cant_spawn_here = []

var tree_noise = OpenSimplexNoise.new()
var tree_step_size = 250
var tree_threshhold = .725
var tree_range = 30000
var trees = []

var dirt_threshhold = -.825

var branch_noise = OpenSimplexNoise.new()
var branch_range = 600
var branch_step = 125
var branch_threshhold = -.75
var branches = []

var cloud_noise = OpenSimplexNoise.new()
var cloud_step = 400
var cloud_threshhold = -.75
var clouds_1 = []

var cloud_2_noise = OpenSimplexNoise.new()
var cloud_2_step = 800
var cloud_2_threshhold = -.745
var clouds_2 = []

var worm_range = 600
var worm_step = 100
var worm_threshhold = -.72
var worms = []

var fly_noise = OpenSimplexNoise.new()
var fly_step = 500
var fly_threshhold = -.6
var flys = []

var partner_threshhold = -.82
var partners = []

var deco_threshhold = -.725

var nest

var noises = []

var autumn = 0

var chunk_size = 1000 * 5
var tile_amount = 9 #there are 9 different ground tiles

func ready():
	randomize()
	player = parent.player
	
	#noise
	tree_noise.seed = randi()
	tree_noise.octaves = 1
	tree_noise.period = 75.0
	tree_noise.persistence = 0.5
	
	branch_noise.seed = randi()
	branch_noise.octaves = 1
	branch_noise.period = 8.0
	branch_noise.persistence = 0.2
	
	cloud_noise.seed = randi()
	cloud_noise.octaves = 1
	cloud_noise.period = 100.0
	cloud_noise.persistence = 0.3
	
	cloud_2_noise.seed = randi()
	cloud_2_noise.octaves = 1
	cloud_2_noise.period = 120.0
	cloud_2_noise.persistence = 0.3
	
	fly_noise.seed = randi()
	fly_noise.octaves = 1
	fly_noise.period = 15.0
	fly_noise.persistence = 0.5
	
	spawn_nature()

func _process(_delta):
	change_height()
	check_for_border()

func spawn_nature():
	set_tilemap()
	
	#lake
	for _x in range(0, 6):
		spawn_lake(-tree_range + (randi() % tree_range*2), -tree_range + (randi() % tree_range*2))
	
	#spawn_field(0, 0)
	
	#trees
	var tree_x = -tree_range
	while tree_x < tree_range:
		var tree_y = -tree_range
		tree_x += tree_step_size
		while tree_y < tree_range:
			tree_y += tree_step_size
			
			var noise_value = tree_noise.get_noise_2d(tree_x, tree_y)
			if noise_value >= tree_threshhold:
				spawn_tree(tree_x, tree_y)
			
			if noise_value <= dirt_threshhold:
				spawn_dirt_hill(tree_x, tree_y)
			elif noise_value <= partner_threshhold:
				spawn_partner(tree_x, tree_y)
			elif noise_value <= deco_threshhold:
				spawn_deco(tree_x, tree_y)
	
	#clouds
	var cloud_x = -tree_range
	while cloud_x <= tree_range:
		var cloud_y = -tree_range
		cloud_x += cloud_step
		while cloud_y < tree_range:
			cloud_y += cloud_step
			
			var noise_value = cloud_noise.get_noise_2d(cloud_x, cloud_y)
			if noise_value <= cloud_threshhold:
				spawn_cloud(cloud_x, cloud_y, 1)
	
	#clouds 2
	cloud_x = -tree_range
	while cloud_x <= tree_range:
		var cloud_y = -tree_range
		cloud_x += cloud_2_step
		while cloud_y < tree_range:
			cloud_y += cloud_2_step
			
			var noise_value = cloud_noise.get_noise_2d(cloud_x, cloud_y)
			if noise_value <= cloud_threshhold:
				spawn_cloud(cloud_x, cloud_y, 2)

func set_tilemap():
	var numbers = []
	for _x in range(0, 5):
		for y in range(0, 9):
			numbers.append(y)
	
	var pos = 0
	numbers.shuffle()
	
	var tile_x = -tree_range/1000
	while tile_x < tree_range/1000:
		var tile_y = -tree_range/1000
		
		while tile_y < tree_range/1000:
			
			tilemap.set_cell(tile_x, tile_y, numbers[pos])
			pos += 1
			if pos >= len(numbers):
				pos = 0
				numbers.shuffle()
			tile_y += 1
		tile_x += 1

func set_tilemap_autumn():
	var numbers = []
	for _x in range(0, 5):
		for y in range(0, 9):
			numbers.append(y)
	
	var pos = 0
	numbers.shuffle()
	
	var tile_x = -tree_range/500
	while tile_x < tree_range/500:
		var tile_y = -tree_range/500
		while tile_y < tree_range/500:
			if tilemap.get_cell(tile_x, tile_y) != -1:
				tilemap.set_cell(tile_x, tile_y, numbers[pos]+9)
				pos += 1
				if pos >= len(numbers):
					pos = 0
					numbers.shuffle()
			tile_y += 1
		tile_x += 1

func spawn_lake(x, y):
	var lake = load("res://scenes/lake.tscn").instance()
	lake.position = Vector2(x, y)
	var animation = randi() % 2
	lake.animation = str(animation)
	var offset 
	match animation:
		0:
			offset = Vector2(5000, 5000)
		1:
			offset = Vector2(6000, 6000)
	cant_spawn_here.append([[x, y], [x + offset.x, y + offset.y]])
	for child in lake.get_children():
		if 'Audio' in child.name:
			noises.append(child)
			child.position = offset/4
			child.play(randi() % 60)
	add_child(lake)
	
	spawn_flys(x, y, offset)

func spawn_flys(x, y, offset):
	var fly_x = 0
	while fly_x < offset.x:
		fly_x += fly_step
		var fly_y = 0
		while fly_y < offset.y:
			fly_y += fly_step
			
			var noise_value = fly_noise.get_noise_2d(fly_x + x, fly_y + y)
			
			if noise_value <= fly_threshhold:
				var fly = load("res://scenes/fly.tscn").instance()
				fly.position = Vector2(fly_x + x, fly_y + y)
				fly.rotation_degrees = randi() % 360
				flys.append(fly)
				add_child(fly)

func spawn_field(x, y):
	var field = load("res://scenes/field.tscn").instance()
	field.position = Vector2(x, y)
	var animation = randi() % 2
	var offset 
	match animation:
		0:
			offset = Vector2(8000, 9000)
		1:
			offset = Vector2(4000, 4000)
	cant_spawn_here.append([[x, y], [x + offset.x, y + offset.y]])
	add_child(field)

func spawn_tree(x, y):
	var can_spawn = true
	for pos in cant_spawn_here:
		if (x > pos[0][0] and x < pos[1][0]) and (y > pos[0][1] and y < pos [1][1]):
			can_spawn = false
	
	if can_spawn == true:
		var tree = load("res://scenes/tree.tscn").instance()
		tree.position = Vector2(x, y)
		var animation = randi() % 3
		match animation:
			0:
				tree.animation = 'oak'
			1:
				tree.animation = 'birch'
			2:
				tree.animation = 'pine'
		
		if autumn:
			tree.frame = 1
		
		trees.append(tree)
		spawn_branches(tree, x, y)
		add_child(tree)

func spawn_branches(tree, x, y):
	var branch_x = -branch_range
	while branch_x < branch_range:
		branch_x += branch_step
		var branch_y = -branch_range
		while branch_y < branch_range:
			branch_y += branch_step
			
			var noise_value = branch_noise.get_noise_2d(branch_x + x, branch_y + y)
			
			if noise_value <= branch_threshhold:
				var branch = load("res://scenes/branch.tscn").instance()
				branch.position = Vector2(branch_x + x, branch_y + y)
				branch.rotation_degrees = randi() % 360
				branch.animation = tree.animation
				branches.append(branch)
				add_child(branch)

func spawn_dirt_hill(x, y):
	var can_spawn = true
	for pos in cant_spawn_here:
		if (x > pos[0][0] and x < pos[1][0]) and (y > pos[0][1] and y < pos [1][1]):
			can_spawn = false
	
	if can_spawn == true:
			var dirt_hill = load("res://scenes/dirt_hill.tscn").instance()
			dirt_hill.position = Vector2(x, y)
			dirt_hill.rotation_degrees = randi() % 360
			var animation = randi() % 2
			dirt_hill.animation = str(animation)
			add_child(dirt_hill)
			
			spawn_worms(x, y)

func spawn_worms(x, y):
	var worm_x = -worm_range
	while worm_x < worm_range:
		worm_x += worm_step
		var worm_y = -worm_range
		while worm_y < worm_range:
			worm_y += worm_step
			
			var noise_value = branch_noise.get_noise_2d(worm_x + x, worm_y + y)
			
			if noise_value <= worm_threshhold:
				var worm = load("res://scenes/worm.tscn").instance()
				worm.position = Vector2(worm_x + x, worm_y + y)
				worm.rotation_degrees = randi() % 360
				worms.append(worm)
				if autumn == 0:
					worm.visible = false
				add_child(worm)

func spawn_partner(x, y):
	var can_spawn = true
	for pos in cant_spawn_here:
		if (x > pos[0][0] and x < pos[1][0]) and (y > pos[0][1] and y < pos [1][1]):
			can_spawn = false
	if can_spawn == true:
		var partner = load("res://scenes/partner.tscn").instance()
		partner.position = Vector2(x, y)
		partner.rotation_degrees = randi() % 360
		partners.append(partner)
		for child in partner.get_children():
			if 'Audio' in child.name:
				noises.append(child)
				child.play(randi() % 20)
		add_child(partner)

func spawn_deco(x, y):
	var can_spawn = true
	for pos in cant_spawn_here:
		if (x > pos[0][0] and x < pos[1][0]) and (y > pos[0][1] and y < pos [1][1]):
			can_spawn = false
	
	if can_spawn == true:
		var deco = load("res://scenes/deco.tscn").instance()
		deco.position = Vector2(x, y)
		deco.rotation_degrees = randi() % 360
		var animation = randi() % 10
		deco.animation = str(animation)
		add_child(deco)

func spawn_cloud(x, y, factor):
	var cloud = load("res://scenes/cloud.tscn").instance()
	cloud.position = Vector2(x, y)
	cloud.rotation_degrees = randi() % 360
	var animation = randi() % 8
	cloud.frame = animation
	cloud.modulate = Color(1, 1, 1, 0)
	
	var transparency = float(50+(randi() % 50))/100
	cloud.transparency = transparency
	
	var scale_multiplier = (float(100+(randi() % 100))/25) * factor
	cloud.scale = Vector2(scale_multiplier, scale_multiplier)
	
	match factor:
		1:
			clouds_1.append(cloud)
		2:
			clouds_2.append(cloud)
	add_child(cloud)

func spawn_nest():
	var closest_distance = 100000
	var closest_tree
	for tree in trees:
		if tree.position.distance_to(player.position) < closest_distance:
			closest_distance = tree.position.distance_to(player.position)
			closest_tree = tree
	
	var new_nest = load("res://scenes/nest.tscn").instance()
	new_nest.position = closest_tree.position
	nest = new_nest
	add_child(new_nest)

func spawn_chicks():
	for x in range(0, 4):
		var chick = load("res://scenes/chick.tscn").instance()
		chick.player = player
		match x:
			0:
				chick.target_position = Vector2(-250, 10)
			1:
				chick.target_position = Vector2(-130, 0)
			2:
				chick.target_position = Vector2(130, 0)
			3:
				chick.target_position = Vector2(250, 10)
		chick.max_speed = player.hori_speed * 1.25
		add_child(chick)

func change_height():
	if player.height != player.new_height:
		player.height = player.new_height
		
		if player.height < player.branches_height:
			var transparency = float(player.height-player.ground_height)/float(player.branches_height-player.ground_height)
			if transparency < 0:
				transparency = 0
			for tree in trees:
				tree.self_modulate = Color(1, 1, 1, 0)
				tree.tree_branches.self_modulate = Color(1, 1, 1, transparency)
		
		elif player.height < player.treetop_height:
			var transparency = float(player.height-player.branches_height)/float(player.treetop_height-player.branches_height)
			if transparency < 0:
				transparency = 0
			for tree in trees:
				tree.self_modulate = Color(1, 1, 1, transparency)
				tree.tree_branches.visible = true
				tree.tree_log.visible = true
		elif player.height < player.cloud_height_1:
			for tree in trees:
				tree.self_modulate = Color(1, 1, 1, 1)
				tree.tree_branches.visible = false
				tree.tree_log.visible = false
		
		elif player.height < player.cloud_height_2:
			var transparency = float(player.height-player.cloud_height_1)/float(player.cloud_height_2-player.cloud_height_1)
			for cloud in clouds_1:
				cloud.modulate = Color(1, 1, 1, cloud.transparency * transparency)
		elif player.height < player.cloud_height_3:
			var transparency = float(player.height-player.cloud_height_2)/float(player.cloud_height_3-player.cloud_height_2)
			
			for cloud in clouds_2:
				cloud.modulate = Color(1, 1, 1, cloud.transparency * transparency)

func check_for_border():
	#for super_x in range(-1, 2):
	var pos_to_check = player.position + player.dir * 8000
	#pos_to_check += pos_to_check + (pos_to_check.rotated(PI/2)* (super_x*chunk_size))
	var x = floor((pos_to_check/tilemap.cell_size).x)
	var y = floor((pos_to_check/tilemap.cell_size).y)
	
	if tilemap.get_cell(x, y) == -1:
		x = floor(float(x)/(chunk_size/1000))
		y = floor(float(y)/(chunk_size/1000))
		var size = 3
		for added_x in range(0, size):
			for added_y in range(0, size):
				generate_new_chunk((x-1+added_x)*(chunk_size/1000), (y-1+added_y)*(chunk_size/1000))

func generate_new_chunk(x, y):
	#set_tilemap
	var new_range = chunk_size/tilemap.cell_size.x
	var start_x = 0
	var spawn_stuff = false
	
	var numbers = []
	for _x in range(0, 5):
		for y in range(0, 9):
			numbers.append(y)
	var pos = 0
	numbers.shuffle()
	
	while start_x < new_range:
		var start_y = 0
		while start_y < new_range:
			if tilemap.get_cell(x + start_x, y + start_y) == -1:
				spawn_stuff = true
				if !autumn:
					tilemap.set_cell(x + start_x, y + start_y, numbers[pos])
				else:
					tilemap.set_cell(x + start_x, y + start_y, numbers[pos] + tile_amount)
				pos += 1
				if pos >= len(numbers):
					pos = 0
					numbers.shuffle()
			start_y += 1
		start_x += 1
	
	if spawn_stuff:
		var tree_x = 0 + (x*tilemap.cell_size.x)
		while tree_x < (x*tilemap.cell_size.x)+chunk_size:
			var tree_y = 0 + (y*tilemap.cell_size.y)
			tree_x += tree_step_size
			while tree_y < (y*tilemap.cell_size.y)+chunk_size:
				tree_y += tree_step_size
				var noise_value = tree_noise.get_noise_2d(tree_x, tree_y)
				
				if noise_value >= tree_threshhold:
					spawn_tree(tree_x, tree_y)
				
				if noise_value <= dirt_threshhold:
					spawn_dirt_hill(tree_x, tree_y)
				elif noise_value <= partner_threshhold:
					spawn_partner(tree_x, tree_y)
				elif noise_value <= deco_threshhold:
					spawn_deco(tree_x, tree_y)
		
		var cloud_1_x = 0 + (x*tilemap.cell_size.x)
		while cloud_1_x < (x*tilemap.cell_size.x)+chunk_size:
			var cloud_1_y = 0 + (y*tilemap.cell_size.y)
			cloud_1_x += cloud_step
			while cloud_1_y < (y*tilemap.cell_size.y)+chunk_size:
				cloud_1_y += cloud_step
				var noise_value = cloud_noise.get_noise_2d(cloud_1_x, cloud_1_y)
				if noise_value <= cloud_threshhold:
					spawn_cloud(cloud_1_x, cloud_1_y, 1)
		
		var cloud_2_x = 0 + (x*tilemap.cell_size.x)
		while cloud_2_x < (x*tilemap.cell_size.x)+chunk_size:
			var cloud_2_y = 0 + (y*tilemap.cell_size.y)
			cloud_2_x += cloud_2_step
			while cloud_2_y < (y*tilemap.cell_size.y)+chunk_size:
				cloud_2_y += cloud_2_step
				var noise_value = cloud_2_noise.get_noise_2d(cloud_2_x, cloud_2_y)
				if noise_value <= cloud_2_threshhold:
					spawn_cloud(cloud_2_x, cloud_2_y, 1)
