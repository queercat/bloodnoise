extends Node3D

@export var animation_player: AnimationPlayer
@export var player_detection_area: Area3D
@export var interactable: Interactable
@export var interaction_text: String

var opened = false

func open():
	if opened: return
	player_detection_area.queue_free()
	GameManager.player_manager.pop_interactable()
	GameManager.consume_player_item("key")
	opened = true
	var t = get_tree().create_tween()
	animation_player.play("OpenAnimation")
	t.tween_property(self, "position", Vector3(position.x  - 2, position.y, position.z), 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await t.finished
	t = get_tree().create_tween()
	t.tween_property(self, "scale", Vector3.ZERO, 1.3)
	t.parallel().tween_property(self, "global_rotation_degrees", Vector3(0, 480, 0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	await t.finished
	GameManager.LockUnlocked.emit(name)
	queue_free()

func can_open_lock():
	return GameManager.does_player_have_item("key")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if len(interaction_text) > 0: interactable.interaction_text = interaction_text
	else: interaction_text = interactable.interaction_text

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Pawn" and can_open_lock():
		GameManager.player_manager.append_interactable(interactable)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		GameManager.player_manager.pop_interactable()
