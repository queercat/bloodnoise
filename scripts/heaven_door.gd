extends Node3D

@onready var animation_player = $"AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func open():
	animation_player.play("open")
	GameManager.spawn_global_noise(preload("res://audio/sound effects/door.mp3"),1, "Sound Effect", .1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
