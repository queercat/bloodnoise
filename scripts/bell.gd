extends Node3D

@onready var stream: AudioStreamPlayer3D = $"AudioStreamPlayer3D"
@export var time_positions: Array[float] = []
var burned_times: Array[int] = []
var tolerance = .01

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.LeverToggled.connect(handle_lever)

func do_cutscene():
	GameManager.start_cutscene()
	stream.play()
	await get_tree().create_timer(10).timeout
	GameManager.stop_cutscene()
	GameManager.world.eye.trigger()
	
func handle_lever(name, state):
	if name == "churchLever" and state == true:
		do_cutscene()

func get_playable_positions():
	return time_positions.filter(func (v): return not burned_times.has(v))

func bong():
	GameManager.spawn_sound_sphere(global_position, 100, Color.PURPLE, 500)
	# GameManager.shake_camera()
	print("bong")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stream.playing:
		var current_time = stream.get_playback_position()
		var positions = get_playable_positions()
		
		for time_marker in positions:
			if time_marker <= current_time:
				bong()
				burned_times.append(time_marker)
