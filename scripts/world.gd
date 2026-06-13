extends Node3D

@export var shader_mesh: MeshInstance3D
@export var cutscene_camera: Camera3D
@onready var heaven_door = $"Gate Area/heavenDoor1_1"
@onready var bad_end_camera = $"BadEndCamera"
@onready var eye = $"Eye"
var uber_shader: ShaderMaterial
var is_ending = false
var locks_unlocked = 0
var total_locks = 4

func hampter_end():
	if is_ending:
		return
	
	is_ending = true
	
	uber_shader.set_shader_parameter("enable_party_mode", true)
	uber_shader.set_shader_parameter("enable_wave", true)
	GameManager.CheatedBadEnd.emit()
	
	await get_tree().create_timer(15).timeout
	
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")
	
	uber_shader.set_shader_parameter("enable_party_mode", false)
	uber_shader.set_shader_parameter("enable_wave", false)

func bad_end():
	if is_ending: return
	bad_end_camera.make_current()
	eye.target = bad_end_camera
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func do_ending(ending_name: Types.GameEnding):
	match ending_name:
		Types.GameEnding.GOOD:
			await good_end()
		Types.GameEnding.BAD:
			await bad_end()

	queue_free()

	is_ending = true

func good_end():
	if is_ending:
		return
	
	heaven_door.open()

func player_entered_end_area(): 
	if locks_unlocked < total_locks:
		do_ending(Types.GameEnding.BAD)
	else:
		do_ending(Types.GameEnding.GOOD)

func end_game(ending_type: Types.GameEnding):
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	uber_shader = shader_mesh.get_active_material(0)
	
	GameManager.world = self
	GameManager.uber_shader = uber_shader
	
	GameManager.StartCutscene.connect(start_cutscene)
	GameManager.StopCutscene.connect(end_cutscene)
	
	GameManager.set_world_passcode(randi_range(1, 999))

func start_cutscene():
	cutscene_camera.make_current()

func end_cutscene():
	cutscene_camera.clear_current()

#func shake_camera():
	#shake_timer = Time.get_ticks_msec() + 1000
#
#func apply_camera_shake():
	#return 
	#if camera:
		#var range = .2
		#camera.position -= Vector3(camera_shake_value.x, 0, camera_shake_value.y)
		#camera_shake_value = Vector2(randf_range(-range, range), randf_range(-range, range))
		#camera.position +=  Vector3(camera_shake_value.x, 0, camera_shake_value.y)
	#
	#if Time.get_ticks_msec() >= shake_timer:
		#shake_timer = 0
		#camera.position -= Vector3(camera_shake_value.x, 0, camera_shake_value.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
