extends Node

var player_items: Array[CollectableResource] = []
var ui: GameUI
var player_manager: PlayerManager
var write_mutex: Mutex = Mutex.new()
var sound_spheres: Array[Node3D] = []
var sphere_material: Material
var sphere_data = []
var sphere_attributes_data = []

var sound_sphere_prefab = preload("res://prefabs/sound_sphere.tscn")

signal LockUnlocked(name: String)

func spawn_sound_sphere(position: Vector3, growth_speed: float = 5, color: Color = Color.WHITE, max_radius: float = 10):
	var root = get_tree().root
	var instance: Node3D = sound_sphere_prefab.instantiate()
	instance.position = position
	instance.growth_speed = growth_speed
	instance.max_radius = max_radius
	instance.color = color
	root.add_child(instance)
	sound_spheres.append(instance)

func delete_sound_sphere(sphere: Node3D):
	sound_spheres.erase(sphere)

func unlocked_lock(name: String):
	LockUnlocked.emit(name)

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sphere_material = get_viewport().get_camera_3d().get_node("MeshInstance3D").get_material()

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	generate_sphere_data()
	feed_material_spheres(sphere_material)
