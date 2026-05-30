extends Control
class_name GameUI

@export var interact_text: RichTextLabel

var lock: Array = [null, Mutex.new()]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.ui = self

func acquire_lock(owner):
	lock[1].lock()
	lock[0] = owner

func release_lock(owner):
	if lock[0] == owner:
		lock[1].unlock()
		return true
	return false

func show_interact_text(text: String):
	#acquire_lock(owner)
	if text:
		interact_text.text = text
	interact_text.show()

func hide_interact_text():
	#if release_lock(owner):
	interact_text.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
