extends Node

@export var animation_player: AnimationPlayer
var risen = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.LeverToggled.connect(rise)

func rise(name, state):
	if name == "mausTest" and state and not risen:
		animation_player.play("Rise")
		risen = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
