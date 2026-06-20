extends Node3D

var blood = preload("res://scenes/blood.tscn")

@export var camera: Camera3D
@export var target: Node3D
@export var shader_mesh: MeshInstance3D
@onready var settings_button = $"UI/Menu/HBoxContainer/VBoxContainer/Settings"
@onready var settings_menu = $"UI/SettingsMenu"
@onready var menu = $"UI/Menu"
@onready var quit_button = $"UI/Menu/HBoxContainer/VBoxContainer/Exit"
@onready var background_music = $"BackgroundMusic"
@onready var endings_label = $"UI/MarginContainer/EndingsLabel"
@onready var start_button = $"UI/Menu/HBoxContainer/VBoxContainer/Start"

var shader_material: ShaderMaterial
var time = 0

func update_camera():
	camera.look_at(target.global_position)

func play_background_music():
	background_music = get_node("BackgroundMusic")
	if background_music: background_music.play()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_button.pressed.connect(func (): settings_menu.switch_from(menu))
	shader_material = shader_mesh.material_override
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	quit_button.pressed.connect(GameManager.handle_quit)
	endings_label.text = "[wave]%d / %d Endings[/wave]" % [GameManager.endings_seen.size(), Types.GameEnding.values().size()]
	start_button.grab_focus.call_deferred()

func map_mod(value: float, from_min: float, from_max: float, to_min: float, to_max: float):
	var ratio = (value - from_min) / (from_max - from_min)
	ratio = fmod(ratio, 1)
	return ratio

func update_shader(delta: float):
	time += delta
	var ratio = map_mod(time, 0, 10, .18, .45)
	var offset = cos(2 * PI * ratio) * .135
	var pos = .315 + offset
	shader_material.set_shader_parameter("u_offset", pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# update_shader(delta * .5)
	target.rotate(Vector3.UP, delta * .01)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(blood)
