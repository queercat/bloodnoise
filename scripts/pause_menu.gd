extends CenterContainer

@onready var continue_button = $"PauseMenu/Continue"

func focus_me():
	continue_button.grab_focus()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
