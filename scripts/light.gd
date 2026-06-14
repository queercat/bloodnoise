extends Node3D

@export var primary_light: OmniLight3D
@export var secondary_light: OmniLight3D
@export var light_on : bool = false
@export var fade_duration_secs : float = 2.0
@export var light_on_duration_secs : float = 2.0
@export var awake_anim : AnimationPlayer

var tween
var decay_counter = 0;
# when sound sphere hits me, turn on!

func turn_on_light():
	secondary_light.light_energy = 1
	light_on = true
	awake_anim.play("Activate")
	await awake_anim.animation_finished
	awake_anim.play("Idle_activated")
	primary_light.light_energy = 1
	
	
func turn_off_light(in_secs):
	tween = 	create_tween()
	tween.tween_property(primary_light, "light_energy", 0, in_secs)
	tween.parallel().tween_property(secondary_light, "light_energy", 0, in_secs)
	
	awake_anim.play("Activate", -1, -1, true)
	
	await tween.finished
	await awake_anim.animation_finished
	light_on = false
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_area_entered(body: Node3D) -> void:
	if not light_on:
		trigger_light_sequence()


func trigger_light_sequence():
	await turn_on_light()
	await get_tree().create_timer(light_on_duration_secs, false).timeout
	turn_off_light(fade_duration_secs)
