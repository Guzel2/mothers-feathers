extends AudioStreamPlayer

var fading_in
var volume_steps = .125

func _ready():
	set_process(false)

func _process(delta):
	if fading_in:
		volume_db += volume_steps
		if volume_db > -10:
			volume_db = -10
			set_process(false)
	else:
		volume_db -= volume_steps
		if volume_db < -40:
			playing = false
			set_process(false)

func fade_in():
	fading_in = true
	volume_db = -40
	playing = true
	set_process(true)

func fade_out():
	fading_in = false
	set_process(true)
