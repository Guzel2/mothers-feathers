extends AnimatedSprite
 
onready var grandparent = get_parent().get_parent().get_parent()
onready var gameplay
onready var hud
onready var mission

func ready():
	gameplay = grandparent.gameplay
	hud = grandparent.hud
	mission = hud.mission
	print(gameplay)

func send_message():#ursprünglich aus enter()
	if(gameplay.branch_count >= gameplay.branch_max || gameplay.fly_count >= gameplay.fly_max || gameplay.worm_count >= gameplay.worm_max):
		hud.mission.enter()
		mission.text = "Return to the nest"
		yield(get_tree().create_timer(5.0), "timeout")
		mission.exit()
	else:
		match gameplay.phase:
			0: 
				mission.enter()
				mission.text = "Find a partner"
				yield(get_tree().create_timer(10.0), "timeout")
				mission.exit()
			1:
				mission.enter()
				mission.text = "Collect " + str(gameplay.branch_max) + " branches for your nest"
				yield(get_tree().create_timer(10.0), "timeout")
				mission.exit()
			4:
				mission.enter()
				mission.text = "Catch " + str(gameplay.fly_max) + " flies for food"
				yield(get_tree().create_timer(18.0), "timeout")
				mission.exit()
			6:
				mission.enter()
				mission.text = "Catch " + str(gameplay.worm_max) + " worms to feed your chicks"
				yield(get_tree().create_timer(10.0), "timeout")
				mission.exit()
			2,3,5,7:
				pass

func enter():
	self.visible = true

func exit():
	self.visible = false
