extends AudioStreamPlayer

@export var bpm: float
@export var offset: float
var target
var next_pulse_time: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_pulse_time = Time.get_ticks_msec()

func get_pulse():
	return (60 / bpm) * 1000

func pulse():
	GameManager.spawn_sound_sphere(target.global_position, 100, Color.PURPLE,200)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if is_playing() == false:
		return
		
	var now = Time.get_ticks_msec()
	
	if now >= next_pulse_time:
		pulse()
		next_pulse_time = get_pulse() + now
