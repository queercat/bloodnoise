extends Button

@export var ending: String

func _pressed() -> void:
	GameManager.world.do_ending(int(ending))
