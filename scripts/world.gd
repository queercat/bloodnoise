extends Node3D



@export var shader_mesh: MeshInstance3D
@export var cutscene_camera: Camera3D
@onready var heaven_door = $"Gate Area/heavenDoor1_1"
@onready var bad_end_camera = $"BadEndCamera"
@onready var good_end_camera = $"GoodEndCamera"
@onready var eye = $"Eye"
@onready var end_scene: PackedScene = load("res://scenes/end_screen.tscn")
@onready var flor = $"Flor"
@onready var flor_intro = $"FlorStuff/FlorIntro"
@onready var flor_song = $"FlorStuff/FlorSong"

var uber_shader: ShaderMaterial
var is_ending = false
var locks_unlocked = 0
var total_locks = 4

func hampter_end():
	var node = GameManager.spawn_global_noise(preload("res://audio/bad_end/the_hampsterdance_song.mp3"), 1, "Music", 1, self)
	
	node.set_script(preload("res://scripts/bpm_emitter.gd"))
	node.bpm = 136
	node.target = GameManager.player_manager.body
	node.set_process(true)
	
	uber_shader.set_shader_parameter("enable_party_mode", true)
	uber_shader.set_shader_parameter("enable_wave", true)
	
	await get_tree().create_timer(15, false).timeout
	
	node.stop()
	uber_shader.set_shader_parameter("enable_party_mode", false)
	uber_shader.set_shader_parameter("enable_wave", false)

func bad_end():
	bad_end_camera.make_current()
	bad_end_camera.shake_intensity = 1
	eye.target = bad_end_camera
	var t = get_tree().create_tween()
	t.tween_property(bad_end_camera, "shake_intensity", 4, 5)
	await t.finished

func flor_end():
	flor_intro.play()
	await flor_intro.finished
	flor_song.play()
	await flor_song.finished

func do_ending(ending_name: Types.GameEnding):
	var next_screen = end_scene.instantiate()
	
	if is_ending:
		return

	is_ending = true
	
	match ending_name:
		Types.GameEnding.GOOD:
			await good_end()
		Types.GameEnding.BAD:
			await bad_end()
		Types.GameEnding.HAMPTER:
			await hampter_end()
		Types.GameEnding.FLOR:
			await flor_end()
	
	GameManager.endings_seen[ending_name] = true
	get_tree().change_scene_to_node(next_screen)
	queue_free()

func good_end():
	good_end_camera.make_current()
	heaven_door.open()
	var t = create_tween()
	t.tween_property(good_end_camera, "global_position", good_end_camera.target.global_position, 5)
	await t.finished

func idiot_player_fell_through_floor_not_my_fault_btw(node):
	var parent = node.get_parent()
	if parent.name == "Pawn":
		do_ending(Types.GameEnding.FLOR)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flor.body_entered.connect(idiot_player_fell_through_floor_not_my_fault_btw)
	uber_shader = shader_mesh.get_active_material(0)
	
	GameManager.world = self
	GameManager.uber_shader = uber_shader
	
	GameManager.StartCutscene.connect(start_cutscene)
	GameManager.StopCutscene.connect(end_cutscene)
	
	GameManager.set_world_passcode(randi_range(1, 999))
	
	GameManager.LockUnlocked.connect(func (n): locks_unlocked += 1)

	if OS.has_feature("editor"):
		for idx in 3:
			GameManager.give_player_item(preload("res://resources/collectables/key_collectable.tres"))

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


func _on_end_area_body_entered(body: Node3D) -> void:
	var parent = body.get_parent()
	if parent and parent.name == "Pawn":
		if locks_unlocked < total_locks and not GameManager.endings_seen.has(Types.GameEnding.HAMPTER):
			do_ending(Types.GameEnding.HAMPTER)
