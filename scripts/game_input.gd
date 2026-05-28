extends Node

@export var sound_sphere_prefab: PackedScene
@export var body: CharacterBody3D
@export var sound_cooldown : float = 1.0 
@export var animated_sprite: AnimatedSprite3D
var sound_cooldown_timer : float = 0

func spawn_sound_sphere():
	var instantiated_sphere: Node3D = sound_sphere_prefab.instantiate()
	var root = get_tree().root
	instantiated_sphere.transform = body.transform
	root.add_child(instantiated_sphere)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action("primary_action") and sound_cooldown_timer <= 0:
		animated_sprite.stop()
		animated_sprite.play("shake")
		sound_cooldown_timer = sound_cooldown
		spawn_sound_sphere()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sound_cooldown_timer > 0:
		sound_cooldown_timer -= delta
