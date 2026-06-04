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
	for line in data.split("\n"):
		var row = line.split(",")
		var time = row[0]
		var key = row[1]
		times.append(float(time))
		
	
	animation_player.play("Crank Dat")
	animation_player.pause()

func can_i_crank_it():
	return not is_cranking

func crank_dat():
	is_cranking = true
	animation_player.play()

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


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Pawn" and can_i_crank_it():
		GameManager.player_manager.append_interactable(interactable)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		GameManager.player_manager.pop_interactable(interactable)
