extends AudioStreamPlayer3D

@export var bpm: float
@export var offset: float

var next_pulse_time: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func get_pulse():
	return (60 / bpm) * 1000

func pulse():
	GameManager.spawn_sound_sphere(global_position, 100, Color.PURPLE,200)

func _play(time: float = 0) -> void:
	play(time)
	next_pulse_time = Time.get_ticks_msec()

func _stop():
	stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_playing() == false:
		return
		
	var now = Time.get_ticks_msec()
	
	if now >= next_pulse_time:
		pulse()
		next_pulse_time = get_pulse() + now
