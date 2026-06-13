extends Node

class_name PlayerManager

@export var sound_sphere_prefab: PackedScene
@export var body: CharacterBody3D
@export var sound_cooldown : float = 1.0 
@export var world_mesh: MeshInstance3D
@export var move_functions: Node
@export var user_input: Node

var uber_material: ShaderMaterial
var run_action_held: bool = false
var move_speed: float = 1.0
var sound_cooldown_timer : float = 0
var interactable_queue: Array[Interactable] = []
var has_bell = false

func append_interactable(interactable):
	self.interactable_queue.append(interactable)

	if len(interactable_queue) == 1:
		interactable.show_interaction()

func pop_interactable(interactable):
	if len(interactable_queue) >= 1:
		if interactable == interactable_queue.front():
			interactable.hide_interaction()
		var idx = interactable_queue.find(interactable)
		self.interactable_queue.pop_at(idx)

	if len(interactable_queue) >= 1:
		interactable_queue.front().show_interaction()

func spawn_sound_sphere():
	GameManager.spawn_sound_sphere(body.global_position, 25, Color.RED, 50)
	GameManager.spawn_noise(preload("res://audio/player/bell1.wav"), Vector3.ZERO, self, randf_range(.7, 1.2))
	
func grab_bell():
	GameManager.BellGrabbed.emit()
	has_bell = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player_manager = self
	world_mesh.show()
	uber_material = world_mesh.mesh.surface_get_material(0)

func _input(event: InputEvent) -> void:
	if event.is_action("primary_action") and sound_cooldown_timer <= 0 and has_bell:
		sound_cooldown_timer = sound_cooldown
		spawn_sound_sphere()
	if event.is_action("do_interaction") and event.pressed and len(interactable_queue) > 0:
		if interactable_queue.front().do_interaction():
			pop_interactable(interactable_queue.front())
	if event.is_action_pressed("pm_run") and not run_action_held:
		run_action_held = true
		move_functions.Parameters.FORWARD_SPEED *= 2
		move_functions.Parameters.MAX_SPEED *= 2
	elif event.is_action_released("pm_run") and run_action_held:
		run_action_held = false
		move_functions.Parameters.FORWARD_SPEED /= 2
		move_functions.Parameters.MAX_SPEED /= 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if sound_cooldown_timer > 0:
		sound_cooldown_timer -= delta
	GameManager.feed_material_spheres(uber_material)
	GameManager.feed_material_clock(uber_material)
