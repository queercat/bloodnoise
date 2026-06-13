extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	
	if parent.name == "Pawn":
		GameManager.player_entered_end_area()
