extends Resource
class_name CollectableResource

@export var collectable_name: String
@export var prefab: PackedScene

func _init() -> void:
	pass

func from(position: Vector3):
	var instantiated = prefab.instantiate() as Node3D
	instantiated.position
	return instantiated
