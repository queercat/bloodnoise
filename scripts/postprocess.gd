extends SubViewportContainer

@onready var subviewport = $"SubViewport"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size = get_viewport().size
	subviewport.size = size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
