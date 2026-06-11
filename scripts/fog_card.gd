@tool
extends MeshInstance3D

const MATERIAL_OWNER_META := "_fog_card_owner"
const MESH_OWNER_META := "_fog_card_mesh_owner"

var _plane_size: Vector2 = Vector2(1.5, 1.5)
var _card_scale_factor: float = 14.02
var _phase: float = 0.45
var _random_offset: Vector2 = Vector2(0.21, 0.67)
var _billboard: bool = true
var _fog_tint: Color = Color(1.0, 1.0, 1.0, 1.0)
var _fog_opacity: float = 0.25098
var _noise_scale: float = 4.0
var _noise_speed: Vector2 = Vector2(0.05, 0.0)
var _softness: float = 3.0
var _fade_in: float = 0.1
var _fade_out: float = 0.9
var _near_fade: float = 3.0
var _far_fade: float = 50.0

@export_group("Reference Card")
@export var plane_size: Vector2 = Vector2(1.5, 1.5):
	get:
		return _plane_size
	set(value):
		_plane_size = Vector2(max(value.x, 0.01), max(value.y, 0.01))
		_apply_plane_size()
		_apply_material_params()

@export var card_scale_factor: float = 14.02:
	get:
		return _card_scale_factor
	set(value):
		_card_scale_factor = max(value, 0.01)
		_apply_material_params()

@export var phase: float = 0.45:
	get:
		return _phase
	set(value):
		_phase = clampf(value, 0.0, 1.0)
		_apply_material_params()

@export var random_offset: Vector2 = Vector2(0.21, 0.67):
	get:
		return _random_offset
	set(value):
		_random_offset = value
		_apply_material_params()

@export var billboard: bool = true:
	get:
		return _billboard
	set(value):
		_billboard = value
		_apply_material_params()

@export_group("Fog Material")
@export var fog_tint: Color = Color(1.0, 1.0, 1.0, 1.0):
	get:
		return _fog_tint
	set(value):
		_fog_tint = value
		_apply_material_params()

@export_range(0.0, 1.0, 0.001) var fog_opacity: float = 0.25098:
	get:
		return _fog_opacity
	set(value):
		_fog_opacity = clampf(value, 0.0, 1.0)
		_apply_material_params()

@export_range(0.01, 64.0, 0.01) var noise_scale: float = 4.0:
	get:
		return _noise_scale
	set(value):
		_noise_scale = max(value, 0.01)
		_apply_material_params()

@export var noise_speed: Vector2 = Vector2(0.05, 0.0):
	get:
		return _noise_speed
	set(value):
		_noise_speed = value
		_apply_material_params()

@export_range(0.0, 10.0, 0.01) var softness: float = 3.0:
	get:
		return _softness
	set(value):
		_softness = clampf(value, 0.0, 10.0)
		_apply_material_params()

@export_range(0.0, 1.0, 0.001) var fade_in: float = 0.1:
	get:
		return _fade_in
	set(value):
		_fade_in = clampf(value, 0.0, 1.0)
		_apply_material_params()

@export_range(0.0, 1.0, 0.001) var fade_out: float = 0.9:
	get:
		return _fade_out
	set(value):
		_fade_out = clampf(value, 0.0, 1.0)
		_apply_material_params()

@export_range(0.01, 200.0, 0.01) var near_fade: float = 3.0:
	get:
		return _near_fade
	set(value):
		_near_fade = max(value, 0.01)
		_apply_material_params()

@export_range(0.01, 400.0, 0.01) var far_fade: float = 50.0:
	get:
		return _far_fade
	set(value):
		_far_fade = max(value, 0.01)
		_apply_material_params()


func _ready() -> void:
	if Engine.is_editor_hint():
		_ensure_unique_mesh()
		_ensure_unique_material_override()
		set_process(true)
	_pull_material_params()
	_apply_plane_size()
	_apply_material_params()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	_ensure_unique_mesh()
	_ensure_unique_material_override()
	_pull_material_params()


func _apply_plane_size() -> void:
	_ensure_unique_mesh()

	var quad_mesh := mesh as QuadMesh
	if quad_mesh == null:
		quad_mesh = QuadMesh.new()
		mesh = quad_mesh

	quad_mesh.size = _plane_size


