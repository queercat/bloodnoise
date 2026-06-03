extends Node

@export var shader_texture: TextureRect
@export var background: TextureRect
@export var left_logo: TextureRect
@export var right_logo: TextureRect
@export var left_audio: AudioStreamPlayer
@export var right_audio: AudioStreamPlayer
@export var static_audio: AudioStreamPlayer
var start_scene = preload("res://scenes/start_screen.tscn")

var texture: NoiseTexture2D
var shader: ShaderMaterial
var glitch = .1

func play():
	static_audio.volume_db = -20
	static_audio.play()
	left_audio.play()
	left_logo.show()
	await left_audio.finished
	glitch = .1
	
	await get_tree().create_timer(1).timeout
	right_audio.play()
	right_logo.show()
	await right_audio.finished
	glitch = .2
	
	var t = create_tween()
	t.tween_property(self, "glitch", 1, 5)
	t.parallel().tween_property(static_audio, "volume_db", 0, 5)
	await t.finished
	get_tree().change_scene_to_packed(start_scene)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	background.size = viewport_size
	texture = background.texture as NoiseTexture2D
	texture.width = viewport_size.x
	texture.height = viewport_size.y
	shader = shader_texture.material

	play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shader.set_shader_parameter("time", Time.get_ticks_msec())
	shader.set_shader_parameter("glitch", glitch)
