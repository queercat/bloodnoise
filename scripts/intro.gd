extends Control

@onready var video_player = $"VideoStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.has_seen_intro:
		done()
	video_player.connect("finished", done)

func done():
	GameManager.has_seen_intro = true
	hide() 
	queue_free()
