extends Button

@export var zone: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _pressed() -> void:
	GameManager.warp_to(zone)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
