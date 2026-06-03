extends Node

@export var interactable: Interactable
@export var default_state: bool = false
@export var one_way: bool = false

var state: bool = false
var changed: bool = false
var anim_player : AnimationPlayer 

func toggle_state():
	changed = true
	state = !state
	anim_player.play("on" if state else "off")
	GameManager.lever_toggled(name, state)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player = $"./AnimationPlayer"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node) -> void:
	if body.get_parent().name == "Pawn" and not (one_way and changed):
		GameManager.player_manager.append_interactable(interactable)	

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.get_parent().name == "Pawn" and not (one_way and changed):
		interactable.skip_hide = false
		GameManager.player_manager.pop_interactable(interactable)
