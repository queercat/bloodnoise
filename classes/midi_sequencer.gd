extends Node
class_name MidiSequencer

@export var stream: AudioStreamPlayer3D
var times: Array = []
var burned_times: Array[float] = []

@export var animation_player: AnimationPlayer
@export_multiline("monospace", "no_wrap") var data: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for line in data.split("\n"):
		var row = line.split(",")
		var time = row[0]
		var key = row[1]
		times.append(float(time))
		
	# stream.play()
	# animation_player.play("Crank Dat")
	# stream.finished.connect(func (): animation_player.stop())

func get_playable_positions():
	return times.filter(func (v): return v not in burned_times)

func trigger():
	GameManager.spawn_sound_sphere(stream.global_position, 50, Color.PURPLE, 200)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stream.playing:
		var current_time = stream.get_playback_position()
		var positions = get_playable_positions()
		
		for time_marker in positions:
			if time_marker <= current_time:
				trigger()
				burned_times.append(time_marker)
