extends Node3D

var is_open = false
var original_rotation
@export var open_duration_seconds: int = 4
var locks_left = 4

func handle_lock_unlocked(name):
	locks_left -= 1
	
	if locks_left == 0:
		open()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_rotation = Vector3(rotation_degrees.x, rotation_degrees.y, rotation_degrees.z)
	GameManager.LockUnlocked.connect(handle_lock_unlocked)

func open():
	if is_open: return
	is_open = true
	var t = create_tween()
	t.tween_property(self, "rotation_degrees", Vector3(rotation_degrees.x, -90, rotation_degrees.z), open_duration_seconds).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await t.finished
	GameManager.world.do_ending(Types.GameEnding.GOOD)

func close():
	if not is_open: return
	var t = create_tween()
	t.tween_property(self, "rotation_degrees", original_rotation, open_duration_seconds).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	await t.finished
	is_open = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
