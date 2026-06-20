extends Control

@export var skip_intro: bool = false

@onready var video_player = $"VideoStreamPlayer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if GameManager.has_seen_intro or OS.has_feature("editor") or skip_intro:
		done()
	video_player.connect("finished", done)

func done():
	GameManager.has_seen_intro = true
	get_parent().play_background_music()
	
	hide() 
	queue_free()
