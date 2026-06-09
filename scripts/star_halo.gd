extends Node3D

# Rotation in radians
@export var star_obj : MeshInstance3D
@export var container_to_kill : Node3D = self
@export var active_anim_speed : float = 5.0
@export var active_anim_windup_secs : float = 1.0

var anim_player : AnimationPlayer
var is_active = false

func set_active(state: bool):
	is_active = state
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT if is_active else Tween.EASE_IN)
	tween.tween_property(anim_player, "speed_scale", active_anim_speed if is_active else 1.0, active_anim_windup_secs)

func die():
	# functional alpha fade out tween, but doesnt work with post-processing. Change material override alpha mode to work
	#var tween = get_tree().create_tween()
	#tween.tween_property(star_obj, "material_override:albedo_color:a", 0, active_anim_windup_secs)
	#await tween.finished
	container_to_kill.queue_free()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player = $"./AnimationPlayer"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	anim_player.play("idle", -1, 1, false)
