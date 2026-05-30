extends Node

class_name PlayerManager

@export var sound_sphere_prefab: PackedScene
@export var body: CharacterBody3D
@export var sound_cooldown : float = 1.0 
@export var animated_sprite: AnimatedSprite3D

var sound_cooldown_timer : float = 0
var interactable_queue: Array[Interactable] = []

func append_interactable(interactable):
	self.interactable_queue.append(interactable)

	if len(interactable_queue) == 1:
		interactable.show_interaction()

func pop_interactable():
	if len(interactable_queue) >= 1:
		var interactable = self.interactable_queue.pop_front()
		interactable.hide_interaction()
	if len(interactable_queue) >= 1:
		interactable_queue.front().show_interaction()

func spawn_sound_sphere():
	var instantiated_sphere: Node3D = sound_sphere_prefab.instantiate()
	var root = get_tree().root
	instantiated_sphere.transform = body.transform
	root.add_child(instantiated_sphere)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player_manager = self

func _input(event: InputEvent) -> void:
	if event.is_action("primary_action") and sound_cooldown_timer <= 0:
		animated_sprite.stop()
		animated_sprite.play("shake")
		sound_cooldown_timer = sound_cooldown
		spawn_sound_sphere()
	if event.is_action("do_interaction") and len(interactable_queue) > 0:
		if interactable_queue.front().do_interaction():
			interactable_queue.pop_front()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sound_cooldown_timer > 0:
		sound_cooldown_timer -= delta
