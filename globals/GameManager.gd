extends Node

const total_locks = 4

var player_items: Array[CollectableResource] = []
var ui: GameUI
var player_manager: PlayerManager
var write_mutex: Mutex = Mutex.new()
var sound_spheres: Array[Node3D] = []
var uber_shader: ShaderMaterial
var sphere_data = []
var sphere_attributes_data = []
var camera: Camera3D
var camera_shake_value: Vector2 = Vector2.ZERO
var shake_timer = 0
var locks_unlocked = 0
var endings_seen = 0
var end_screen = preload("res://scenes/end_screen.tscn")
var start_screen = preload("res://scenes/start_screen.tscn")
var heaven_door: Node3D
var has_seen_intro: bool = false
var volume: float = 100
var y_sensitivty: float = 1
var x_sensitivty: float = 1


var sound_sphere_prefab = preload("res://prefabs/sound_sphere.tscn")
var is_ending = false
var has_started = false

signal LockUnlocked(name: String)
signal CheatedBadEnd()
signal LeverToggled(name: String, state: bool)

signal VolumeChanged(volume: float)
signal StartCutscene()
signal StopCutscene()
signal MidiNote(emitter, key)
signal SetWorldPasscode(passcode)

var warp_zones = {}

func volume_changed(new_volume: float):
	volume = new_volume
	AudioServer.set_bus_volume_linear(1, volume / 100)
	AudioServer.set_bus_volume_linear(2, volume / 100)
	VolumeChanged.emit(new_volume)

func do_ending(name: String):
	match name.to_lower():
		"good":
			good_end()
		"bad":
			bad_end()
			bad_end()
			

func register_warp_zone(node):
	warp_zones[node.zone] = node

func warp_to(zone):
	print("warping to %s" % zone)
	print(warp_zones[zone])
	player_manager.body.global_position = warp_zones[zone].global_position

func set_world_passcode(passcode):
	SetWorldPasscode.emit(passcode)

func midi_note(emitter, key):
	print(key)
	MidiNote.emit(emitter, key)

func start_cutscene():
	StartCutscene.emit()

func stop_cutscene():
	StopCutscene.emit()

func spawn_sound_sphere(position: Vector3, growth_speed: float = 5, color: Color = Color.WHITE, max_radius: float = 10):
	var root = get_tree().root
	var instance: Node3D = sound_sphere_prefab.instantiate()
	instance.position = position
	instance.growth_speed = growth_speed
	instance.max_radius = max_radius
	instance.color = color
	root.add_child(instance)
	sound_spheres.append(instance)

func bad_end():
	if is_ending:
		return
	
	is_ending = true
	
	uber_shader.set_shader_parameter("enable_party_mode", true)
	uber_shader.set_shader_parameter("enable_wave", true)
	CheatedBadEnd.emit()
	
	await get_tree().create_timer(15).timeout
	
	has_started = false
	get_tree().change_scene_to_packed(end_screen)
	uber_shader.set_shader_parameter("enable_party_mode", false)
	uber_shader.set_shader_parameter("enable_wave", false)

func good_end():
	if is_ending:
		return
	
	is_ending = true
	heaven_door.open()

func player_entered_end_area(): 
	if locks_unlocked < total_locks:
		bad_end()
	else:
		good_end()

func delete_sound_sphere(sphere: Node3D):
	sound_spheres.erase(sphere)

func unlocked_lock(name: String):
	LockUnlocked.emit(name)
	locks_unlocked += 1
	
func lever_toggled(name: String, state: bool):
	LeverToggled.emit(name, state)

func does_player_have_item(name: String):
	return player_items.any(func (v: CollectableResource): return v.collectable_name == name)

func consume_player_item(name: String):
	write_mutex.lock()
	var index = player_items.find_custom(func (v: CollectableResource): return v.collectable_name == name)
	assert(index >= 0, "Player does NOT have that item.")
	player_items.remove_at(index)
	write_mutex.unlock()

func give_player_item(resource: CollectableResource):
	player_items.push_back(resource)
	print("got %s" % resource.collectable_name)

func shake_camera():
	shake_timer = Time.get_ticks_msec() + 1000

func apply_camera_shake():
	return 
	if camera:
		var range = .2
		camera.position -= Vector3(camera_shake_value.x, 0, camera_shake_value.y)
		camera_shake_value = Vector2(randf_range(-range, range), randf_range(-range, range))
		camera.position +=  Vector3(camera_shake_value.x, 0, camera_shake_value.y)
	
	if Time.get_ticks_msec() >= shake_timer:
		shake_timer = 0
		camera.position -= Vector3(camera_shake_value.x, 0, camera_shake_value.y)

func __ready():
	camera = get_viewport().get_camera_3d()
	shake_timer = 0

func _ready() -> void:
	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	volume_changed(volume)
	
func init_material(material):
	material.set_shader_parameter("enable_party_mode", false)
	material.set_shader_parameter("enable_wave", false)

func spawn_noise(stream: AudioStream, position: Vector3, parent, pitch = 1, bus = "Sound Effect"):
	var node = AudioStreamPlayer3D.new()
	node.stream = stream
	node.position = position
	node.pitch_scale = pitch
	node.bus = bus
	
	if parent == null:
		parent = get_tree().root
	
	parent.add_child(node)
	node.play()

func generate_sphere_data():
	sphere_data.clear()
	sphere_attributes_data.clear()
	for v in sound_spheres:
		sphere_data.push_back(Vector4(v.global_position.x, v.global_position.y, v.global_position.z, v.radius))
		sphere_attributes_data.push_back(Vector4(v.color.r, v.color.g, v.color.b, v.max_radius))

func feed_material_spheres(material):
	material.set_shader_parameter("sphere_data_length", len(sphere_data))
	material.set_shader_parameter("sphere_data", sphere_data)
	material.set_shader_parameter("sphere_attributes_data", sphere_attributes_data)

func feed_material_clock(material):
	material.set_shader_parameter("clock", Time.get_ticks_msec())

func handle_exit():
	has_started = false
	get_tree().change_scene_to_packed(start_screen)
	get_tree().paused = false

func handle_quit():
	get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not has_started: return
	
	generate_sphere_data()
	
	if shake_timer > 0:
		apply_camera_shake()
