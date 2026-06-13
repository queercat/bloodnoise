extends Node

@onready var song_a: AudioStreamPlayer = $"Song A"
@onready var song_b: AudioStreamPlayer = $"Song B"

var index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.BellGrabbed.connect(start)

func start():
	song_a.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
