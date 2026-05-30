extends Node3D

@onready var animation_player = $"AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# animation_player.play("Speen")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(GameManager.player_manager.body.position)