func _apply_material_params() -> void:
	var shader_material := material_override as ShaderMaterial
	if shader_material == null:
		return

	shader_material.set_shader_parameter("scale_factor", _card_scale_factor)
	shader_material.set_shader_parameter("phase", _phase)
	shader_material.set_shader_parameter("random_offset", _random_offset)
	shader_material.set_shader_parameter("billboard", _billboard)
	shader_material.set_shader_parameter("color", Color(_fog_tint.r, _fog_tint.g, _fog_tint.b, _fog_opacity))
	shader_material.set_shader_parameter("noise_scale", _noise_scale)
	shader_material.set_shader_parameter("noise_speed", _noise_speed)
	shader_material.set_shader_parameter("softness", _softness)
	shader_material.set_shader_parameter("fade_in", _fade_in)
	shader_material.set_shader_parameter("fade_out", _fade_out)
	shader_material.set_shader_parameter("near_fade", _near_fade)
	shader_material.set_shader_parameter("far_fade", _far_fade)


func _pull_material_params() -> void:
	var shader_material := material_override as ShaderMaterial
	if shader_material == null:
		return

	var color_variant: Variant = shader_material.get_shader_parameter("color")
	if color_variant is Color:
		var shader_color: Color = color_variant
		_fog_tint = Color(shader_color.r, shader_color.g, shader_color.b, 1.0)
		_fog_opacity = shader_color.a

	var noise_scale_variant: Variant = shader_material.get_shader_parameter("noise_scale")
	if noise_scale_variant is float:
		_noise_scale = max(noise_scale_variant as float, 0.01)

	var noise_speed_variant: Variant = shader_material.get_shader_parameter("noise_speed")
	if noise_speed_variant is Vector2:
		_noise_speed = noise_speed_variant

	var softness_variant: Variant = shader_material.get_shader_parameter("softness")
	if softness_variant is float:
		_softness = clampf(softness_variant as float, 0.0, 10.0)

	var fade_in_variant: Variant = shader_material.get_shader_parameter("fade_in")
	if fade_in_variant is float:
		_fade_in = clampf(fade_in_variant as float, 0.0, 1.0)

	var fade_out_variant: Variant = shader_material.get_shader_parameter("fade_out")
	if fade_out_variant is float:
		_fade_out = clampf(fade_out_variant as float, 0.0, 1.0)

	var near_fade_variant: Variant = shader_material.get_shader_parameter("near_fade")
	if near_fade_variant is float:
		_near_fade = max(near_fade_variant as float, 0.01)

	var far_fade_variant: Variant = shader_material.get_shader_parameter("far_fade")
	if far_fade_variant is float:
		_far_fade = max(far_fade_variant as float, 0.01)


func _ensure_unique_material_override() -> void:
	var shader_material := material_override as ShaderMaterial
	if shader_material == null:
		return

	var owner_path := _get_editor_owner_key()
	if shader_material.has_meta(MATERIAL_OWNER_META) and str(shader_material.get_meta(MATERIAL_OWNER_META)) == owner_path:
		return

	var unique_material := shader_material.duplicate(true) as ShaderMaterial
	if unique_material == null:
		return

	unique_material.resource_local_to_scene = true
	unique_material.set_meta(MATERIAL_OWNER_META, owner_path)
	material_override = unique_material


func _ensure_unique_mesh() -> void:
	var quad_mesh := mesh as QuadMesh
	if quad_mesh == null:
		return

	var owner_path := _get_editor_owner_key()
	if quad_mesh.has_meta(MESH_OWNER_META) and str(quad_mesh.get_meta(MESH_OWNER_META)) == owner_path:
		return

	var unique_mesh := quad_mesh.duplicate() as QuadMesh
	if unique_mesh == null:
		return

	unique_mesh.resource_local_to_scene = true
	unique_mesh.set_meta(MESH_OWNER_META, owner_path)
	mesh = unique_mesh


func _get_editor_owner_key() -> String:
	if is_inside_tree():
		return str(get_path())
	return "instance_%s" % str(get_instance_id())
