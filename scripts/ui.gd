extends Control
class_name GameUI

@export var interact_text: RichTextLabel
@export var diagetic_container: Control
@export var pause_container: Control

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

func handle_pause():
	get_tree().paused = true
	pause_container.show()
	diagetic_container.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handle_unpause():
	get_tree().paused = false
	pause_container.hide()
	diagetic_container.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		match get_tree().paused:
			false:
				handle_pause()
			true:
				handle_unpause()
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
