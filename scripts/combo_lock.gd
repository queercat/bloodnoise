extends Node3D

@export var animation_player: AnimationPlayer
@export var top_area: Area3D
@export var middle_area: Area3D
@export var bottom_area: Area3D
@export var lock_area: Area3D
var player_in_area = false

var values = [0, 0, 0]
var pointer = -1
var target: Node3D = null
var passcode: int
var is_locked = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.SetWorldPasscode.connect(func (n): passcode = n)

func unlock():
	is_locked = false
	animation_player.play("OpenAnimation")
	await animation_player.animation_finished
	var parent = get_parent_node_3d()
	var t = get_tree().root.create_tween()
	t.tween_property(parent, "position", Vector3(position.x  + 2, position.y, position.z), 2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	await t.finished
	t = get_tree().create_tween()
	t.tween_property(parent, "scale", Vector3.ZERO, 1.3)
	t.parallel().tween_property(parent, "global_rotation_degrees", Vector3(0, 480, 0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_EXPO)
	await t.finished
	GameManager.LockUnlocked.emit(parent.name)
	parent.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not player_in_area:
		return
	
	var space_state = get_world_3d().direct_space_state
	var cam = get_viewport().get_camera_3d()
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 100
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	if result:
		var parent = result.collider.get_parent()
		var text = "Press E to rotate %s cylinder"
		if parent:
			match parent.name:
				"Top":
					GameManager.ui.show_interact_text(text % "top")
					target = parent
					pointer = 2
				"Middle":
					GameManager.ui.show_interact_text(text % "middle")
					target = parent
					pointer = 1
				"Bottom":
					GameManager.ui.show_interact_text(text % "bottom")
					target = parent
					pointer = 0
	elif target:
		target = null
		pointer = -1
		GameManager.ui.hide_interact_text()
	
func updated_passcode(bottom, middle, top):
	var number = int("%d%d%d" % [top, middle, bottom])
	if passcode == number:
		unlock()

func _input(event: InputEvent) -> void:
	if not target: return
	if event.is_action_pressed("do_interaction"):
		target.rotate_object_local(Vector3(0, 1, 0), deg_to_rad(-36))
		values[pointer] = (values[pointer] + 1) % 10
		updated_passcode(values[0], values[1], values[2])

func _on_lock_area_body_entered(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		player_in_area = true


func _on_lock_area_body_exited(body: Node3D) -> void:
	if body.get_parent().name == "Pawn":
		player_in_area = false
		GameManager.ui.hide_interact_text()
