extends Node
class_name MidiSequencer

@export var stream: AudioStreamPlayer3D
@export var interactable: Interactable
var times: Array = []
var burned_times: Array[float] = []
var is_cranking: bool = false

@export var animation_player: AnimationPlayer
@export_multiline("monospace", "no_wrap") var data: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var idx = 0
	for line in data.split("\n"):
		var row = line.split(",")
		var time = row[0]
		var key = row[1]
		times.append([float(time), int(key), idx])
		idx += 1
		
	animation_player.play("Crank Dat")
	animation_player.speed_scale = 0

func can_i_crank_it():
	return not is_cranking

func crank_dat():
	is_cranking = true
	animation_player.speed_scale = 1
	stream.play()
	stream.finished.connect(handle_finished)

func handle_finished():
	GameManager.midi_note("piano_reset", -1, -1)
	animation_player.speed_scale = 0
	is_cranking = false
	burned_times = []
	stream.finished.disconnect(handle_finished)

func get_playable_positions():
	return times.filter(func (v): return v[0] not in burned_times)

func trigger(time, key, index):
	GameManager.midi_note("piano", key, index)
	GameManager.spawn_sound_sphere(stream.global_position, 50, Color.PURPLE, 200)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation_player.speed_scale > 0:
		var current_time = stream.get_playback_position()
		var positions = get_playable_positions()
		
		for time_marker in positions:
			if time_marker[0] <= current_time:
				trigger(time_marker[0], time_marker[1], time_marker[2])
				burned_times.append(time_marker[0])


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Pawn" and can_i_crank_it():
		GameManager.player_manager.append_interactable(interactable)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		GameManager.player_manager.pop_interactable(interactable)
