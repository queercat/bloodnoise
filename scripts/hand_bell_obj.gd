extends Node

@export var interactable: Interactable
@export var star_halo: Node3D

func grab():
	GameManager.player_manager.grab_bell()
	star_halo.die()
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node) -> void:
	star_halo.set_active(true)
	if body.get_parent().name == "Pawn":
		GameManager.player_manager.append_interactable(interactable)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if star_halo: star_halo.set_active(false)
	if body.get_parent().name == "Pawn":
		interactable.skip_hide = true
		GameManager.player_manager.pop_interactable(interactable)
