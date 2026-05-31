extends Node

var player_items: Array[CollectableResource] = []
var ui: GameUI
var player_manager: PlayerManager
var write_mutex: Mutex = Mutex.new()
var sound_spheres: Array[Node3D] = []
var sphere_material: Material

var sound_sphere_prefab = preload("res://prefabs/sound_sphere.tscn")

signal LockUnlocked(name: String)

func spawn_sound_sphere(position: Vector3, growth_speed: float = 5):
	var root = get_tree().root
	var instance: Node3D = sound_sphere_prefab.instantiate()
	instance.position = position
	instance.growth_speed = growth_speed
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var camera = get_viewport().get_camera_3d()
	
	var array = sound_spheres.map(func (v): return Vector4(v.global_position.x, v.global_position.y, v.global_position.z, v.radius))
	sphere_material.set_shader_parameter("sphere_data", array)
