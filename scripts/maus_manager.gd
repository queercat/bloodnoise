extends Node

@export var animation_player: AnimationPlayer
var risen = false

func rise():
	if not risen:
		animation_player.play("Rise")
		risen = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
