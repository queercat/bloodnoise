extends Node3D

@export var light: OmniLight3D
@export var light_on : bool = false
@export var turn_off_after : float = 2.0

var tween
var decay_counter = 0;
# when sound sphere hits me, turn on!

func turn_on_light():
	light.light_energy = 1
	light_on = true
	
func turn_off_light(in_secs):
	tween = 	get_tree().root.create_tween()
	tween.tween_property(light, "light_energy", 0, in_secs)
	await tween.finished
	light_on = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_area_entered(body: Node3D) -> void:
	if not light_on:
		turn_on_light()
		turn_off_light(turn_off_after)
	else:
		tween.kill()
		turn_on_light()
		turn_off_light(turn_off_after)	
