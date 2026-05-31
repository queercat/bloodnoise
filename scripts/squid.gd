extends Node3D

var last_noise: float = 0
@export var noise_texture: NoiseTexture2D
var sample_position: float = 0
var speed = 10
@onready var animation_player = $"AnimationPlayer"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("Float")
	
func add_noise_to_position():
	position -= Vector3(last_noise, last_noise, last_noise)
	last_noise = noise_texture.noise.get_noise_1d(sample_position) / 5
	position += Vector3(last_noise, last_noise, last_noise)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(GameManager.player_manager.body.position)
