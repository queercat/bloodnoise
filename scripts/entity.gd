extends Node3D

@export var time_till_impact_seconds: float
@export var impact_node: Node3D
@onready var cloud_parent = $"CloudsParent"
var target: Node3D
var initial_distance

func trigger():
	var t = get_tree().create_tween()
	
	t.tween_property(self, "global_position", impact_node.global_position, time_till_impact_seconds)
	await t.finished
	
	GameManager.world.do_ending(Types.GameEnding.BAD)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = GameManager.player_manager.body
	initial_distance = global_position.distance_to(target.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(target.position)
	
	if global_position.distance_to(target.global_position) <= .5 * initial_distance:
		for child in cloud_parent.get_children():
			child.show()
