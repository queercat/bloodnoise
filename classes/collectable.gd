extends Node3D

class_name Collectable
@export var collectable_resource: Resource
@export var collection_zone: Area3D
var target = null
var being_consumed = false
var rotation_speed = 1

func collect():
	target = GameManager.player_manager.body
	GameManager.spawn_global_noise(preload("res://audio/sound effects/keyPickup.wav"))

func consume():
	if being_consumed: return
	being_consumed = true
	
	var t = get_tree().root.create_tween()
	t.tween_property(self, "scale", Vector3.ZERO, 4)
	t.parallel().tween_property(self, "rotation_speed", 10, 2)
	t.parallel().tween_property(self, "position", position + Vector3(0, 10, 0), 2)
	await t.finished
	GameManager.give_player_item(collectable_resource)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collection_zone.body_entered.connect(handle_body_entered)

func handle_body_entered(body: Node3D):
	if body.get_parent().name == "Pawn":
		collect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(Vector3.UP, delta * rotation_speed)
	if target != null:
		global_position = lerp(global_position, target.global_position, .01)
		var distance = global_position.distance_to(target.global_position)
		if distance <= 3:
			consume()
			target = null
