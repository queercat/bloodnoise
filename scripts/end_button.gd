extends Button

@export var ending: String

func _pressed() -> void:
	GameManager.do_ending(ending)
