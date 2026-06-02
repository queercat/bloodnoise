extends Node3D

@export var time_till_impact_seconds: float
@export var impact_node: Node3D

func trigger():
	var t = get_tree().create_tween()
	
	t.tween_property(self, "global_position", impact_node.global_position, time_till_impact_seconds).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	await t.finished
	
	print("GAME OVER")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(GameManager.player_manager.body.position)
